import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/data/basic_sample_data.dart';
import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/tree/iterators.dart';


class TestLeafNode extends ConcreteLeafNode {
  TestLeafNode({required super.name});
  @override
  void fromMap(Map<String, Object> inputMap) {
    super.fromMap(inputMap);
  }
  factory TestLeafNode.fromJson(Map<String, Object> map) {
    final node = TestLeafNode(name: 'test');
    node.fromMap(map);
    print('TestLeafNode.fromJson(): ${node.toMap()}');
    return node;
  }
}

/// A bunch of diagnostic tests for json manipulation.
void main() {
  /// A reviver function for [jsonDecode] that ensures the resulting object 
  /// graph is strictly typed and adheres to the platform's No-Null Policy.
  Object _jsonReviver(Object? key, Object? value) {
    // Satisfy No-Null policy by converting nulls to empty strings.
    Object result = value ?? '';

    if (value is Map) {
      // Reify dynamic maps into strictly typed Map<String, Object>.
      result = Map<String, Object>.from(value);
    } else if (value is List) {
      // Reify dynamic lists into strictly typed List<Object>.
      result = List<Object>.from(value);
    }

    return result;
  }

  test('Output sample data to console hierarchically', () {
    // Iterate through each root site using DepthFirstIterator to visit 
    // all nodes in a predictable, iterative manner.
    for (final site in sampleSites) {
      final iterator = DepthFirstIterator(site);

      while (iterator.moveNext()) {
        final node = iterator.current;
        print('${node.toMap()}');
      }
    }
  });

  test('JSON conversion functionality check', () {
    // Create a basic map of mixed types about trees.
    final Map<String, Object> originalMap = {
      'species': 'Oak',
      'age': 50,
      'isHealthy': true,
      'height_m': 15.5,
      // List<String> with 3 elements.
      'tags': ['deciduous', 'hardwood', 'native'],
      // Map<String, int> with 4 elements.
      'countByYear': {
        '2021': 10,
        '2022': 12,
        '2023': 15,
        '2024': 18,
      },
    };

    // Serialize the map to a JSON string.
    final String jsonString = jsonEncode(originalMap);

    // Decode the JSON string back into a map using the reviver for reification.
    final dynamic decodedMap = jsonDecode(jsonString, reviver: _jsonReviver);

    // Verify that the reified decoded map is equal to the original map.
    expect(decodedMap, equals(originalMap));
  });

  test('JSON LeafNode Check', () {
    final leaf = TestLeafNode(name: 'Test Leaf');
    final String leafJson = jsonEncode(leaf);
    print(leafJson);
    final revivedLeafCastMap = jsonDecode(leafJson, reviver: _jsonReviver);
    print(revivedLeafCastMap);
    print(revivedLeafCastMap.runtimeType);
    final map = Map<String,Object>.from(revivedLeafCastMap);
    print(map);
    print(map.runtimeType);
    final revivedLeaf = TestLeafNode.fromJson(map);
    print(revivedLeaf);
  });
}
