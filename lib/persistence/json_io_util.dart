import 'dart:convert';
import 'package:stager_platform/system/registry.dart';
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
  String serialize(List<LeafNode> nodeList) {
    // No magic here - I moved it elsewhere!
    return jsonEncode(nodeList);
  }

  /// This is a custom reviver to remove null values from the JSON decoding
  /// output and partially regenerate maps and lists. It's handy.
  Object _jsonReviver(Object? key, Object? value) {
    Object result = ':';
    // Only revive the value if it is... revivable?
    if (value != null) {
      result = value;
      if (value is Map) {
        result = Map<String,Object>.from(value);
      } else if (value is List) {
        result = List<Object>.from(value);
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
    final List<LeafNode> nodeList = [];

    // jsonDecode automatically creates a List<dynamic> from the JSON string.
    // However, we avoid dynamic where possible in Stager, so we use a custom
    // "reviver" function that converts dynamic list elements - which could be
    // null values - to full Objects. The reviver also recovers List and Map
    // types. Assuming there's nothing funny with the data, each List element is
    // a node.
    final Object decodedJson = jsonDecode(jsonString,reviver:_jsonReviver);

    if (decodedJson is List) {
      // The base implementation of LeafNode provides a type parameter in
      // the map that identifies which concrete type the data represents. Thus,
      // here, we need recreate the Map, pull the type entry, use the type with
      // the Stager Registry to recreate the LeafNode, and add the
      // rebuilt node to the list to return.
      for (final entry in decodedJson as List) {
        try {
          if (entry.containsKey('type')) {
            final nodeMap = Map<String, Object>.from(entry);
            final nodeType = nodeMap['type']! as String;
            final node = buildObject(nodeType, nodeMap) as LeafNode;
            nodeList.add(node);
          } else {
            throw JsonIOException(
                'Cannot deserialize List element without "type" '
                    'key. Aborting');
          }
        } catch (e) {
          throw JsonIOException(
              'Something bad happened during deserialization: $e');
        }
      }
    } else {
      throw JsonIOException('Expected a list but received '
          '${decodedJson.runtimeType}.');
    }
    return nodeList;
  }
}
