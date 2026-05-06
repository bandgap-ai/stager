import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/tree/basic_node_builder.dart';
import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/leaf_node.dart';
import 'mock_node_observer.dart';

void main() {
  group('Basic Node Builder', () {

    BasicNodeBuilder builder = BasicNodeBuilder();

    test('Build a leaf node', () {
      // Create a leaf node
      String name = "One";
      LeafNode node = builder.buildLeafNode(name);
      expect(node.name, name);
      expect(node.isComposite,isFalse);
    });

    test('Build a composite node', () {

      // Create a composite node
      String name = "Two";
      CompositeNode node = builder.buildCompositeNode(name);
      expect(node.name, name);
      expect(node.isComposite,isTrue);

      // Register as an observer of the composite node for the next exercise
      MockNodeObserver observer = MockNodeObserver();
      node.attach(observer);

      // Now build a leaf node and add it as a child
      String name2 = "Three";
      LeafNode child = builder.buildLeafNode(name2, node);
      // Check to see that the composite is linked as the child's parent
      expect(child.parent == node, isTrue);
      // Check to see that the observer was notified
      expect(observer.updated, isTrue);
    });
  });
}
