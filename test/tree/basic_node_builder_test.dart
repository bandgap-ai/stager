import 'package:stager_platform/tree/basic_node_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/leaf_node.dart';

import 'mock_node_observer.dart';

void main() {
  group('Basic Node Builder', () {

    BasicNodeBuilder builder = BasicNodeBuilder();

    test('Build a leaf node', () {
      // Create a leaf node
      String id = "1";
      String name = "One";
      LeafNode node = builder.buildLeafNode(id, name);
      expect(node.properties.get<String>('id'), id);
      expect(node.properties.get<String>('name'), name);
      expect(node.isComposite,isFalse);
    });

    test('Build a composite node', () {

      // Create a composite node
      String id = "2";
      String name = "Two";
      CompositeNode node = builder.buildCompositeNode(id, name);
      expect(node.properties.get<String>('id'), id);
      expect(node.properties.get<String>('name'), name);
      expect(node.isComposite,isTrue);

      // Register as an observer of the composite node for the next exercise
      MockNodeObserver observer = MockNodeObserver();
      node.attach(observer);

      // Now build a leaf node and add it as a child
      String id2 = "3";
      String name2 = "Three";
      LeafNode child = builder.buildLeafNode(id2, name2, node);
      // Check to see that the composite is linked as the child's parent
      expect(child.parent == node, isTrue);
      // Check to see that the observer was notified
      expect(observer.updated, isTrue);
    });
  });
}
