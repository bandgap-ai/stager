import 'dart:convert';
import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/tree/iterators.dart';

import '../builders/stager_context.dart';
import '../system/typed_value.dart';

/// A codec for serializing and deserializing a tree of [TreeNode]s to and from JSON.
class JsonIOUtil {
  const JsonIOUtil();

  /// Serializes a list of [LeafNode]s to a JSON string.
  String serialize(List<LeafNode> nodes) {
    final nodeMap = <LeafNode, Map<String, dynamic>>{};
    final allNodes = <LeafNode>[];

    // Flatten the trees and map nodes to their initial JSON objects.
    // We use a single loop with DepthFirstIterator to unify processing for 
    // both TreeNodes and simple LeafNodes.
    for (final rootNode in nodes) {
      _flattenSubtree(rootNode, allNodes, nodeMap);
    }

    // Assemble the nested hierarchy by linking parents to children.
    _linkHierarchy(allNodes, nodeMap);

    // Collect only the root-level JSON objects for final encoding.
    // Stager's no-null policy ensures that nodes in the input list exist.
    final rootJson = nodes.map((node) => nodeMap[node]!).toList();
    return jsonEncode(rootJson);
  }

  /// Traverses a subtree starting at [node] and populates the flat [allNodes] 
  /// list and the [nodeMap] with initial JSON structures.
  void _flattenSubtree(LeafNode node, List<LeafNode> allNodes,
      Map<LeafNode, Map<String, dynamic>> nodeMap) {
    // Treat the node as a tree (even if it's just a leaf) to use the iterator.
    final iterator = DepthFirstIterator(node);
    while (iterator.moveNext()) {
      final current = iterator.current;
      allNodes.add(current);
      nodeMap[current] = _nodeToJson(current);
    }
  }

  /// Transforms a single [LeafNode] into its JSON map representation.
  Map<String, dynamic> _nodeToJson(LeafNode node) {
    return {
      'type': node is TreeNode
          ? 'tree'
          : (node.isComposite ? 'composite' : 'leaf'),
      'properties': node.properties.map,
      if (node.isComposite) 'children': <Map<String, dynamic>>[],
    };
  }

  /// Establishes the parent-child links in the JSON representation.
  void _linkHierarchy(
      List<LeafNode> allNodes, Map<LeafNode, Map<String, dynamic>> nodeMap) {
    for (final node in allNodes) {
      final parent = node.parent;
      if (parent != null) {
        final parentJson = nodeMap[parent];
        final childJson = nodeMap[node];

        // Ensure both exist in our map before linking.
        if (parentJson != null && childJson != null) {
          final children = parentJson['children'] as List<dynamic>?;
          children?.add(childJson);
        }
      }
    }
  }

  /// Deserializes a JSON string into a list of [LeafNode]s.
  List<LeafNode> deserialize(String jsonString) {
    final List<LeafNode> rootNodes = [];
    final List<Map<String, dynamic>> stack = [];

    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! List) {
      throw FormatException(
          'Invalid JSON format: Expected a list but received ${decoded.runtimeType}.');
    }

    try {
      final List<dynamic> topLevelData = decoded;

      // Use a stack to reconstruct the hierarchy without recursion.
      for (final data in topLevelData.reversed) {
        stack.add({'data': data as Map<String, dynamic>, 'parent': null});
      }

      while (stack.isNotEmpty) {
        final current = stack.removeLast();
        final data = current['data'] as Map<String, dynamic>;
        final parent = current['parent'] as CompositeNode?;

        final LeafNode node = _createNodeFromJson(data);

        if (parent != null) {
          parent.addChild(node);
        } else {
          rootNodes.add(node);
        }

        if (data.containsKey('children')) {
          final childrenData = data['children'] as List<dynamic>;
          for (final childData in childrenData.reversed) {
            stack.add({'data': childData as Map<String, dynamic>, 'parent': node});
          }
        }
      }
    } on FormatException {
      rethrow;
    } catch (s,e) {
      throw FormatException('Failed to deserialize Stager tree. Is your JSON '
          'valid with TypedValues? Error: $e Stacktrace: $s');
    }
    return rootNodes;
  }

  static final Map<String, Function> _nodeFactory = {
    'tree': (String id, String name, Map<String, TypedValue<Object>> properties) =>
        ConcreteTreeNode(id: id, name: name, initialProperties: properties),
    'composite': (String id, String name, Map<String, TypedValue<Object>> properties) =>
        ConcreteCompositeNode(id: id, name: name, initialProperties: properties),
    'leaf': (String id, String name, Map<String, TypedValue<Object>> properties) =>
        ConcreteLeafNode(id: id, name: name, initialProperties: properties),
  };

  /// Creates a [LeafNode] from a JSON map representation.
  /// 
  /// Validates mandatory keys and enforces Stager's no-null policy.
  LeafNode _createNodeFromJson(Map<String, dynamic> data) {
    late final LeafNode result;

    // 1. Validate mandatory top-level keys.
    if (!data.containsKey('type')) {
      throw const FormatException('Missing mandatory key: type');
    }
    if (!data.containsKey('properties')) {
      throw const FormatException('Missing mandatory key: properties');
    }

    final type = data['type'] as String;
    // Deserialize the properties as Map<String, TypedValue<Object>> by first
    // going through Map<String,String> for rehydration.
    Map<String,dynamic> rawProps = data['properties'] as Map<String,dynamic>;
    Map<String,TypedValue<Object>> properties = {};
    for (final entry in rawProps.entries) {
      // This takes some converting because Stager proper only works with
      // Map<String,Object> or better.
      properties[entry.key] = buildTypedValue(StagerContext(
          _convertDynamicMap(entry.value as Map<String,dynamic>)));
    }
    print('$properties');

    // 2. Validate mandatory properties (id and name).
    if (!properties.containsKey('id')) {
      throw const FormatException('Missing mandatory property: id');
    }
    if (!properties.containsKey('name')) {
      throw const FormatException('Missing mandatory property: name');
    }

    // 3. Enforce no-null policy on mandatory properties.
    if (!properties.containsKey('id')) {
      throw const FormatException('Property "id" cannot be null');
    }
    if (!properties.containsKey('name')) {
      throw const FormatException('Property "name" cannot be null');
    }

    final id = properties['id']!.value as String;
    final name = properties['name']!.value as String;

    // 4. Resolve the node using the factory.
    final factory = _nodeFactory[type] ?? _nodeFactory['leaf']!;
    result = factory(id, name, properties);

    return result;
  }

  Map<String,String> _convertDynamicMap(Map<String,dynamic> dynaMap) {
    return dynaMap.map((key,value) => MapEntry(key, value!.toString()));
  }
}
