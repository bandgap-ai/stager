import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/persistence/json_io_util.dart';
import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/system/point.dart';
import 'package:stager_platform/tree/tree.dart';

/// Unit tests for the [JsonIOUtil] codec.
void main() {
  group('JsonIOUtil Tests', () {
    const ioUtil = JsonIOUtil();

    test('should serialize and deserialize a complex tree structure', () {
      // Create a small tree hierarchy with diverse data types.
      final leaf1 = ConcreteLeafNode(name: 'Leaf 1');
      
      final leaf2 = ConcreteLeafNode(name: 'Leaf 2')
        ..position = const Point(coords: [-77.0, 38.0]);

      final comp1 = ConcreteCompositeNode(name: 'Composite 1');
      comp1.addChild(leaf2);

      final site1 = ConcreteTreeNode(name: 'Site 1');
      site1.setProperty('test_prop', const TypedValue<String>('value1'));
      site1.addChild(leaf1);
      site1.addChild(comp1);

      final originalTree = [site1];

      // Execute the full round-trip serialization cycle.
      final jsonString = ioUtil.serialize(originalTree);
      print(jsonString);
      final deserializedTree = ioUtil.deserialize(jsonString);

      // Verify that the hierarchy and reified state are faithfully restored.
      expect(deserializedTree.length, 1);
      final deserializedSite1 = deserializedTree.first as TreeNode;
      
      expect(deserializedSite1.name, 'Site 1');
      expect(deserializedSite1.typedProperty('test_prop').value, 'value1');
      
      // Verify positional integrity and child counts.
      expect(deserializedSite1.children.length, 2);
      
      final deserializedLeaf1 = deserializedSite1.children.first;
      expect(deserializedLeaf1.name, 'Leaf 1');
      
      final deserializedComp1 = deserializedSite1.children.last as CompositeNode;
      expect(deserializedComp1.children.length, 1);
      
      final deserializedLeaf2 = deserializedComp1.children.first;
      expect(deserializedLeaf2.name, 'Leaf 2');
      expect(deserializedLeaf2.position.x, -77.0);
    });

    test('should use default name when missing in JSON properties', () {
      // Provide a JSON object missing the 'name' property.
      const jsonString = '''
        [{
          "type": "ConcreteLeafNode",
          "properties": {
            "id": ["UuidValue", "019dc5cf-cfab-7c0d-96da-38ccb2e75155"]
          }
        }]
      ''';

      // Rehydrate the node and verify that it defaults to 'Unknown Node'.
      final nodes = ioUtil.deserialize(jsonString);
      expect(nodes.first.name, 'Unknown Node');
    });

    test('should throw JsonIOException when JSON is not a list', () {
      // Provide a map instead of the expected root list.
      const jsonString = '{"type": "ConcreteLeafNode"}';

      // Verify that the utility enforces the top-level list contract.
      expect(
        () => ioUtil.deserialize(jsonString),
        throwsA(isA<JsonIOException>().having(
          (e) => e.message,
          'message',
          contains('Invalid JSON format: Expected a list but received String.'),
        )),
      );
    });

    test('should throw JsonIOException when mandatory structural keys are missing', () {
      // Provide a node entry missing the 'type' discriminator.
      const jsonString = '[{"properties": {"name": "Test"}}]';

      // Verify that structural requirements are validated.
      expect(
        () => ioUtil.deserialize(jsonString),
        throwsA(isA<JsonIOException>().having(
          (e) => e.message,
          'message',
          contains('Missing mandatory structural keys'),
        )),
      );
    });

    test('should throw JsonIOException when rehydration fails (malformed tuple)', () {
      // Provide a malformed TypedValue tuple (too short).
      const jsonString = '''
        [{
          "type": "ConcreteLeafNode",
          "properties": {
            "name": "Broken",
            "age": ["int"]
          }
        }]
      ''';

      // Verify that tuple validation errors are caught and re-wrapped.
      expect(
        () => ioUtil.deserialize(jsonString),
        throwsA(isA<JsonIOException>().having(
          (e) => e.message,
          'message',
          contains('Malformed context data'),
        )),
      );
    });

    test('should throw JsonIOException when properties contain null values', () {
      // Provide a JSON structure where a typed value is null.
      const jsonString = '''
        [{
          "type": "ConcreteLeafNode",
          "properties": {
            "name": "NullTest",
            "age": ["int", null]
          }
        }]
      ''';

      // Verify that parsing errors (null to int) trigger a rehydration exception.
      expect(
        () => ioUtil.deserialize(jsonString),
        throwsA(isA<JsonIOException>().having(
          (e) => e.message,
          'message',
          contains('Deserialization failed'),
        )),
      );
    });

    test('should successfully skip non-map elements in the JSON list', () {
      // Provide a list containing both valid node maps and primitive values.
      const jsonString = '[123, {"type": "leaf", "properties": {"name": "Valid"}}]';

      // Verify that the deserializer robustly handles heterogeneous lists by 
      // focusing only on valid node representations.
      final nodes = ioUtil.deserialize(jsonString);
      expect(nodes.length, 1);
      expect(nodes.first.name, 'Valid');
    });
  });
}
