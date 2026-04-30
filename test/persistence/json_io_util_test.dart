import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/data/basic_sample_data.dart';
import 'package:stager_platform/persistence/json_io_util.dart';
import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/tree/tree.dart';

void main() {
  group('JsonIOUtil Tests', () {
    const ioUtil = JsonIOUtil();

    test('Handle LeafNodes', () {
      // Create a some concrete leaf nodes and write them to a JSON string.
      final leaf1 = ConcreteLeafNode(name: 'Leaf 1');
      final leaf2 = ConcreteLeafNode(name: 'Leaf 2');
      final leaf3 = ConcreteLeafNode(name: 'Leaf 3');
      final List<LeafNode> jsonLeaves = [leaf1, leaf2, leaf3];

      // Serialize the list of LeafNodes to a JSON string.
      final jsonOutput = ioUtil.serialize(jsonLeaves);

      // Parse the JSON string back into a list of LeafNodes.
      final deserializedLeaves = ioUtil.deserialize(jsonOutput);

      expect(deserializedLeaves.length, 3);
      expect(deserializedLeaves[0].name, 'Leaf 1');
      expect(deserializedLeaves[0].runtimeType, ConcreteLeafNode);
      expect(deserializedLeaves[1].name, 'Leaf 2');
      expect(deserializedLeaves[1].runtimeType, ConcreteLeafNode);
      expect(deserializedLeaves[2].name, 'Leaf 3');
      expect(deserializedLeaves[2].runtimeType, ConcreteLeafNode);    });

    test('Handle Composite Nodes', () {
      // Create a some concrete nodes and write them to a JSON string.
      final leaf1 = ConcreteLeafNode(name: 'Leaf 1');
      final leaf2 = ConcreteLeafNode(name: 'Leaf 2');
      final branch = ConcreteCompositeNode(name: 'Branch');
      final List<LeafNode> jsonNodes = [leaf1, leaf2, branch];

      // Assign children to the branch node
      branch.addChild(ConcreteLeafNode(name: 'Leaf 3'));
      branch.addChild(ConcreteCompositeNode(name: 'Node 4'));

      // Serialize the list of nodes to a JSON string.
      final jsonOutput = ioUtil.serialize(jsonNodes);

      // Parse the JSON string back into a list of nodes.
      final deserializedNodes = ioUtil.deserialize(jsonOutput);

      expect(deserializedNodes.length, 3);
      expect(deserializedNodes[0].name, 'Leaf 1');
      expect(deserializedNodes[0].runtimeType, ConcreteLeafNode);
      expect(deserializedNodes[1].name, 'Leaf 2');
      expect(deserializedNodes[1].runtimeType, ConcreteLeafNode);
      expect(deserializedNodes[2].name, 'Branch');
      expect(deserializedNodes[2].runtimeType, ConcreteCompositeNode);

      // Check the branches children
      final children = (deserializedNodes[2] as ConcreteCompositeNode).children;
      expect(children.length, 2);
      expect(children[0].name, 'Leaf 3');
      expect(children[0].runtimeType, ConcreteLeafNode);
      expect(children[1].name, 'Node 4');
      expect(children[1].runtimeType, ConcreteCompositeNode);

    });

    test('Handle Tree Nodes', () {
      // Create a some concrete nodes and write them to a JSON string.
      final leaf1 = ConcreteLeafNode(name: 'Leaf 1');
      final leaf2 = ConcreteLeafNode(name: 'Leaf 2');
      final branch = ConcreteCompositeNode(name: 'Branch');
      final branch2 = ConcreteCompositeNode(name: 'Branch 2');
      final tree = ConcreteTreeNode(name: 'Tree');
      // Assign the children and build a cool tree
      branch.addChild(leaf1);
      branch2.addChild(leaf2);
      tree.addChild(branch);
      tree.addChild(branch2);
      // Build a second cool tree
      final leaf3 = ConcreteLeafNode(name: 'Leaf 3');
      final branch3 = ConcreteCompositeNode(name: 'Branch 3');
      final tree2 = ConcreteTreeNode(name: 'Tree 2');
      branch3.addChild(leaf3);
      tree2.addChild(branch3);
      // Create the list
      final List<LeafNode> jsonNodes = [tree,tree2];

      // Serialize the list of nodes to a JSON string.
      final jsonOutput = ioUtil.serialize(jsonNodes);

      // Parse the JSON string back into a list of nodes.
      final deserializedNodes = ioUtil.deserialize(jsonOutput);

      // There should be exactly two deserialized nodes since we only sent in
      // two trees.
      expect(deserializedNodes.length, 2);
      expect(deserializedNodes[0].name, 'Tree');
      expect(deserializedNodes[0].runtimeType, ConcreteTreeNode);
      expect(deserializedNodes[1].name, 'Tree 2');

      // Check tree 1's direct children - no need to go to the leaves since they
      // get two more tests
      final children = (deserializedNodes[0] as TreeNode).children;
      expect(children.length, 2);
      expect(children[0].name, 'Branch');
      expect(children[0].runtimeType, ConcreteCompositeNode);
      expect(children[1].name, 'Branch 2');
      expect(children[1].runtimeType, ConcreteCompositeNode);
      // And tree 2
      final children2 = (deserializedNodes[1] as TreeNode).children;
      expect(children2.length, 1);
      expect(children2[0].name, 'Branch 3');

    });

    test('should serialize and deserialize a tree structure', () {
      // Arrange
      final leaf1 = ConcreteLeafNode(name: 'Leaf 1');
      final leaf2 = ConcreteLeafNode(name: 'Leaf 2');
      final comp1 = ConcreteCompositeNode(name: 'Composite 1');
      comp1.addChild(leaf2);
      final site1 = ConcreteTreeNode(
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
      expect(deserializedSite1.name, 'Site 1');
      expect((deserializedSite1 as CompositeNode).children.length, 2);
      final deserializedLeaf1 =
          (deserializedSite1 as CompositeNode).children.first;
      expect(deserializedLeaf1.name, 'Leaf 1');
      final deserializedComp1 =
          (deserializedSite1 as CompositeNode).children.last as CompositeNode;
      expect(deserializedComp1.name, 'Composite 1');
      expect(deserializedComp1.children.length, 1);
      final deserializedLeaf2 = deserializedComp1.children.first;
      expect(deserializedLeaf2.name, 'Leaf 2');
    });

    test('should throw JsonException when JSON is not a list', () {
      // Arrange
      const jsonString = '{"type": "leaf"}';

      // Act & Assert
      expect(
        () => ioUtil.deserialize(jsonString),
        throwsA(isA<JsonIOException>().having(
          (e) => e.message,
          'message',
          contains('Expected a list but received _Map<String, Object>.'),
        )),
      );
    });

    test('should throw JsonException when mandatory keys are missing', () {
      // Arrange
      const jsonString = '[{"properties": {"id": "1", "name": "n"}}]'; // missing type

      // Act & Assert
      expect(
        () => ioUtil.deserialize(jsonString),
        throwsA(isA<JsonIOException>().having(
          (e) => e.message,
          'message',
          contains('Cannot deserialize List element without "type" '
              'key. Aborting'),
        )),
      );
    });

    test('should throw JsonException when JSON list contains non-map elements',
        () {
      // Arrange
      const jsonString = '[123]'; // Not a Map<String, dynamic>

      // Act & Assert
      expect(
        () => ioUtil.deserialize(jsonString),
        throwsA(isA<JsonIOException>().having(
          (e) => e.message,
          'message',
          contains('Something bad happened during deserialization:'),
        )),
      );
    });

    test('Can load the basic sample data', () {
      // Write the sampleSites data to a json string
      final sampleSiteJson = ioUtil.serialize(sampleSites);

      // Try to read it back in
      final deserializedSampleSites = ioUtil.deserialize(sampleSiteJson);


    });

  });
}
