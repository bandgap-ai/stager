
/// This file contains unit tests for the iterators defined in
/// `lib/stager/iterators.dart`.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/tree/concrete_tree.dart';
import 'package:stager_platform/tree/iterators.dart';

void main() {
  group('Iterators', () {
    late ConcreteTreeNode root;
    late ConcreteLeafNode leaf1, leaf2, leaf3, leaf4;
    late ConcreteCompositeNode comp1, comp2;

    setUp(() {
      // Set up a sample tree structure for traversal tests.
      root = ConcreteTreeNode(name: 'root');
      comp1 = ConcreteCompositeNode(name: 'comp1');
      leaf1 = ConcreteLeafNode(name: 'leaf1');
      leaf2 = ConcreteLeafNode(name: 'leaf2');
      comp2 = ConcreteCompositeNode(name: 'comp2');
      leaf3 = ConcreteLeafNode(name: 'leaf3');
      leaf4 = ConcreteLeafNode(name: 'leaf4');

      root.addChild(comp1);
      root.addChild(leaf4); // Add leaf4 to root to test mixed children
      comp1.addChild(leaf1);
      comp1.addChild(leaf2);
      comp1.addChild(comp2);
      comp2.addChild(leaf3);
    });

    test('DepthFirstIterator traverses correctly', () {
      final iterator = DepthFirstIterator(root);
      final visitedNodes = <String>[];
      while (iterator.moveNext()) {
        visitedNodes.add(iterator.current.name);
      }
      expect(visitedNodes, ['root', 'comp1', 'leaf1', 'leaf2', 'comp2', 'leaf3', 'leaf4']);
    });

    test('BreadthFirstIterator traverses correctly', () {
      final iterator = BreadthFirstIterator(root);
      final visitedNodes = <String>[];
      while (iterator.moveNext()) {
        visitedNodes.add(iterator.current.name);
      }
      expect(visitedNodes, ['root', 'comp1', 'leaf4', 'leaf1', 'leaf2', 'comp2', 'leaf3']);
    });
  });
}
