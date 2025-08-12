import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/persistence/json_codec.dart';
import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/tree/concrete_tree.dart';

void main() {
  group('JsonCodec', () {
    test('should serialize and deserialize a tree structure', () {
      // Arrange
      final codec = JsonCodec();
      final leaf1 = ConcreteLeafNode(id: 'leaf1', name: 'Leaf 1');
      final leaf2 = ConcreteLeafNode(id: 'leaf2', name: 'Leaf 2');
      final comp1 = ConcreteCompositeNode(id: 'comp1', name: 'Composite 1');
      comp1.addChild(leaf2);
      final site1 = ConcreteTreeNode(
        id: 'site1',
        name: 'Site 1',
        initialProperties: {'prop1': 'value1'},
      );
      site1.addChild(leaf1);
      site1.addChild(comp1);
      final originalTree = [site1];

      // Act
      final jsonString = codec.serialize(originalTree);
      final deserializedTree = codec.deserialize(jsonString).cast<TreeNode>();

      // Assert
      expect(deserializedTree, isA<List<TreeNode>>());
      expect(deserializedTree.length, 1);
      final deserializedSite1 = deserializedTree.first;
      expect(deserializedSite1.properties.getProperty('name'), 'Site 1');
      expect((deserializedSite1 as CompositeNode).children.length, 2);
      final deserializedLeaf1 = (deserializedSite1 as CompositeNode).children.first;
      expect(deserializedLeaf1.properties.getProperty('name'), 'Leaf 1');
      final deserializedComp1 = (deserializedSite1 as CompositeNode).children.last as CompositeNode;
      expect(deserializedComp1.properties.getProperty('name'), 'Composite 1');
      expect(deserializedComp1.children.length, 1);
      final deserializedLeaf2 = deserializedComp1.children.first;
      expect(deserializedLeaf2.properties.getProperty('name'), 'Leaf 2');
    });
  });
}
