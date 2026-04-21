import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/persistence/json_io_util.dart';
import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/tree/tree.dart';

void main() {
  group('JsonIOUtil Tests', () {
    const ioUtil = JsonIOUtil();

    test('should serialize and deserialize a tree structure', () {
      // Arrange
      final leaf1 = ConcreteLeafNode(id: 'leaf1', name: 'Leaf 1');
      final leaf2 = ConcreteLeafNode(id: 'leaf2', name: 'Leaf 2');
      final comp1 = ConcreteCompositeNode(id: 'comp1', name: 'Composite 1');
      comp1.addChild(leaf2);
      final site1 = ConcreteTreeNode(
        id: 'site1',
        name: 'Site 1',
        initialProperties: {'prop1': TypedValue<String>('value1')},
      );
      site1.addChild(leaf1);
      site1.addChild(comp1);
      final originalTree = [site1];

      // Act
      final jsonString = ioUtil.serialize(originalTree);
      final deserializedTree = ioUtil.deserialize(jsonString).cast<TreeNode>();

      // Assert
      expect(deserializedTree, isA<List<TreeNode>>());
      expect(deserializedTree.length, 1);
      final deserializedSite1 = deserializedTree.first;
      expect(deserializedSite1.properties.get<String>('name'), 'Site 1');
      expect((deserializedSite1 as CompositeNode).children.length, 2);
      final deserializedLeaf1 =
          (deserializedSite1 as CompositeNode).children.first;
      expect(deserializedLeaf1.properties.get<String>('name'), 'Leaf 1');
      final deserializedComp1 =
          (deserializedSite1 as CompositeNode).children.last as CompositeNode;
      expect(deserializedComp1.properties.get<String>('name'), 'Composite 1');
      expect(deserializedComp1.children.length, 1);
      final deserializedLeaf2 = deserializedComp1.children.first;
      expect(deserializedLeaf2.properties.get<String>('name'), 'Leaf 2');
    });

    test('should throw FormatException when JSON is not a list', () {
      // Arrange
      const jsonString = '{"type": "leaf"}';

      // Act & Assert
      expect(
        () => ioUtil.deserialize(jsonString),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Expected a list but received'),
        )),
      );
    });

    test('should throw FormatException when mandatory keys are missing', () {
      // Arrange
      const jsonString = '[{"properties": {"id": "1", "name": "n"}}]'; // missing type

      // Act & Assert
      expect(
        () => ioUtil.deserialize(jsonString),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Missing mandatory key: type'),
        )),
      );
    });

    test('should throw FormatException when mandatory properties are missing',
        () {
      // Arrange
      const jsonString = '[{"type": "leaf", "properties": {"id": {"type": "String", "value": "1"}}}]'; // missing name

      // Act & Assert
      expect(
        () => ioUtil.deserialize(jsonString),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Missing mandatory property: name'),
        )),
      );
    });

    test('should throw FormatException when properties contain null values',
        () {
      // Arrange
      const jsonString =
          '[{"type": "leaf", "properties": {"id": {"type": "String", "value": "1"}, "name": {"type": "String", "value": null}}}]';

      // Act & Assert
      expect(
        () => ioUtil.deserialize(jsonString),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Null check operator used on a null value'),
        )),
      );
    });

    test('should throw FormatException when JSON list contains non-map elements',
        () {
      // Arrange
      const jsonString = '[123]'; // Not a Map<String, dynamic>

      // Act & Assert
      expect(
        () => ioUtil.deserialize(jsonString),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Failed to deserialize Stager tree'),
        )),
      );
    });
  });
}
