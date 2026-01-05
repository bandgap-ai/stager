import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/stager.dart';

void main() {
  group('Stager Public API Smoke Test', () {
    test('should allow creation and composition of tree nodes', () {
      // This test verifies that the core concrete classes are exported and
      // that a basic tree can be constructed.

      // 1. Create a root node for the tree.
      final ConcreteTreeNode root = ConcreteTreeNode(
        id: 'root-id',
        name: 'Root Node',
      );

      // 2. Create a composite node.
      final ConcreteCompositeNode composite = ConcreteCompositeNode(
        id: 'comp-id',
        name: 'Composite Node',
      );

      // 3. Create a leaf node.
      final ConcreteLeafNode leaf = ConcreteLeafNode(
        id: 'leaf-id',
        name: 'Leaf Node',
      );

      // 4. Build the hierarchy.
      root.addChild(composite);
      composite.addChild(leaf);

      // 5. Assert that the hierarchy was built correctly.
      expect(root.children.length, 1);
      expect(root.children.first, isA<ConcreteCompositeNode>());
      expect(composite.parent, root);
      expect(composite.children.length, 1);
      expect(composite.children.first, isA<ConcreteLeafNode>());
      expect(leaf.parent, composite);
    });
  });
}
