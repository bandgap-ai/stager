import 'dart:convert';
import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/tree/concrete_tree.dart';
import 'package:stager_platform/tree/iterators.dart';
import 'package:logger/logger.dart';

/// A codec for serializing and deserializing a tree of [TreeNode]s to and from JSON.
class JsonCodec {

  /// Logger for this class.
  final logger = Logger();

  /// Serializes a list of [LeafNode]s to a JSON string.
  String serialize(List<LeafNode> nodes) {
    final nodeMap = <LeafNode, Map<String, dynamic>>{};
    final allNodes = <LeafNode>[];

    // First pass: create a JSON object for each node and populate the map
    for (final rootNode in nodes) {
      if (rootNode is TreeNode) {
        final iterator = DepthFirstIterator(rootNode);
        while (iterator.moveNext()) {
          final node = iterator.current;
          allNodes.add(node);
          nodeMap[node] = {
            'type': node is TreeNode ? 'tree' : (node.isComposite ? 'composite' : 'leaf'),
            'properties': node.properties.map,
            if (node.isComposite) 'children': <Map<String, dynamic>>[],
          };
        }
      } else {
        allNodes.add(rootNode);
        nodeMap[rootNode] = {
          'type': 'leaf',
          'properties': rootNode.properties.map,
        };
      }
    }

    // Second pass: assemble the hierarchy
    for (final node in allNodes) {
      if (node.parent != null) {
        final parentJson = nodeMap[node.parent!];
        final childJson = nodeMap[node]!;
        (parentJson!['children'] as List).add(childJson);
      }
    }

    // Collect the root-level JSON objects
    final rootJson = nodes.map((node) => nodeMap[node]!).toList();
    return jsonEncode(rootJson);
  }

  /// Deserializes a JSON string into a list of [LeafNode]s.
  List<LeafNode> deserialize(String jsonString) {

    final List<LeafNode> rootNodes = [];
    final List<Map<String, dynamic>> stack = [];

    try {
      final List<dynamic> topLevelData = jsonDecode(jsonString) as List<
          dynamic>;

      for (final data in topLevelData.reversed) {
        stack.add({'data': data, 'parent': null});
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
            stack.add({'data': childData, 'parent': node});
          }
        }
      }
    } catch (e){
      logger.e('Error deserializing JSON: $e');
      throw FormatException('Invalid JSON format: '
          'Expected a list but received ${jsonString.runtimeType}');
    }
    return rootNodes;
  }

  static final Map<String, Function> _nodeFactory = {
    'tree': (String id, String name, Map<String, dynamic> properties) =>
        ConcreteTreeNode(id: id, name: name, initialProperties: properties),
    'composite': (String id, String name, Map<String, dynamic> properties) =>
        ConcreteCompositeNode(id: id, name: name, initialProperties: properties),
    'leaf': (String id, String name, Map<String, dynamic> properties) =>
        ConcreteLeafNode(id: id, name: name, initialProperties: properties),
  };

  /// Creates a [LeafNode] from a JSON map representation.
  LeafNode _createNodeFromJson(Map<String, dynamic> data) {
    final type = data['type'] as String;
    final properties = data['properties'] as Map<String, dynamic>;
    final id = properties['id'] as String;
    final name = properties['name'] as String;

    final factory = _nodeFactory[type] ?? _nodeFactory['leaf']!;
    return factory(id, name, properties);
  }
}
