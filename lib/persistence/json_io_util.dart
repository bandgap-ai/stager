import 'dart:convert';
import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/tree/iterators.dart';

/// Exception thrown when an error occurs during JSON serialization or
/// deserialization of the Stager tree structure.
class JsonIOException implements Exception {
  /// The error message.
  final String message;

  /// Constructor.
  JsonIOException(this.message);

  @override
  String toString() => 'JsonIOException: $message';
}

/// A codec for serializing and deserializing a tree of [TreeNode]s to and from JSON.
///
/// [JsonIOUtil] implements the platform's rehydration strategy by utilizing
/// [LeafNode.toMap] and [LeafNode.fromMap] to preserve reified type information
/// across the persistence boundary.
class JsonIOUtil {
  /// Constructor.
  const JsonIOUtil();

  /// Serializes a list of [LeafNode]s (roots of trees) to a JSON string.
  ///
  /// This method performs a non-recursive traversal of each root node,
  /// creating a hierarchical JSON structure that includes both intrinsic
  /// members and reified generic properties.
  ///
  /// [nodes]: The list of root nodes to serialize.
  String serialize(List<LeafNode> nodes) {
    final Map<LeafNode, Map<String, Object>> nodeMap = {};
    final List<LeafNode> allNodes = [];

    // Flatten the trees to capture all nodes and their local state.
    // We utilize DepthFirstIterator to unify processing for all node types.
    for (final rootNode in nodes) {
      _flattenSubtree(rootNode, allNodes, nodeMap);
    }

    // Connect the parent-child relationships in the JSON representation.
    _linkHierarchy(allNodes, nodeMap);

    // Filter the final list to include only the root-level JSON objects.
    final rootJson = nodes.map((node) {
      final json = nodeMap[node];
      if (json == null) {
        throw JsonIOException(
            'Failed to capture state for root node: ${node.name}');
      }
      return json;
    }).toList();

    return jsonEncode(rootJson);
  }

  /// Traverses a subtree starting at [node] and populates the tracking maps.
  void _flattenSubtree(LeafNode node, List<LeafNode> allNodes,
      Map<LeafNode, Map<String, Object>> nodeMap) {
    final iterator = DepthFirstIterator(node);
    while (iterator.moveNext()) {
      final current = iterator.current;
      allNodes.add(current);
      nodeMap[current] = _nodeToJson(current);
    }
  }

  /// Transforms a single [LeafNode] into its JSON map representation.
  ///
  /// This performs a 'Full Harvest' by calling node.toMap(), which captures
  /// the reified state of identity, position, and property bag members.
  Map<String, Object> _nodeToJson(LeafNode node) {
    late final Map<String, Object> result;

    result = {
      'type': node.runtimeType.toString(),
      'properties': node.toMap(),
      if (node.isComposite) 'children': <Map<String, Object>>[],
    };

    return result;
  }

  /// Establishes parent-child links within the serializable maps.
  void _linkHierarchy(
      List<LeafNode> allNodes, Map<LeafNode, Map<String, Object>> nodeMap) {
    for (final node in allNodes) {
      // Follows Rule 11: Use safe branching instead of null checks.
      if (node.hasParent()) {
        final parent = node.parent;
        final parentJson = nodeMap[parent];
        final childJson = nodeMap[node];

        if (parentJson != null && childJson != null) {
          final List<Object>? children =
              parentJson['children'] as List<Object>?;
          children?.add(childJson);
        }
      }
    }
  }

  Object _jsonReviver(Object? key, Object? value) {
    Object result = ':';
    // Only revive the value if it is... revivable?
    if (value != null) {
      result = value;
      if (value is Map) {
        result = Map<String,Object>.from(value);
      } else if (value is List) {
        result = List.from(value);
      }
    }
    return result;
  }

  /// Deserializes a JSON string into a list of [LeafNode]s.
  ///
  /// Reconstructs the tree structure and reified state using a non-recursive
  /// stack implementation.
  ///
  /// [jsonString]: The JSON data representing the tree.
  /// Returns a list of reconstructed root nodes.
  List<LeafNode> deserialize(String jsonString) {
    final List<LeafNode> rootNodes = [];
    final List<Map<String, Object?>> stack = [];

    final Object decoded = jsonDecode(jsonString,reviver:_jsonReviver);
    if (decoded is! List) {
      throw JsonIOException(
          'Invalid JSON format: Expected a list but received ${decoded.runtimeType}.');
    }

    try {
      final List<Object?> topLevelData = decoded;

      // Initialize the stack with top-level roots in reverse order for correct
      // depth-first processing.
      for (final data in topLevelData.reversed) {
        if (data is Map<String, Object?>) {
          stack.add({'data': data, 'parent': null});
        }
      }

      while (stack.isNotEmpty) {
        final current = stack.removeLast();
        final data = current['data'] as Map<String, Object?>;
        final parent = current['parent'] as CompositeNode?;

        // Rehydrate the node and its local state.
        final LeafNode node = _createNodeFromJson(data.cast<String, Object>());

        // Establish the hierarchical link.
        if (parent != null) {
          parent.addChild(node);
        } else {
          rootNodes.add(node);
        }

        // Push children for subsequent processing.
        if (data.containsKey('children')) {
          final List<Object?> childrenData = data['children'] as List<Object?>;
          for (final childData in childrenData.reversed) {
            if (childData is Map<String, Object?>) {
              stack.add({'data': childData, 'parent': node});
            }
          }
        }
      }
    } on Exception catch (e) {
      throw JsonIOException('Deserialization failed: $e');
    }

    return rootNodes;
  }

  // FIXME - This lookup table should be replaced by the platform's
  // global builder registry (stagerRegistry).
  static final Map<String, LeafNode Function(String)> _nodeFactory = {
    'ConcreteTreeNode': (name) => ConcreteTreeNode(name: name),
    'ConcreteCompositeNode': (name) => ConcreteCompositeNode(name: name),
    'ConcreteLeafNode': (name) => ConcreteLeafNode(name: name),
    // Support for legacy type discriminators.
    'tree': (name) => ConcreteTreeNode(name: name),
    'composite': (name) => ConcreteCompositeNode(name: name),
    'leaf': (name) => ConcreteLeafNode(name: name),
  };

  /// Instantiates a node and rehydrates its reified state from a JSON map.
  LeafNode _createNodeFromJson(Map<String, Object> data) {
    if (!data.containsKey('type') || !data.containsKey('properties')) {
      throw JsonIOException('Missing mandatory structural keys in node JSON.');
    }

    final type = data['type'] as String;
    final Map<String, Object> properties =
        (data['properties'] as Map<String, dynamic>).cast<String, Object>();

    // Extract identity for construction.
    final String name = (properties['name'] ?? 'Unknown Node').toString();

    // Instantiate via factory and delegate state restoration to fromMap().
    final factory = _nodeFactory[type] ?? _nodeFactory['leaf']!;
    final node = factory(name);

    node.fromMap(properties);

    return node;
  }
}
