/// This file contains unit tests for the Stager tree data structure
/// defined in `lib/stager/tree.dart` and its concrete implementation
/// in `lib/stager/concrete_tree.dart`.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/tree/concrete_tree.dart';

import 'mock_node_visitor.dart';

/// A simple observer implementation for testing [LeafNode] updates.
class TestLeafNodeObserver implements LeafNodeObserver {
  /// Stores the last [LeafNode] that triggered an update.
  LeafNode? lastUpdatedNode;

  @override
  void update(LeafNode node) {
    lastUpdatedNode = node;
  }
}

class TestNodePropertiesObserver implements NodePropertiesObserver {
  /// Stores the last [NodeProperties] that triggered an an update.
  NodeProperties? lastUpdatedProperties;

  @override
  void update(NodeProperties properties) {
    lastUpdatedProperties = properties;
  }
}

void main() {
  group('NodeProperties', () {
    test('ConcreteNodeProperties can set and get properties', () {
      final properties = ConcreteNodeProperties();
      properties.setProperty('name', 'Test Name');
      properties.setProperty('value', 123);
      properties.setProperty('is_active', true);

      expect(properties.getProperty('name'), 'Test Name');
      expect(properties.getProperty('value'), 123);
      expect(properties.getProperty('is_active'), true);
      expect(properties.getProperty('non_existent'), isNull);
    });

    test('ConcreteNodeProperties handles null values', () {
      final properties = ConcreteNodeProperties();
      properties.setProperty('nullable_value', null);
      expect(properties.getProperty('nullable_value'), isNull);
    });
  });

  group('LeafNode', () {

    test('ConcreteLeafNode can load properties from a map', () {
      String id = 'l1';
      final leaf = ConcreteLeafNode(id: id, name: 'Leaf 1');
      TestLeafNodeObserver observer = TestLeafNodeObserver();
      leaf.attach(observer);
      expect(observer.lastUpdatedNode, isNull);

      // Make some new property values
      Map<String, dynamic> mapInput = {
        'name': 'Updated Name',
        'value': 456,
        'is_active': false,
      };

      // Set them.
      leaf.loadPropertiesFromMap(mapInput);

      // Get and check the properties. The id should be unchanged:
      expect(leaf.properties.getProperty('id'), id);
      expect(leaf.properties.getProperty('name'), 'Updated Name');
      expect(leaf.properties.getProperty('value'), 456);
      expect(leaf.properties.getProperty('is_active'), false);
      // There should now be 4 properties
      expect(leaf.properties.map.length, 4);
      // Ensure that observers were notified the state changed.
      expect(observer.lastUpdatedNode, isNotNull);

    });

    test('ConcreteLeafNode initializes correctly', () {
      final leaf = ConcreteLeafNode(id: 'l1', name: 'Leaf 1');
      expect(leaf.properties.getProperty('id'), 'l1');
      expect(leaf.properties.getProperty('name'), 'Leaf 1');
      expect(leaf.parent, isNull);
      expect(leaf.next, isNull);
      expect(leaf.previous, isNull);
      expect(leaf.isComposite, isFalse);
      expect(leaf.properties, isA<NodeProperties>());
    });

    test('ConcreteLeafNode sets parent, next, and previous correctly', () {
      final leaf1 = ConcreteLeafNode(id: 'l1', name: 'Leaf 1');
      final leaf2 = ConcreteLeafNode(id: 'l2', name: 'Leaf 2');
      final leaf3 = ConcreteLeafNode(id: 'l3', name: 'Leaf 3');

      leaf2.setParent(leaf1);
      leaf2.setNext(leaf3);
      leaf2.setPrevious(leaf1);

      expect(leaf2.parent, leaf1);
      expect(leaf2.next, leaf3);
      expect(leaf2.previous, leaf1);
    });

    test('ConcreteLeafNode notifies observers on structural changes', () {
      final leaf = ConcreteLeafNode(id: 'l1', name: 'Leaf 1');
      final observer = TestLeafNodeObserver();
      leaf.attach(observer);

      leaf.setParent(ConcreteLeafNode(id: 'p1', name: 'Parent'));
      expect(observer.lastUpdatedNode, leaf);

      observer.lastUpdatedNode = null; // Reset for next assertion
      leaf.setNext(ConcreteLeafNode(id: 'n1', name: 'Next'));
      expect(observer.lastUpdatedNode, leaf);

      observer.lastUpdatedNode = null; // Reset for next assertion
      leaf.setPrevious(ConcreteLeafNode(id: 'pr1', name: 'Previous'));
      expect(observer.lastUpdatedNode, leaf);
    });

    test('ConcreteLeafNode can be visited', () {
      final leaf = ConcreteLeafNode(id: 'l1', name: 'Leaf 1');
      final visitor = MockNodeVisitor();

      leaf.accept(visitor);
      expect(visitor.hasVisited, true);
    });
  });

  group('CompositeNode', () {
    test('ConcreteCompositeNode initializes correctly', () {
      final composite = ConcreteCompositeNode(id: 'c1', name: 'Composite 1');
      expect(composite.properties.getProperty('id'), 'c1');
      expect(composite.properties.getProperty('name'), 'Composite 1');
      expect(composite.isComposite, isTrue);
      expect(composite.children, isEmpty);
    });

    test('ConcreteCompositeNode adds and removes children correctly', () {
      final composite = ConcreteCompositeNode(id: 'c1', name: 'Composite 1');
      final leaf1 = ConcreteLeafNode(id: 'l1', name: 'Leaf 1');
      final leaf2 = ConcreteLeafNode(id: 'l2', name: 'Leaf 2');
      final nestedComposite = ConcreteCompositeNode(id: 'nc1', name: 'Nested Composite');

      composite.addChild(leaf1);
      composite.addChild(leaf2);
      composite.addChild(nestedComposite);

      expect(composite.children, hasLength(3));
      expect(composite.children, contains(leaf1));
      expect(composite.children, contains(leaf2));
      expect(composite.children, contains(nestedComposite));
      expect(leaf1.parent, composite);
      expect(leaf2.parent, composite);
      expect(nestedComposite.parent, composite);

      composite.removeChild(leaf1);
      expect(composite.children, hasLength(2));
      expect(composite.children, isNot(contains(leaf1)));
      expect(leaf1.parent, isNull);
    });

    test('ConcreteCompositeNode notifies observers on child changes', () {
      final composite = ConcreteCompositeNode(id: 'c1', name: 'Composite 1');
      final observer = TestLeafNodeObserver();
      composite.attach(observer);

      final leaf = ConcreteLeafNode(id: 'l1', name: 'Leaf 1');
      composite.addChild(leaf);
      expect(observer.lastUpdatedNode, composite);

      observer.lastUpdatedNode = null; // Reset for next assertion
      composite.removeChild(leaf);
      expect(observer.lastUpdatedNode, composite);
    });

    test('ConcreteCompositeNode attach/detach observers to children', () {
      final rootComposite = ConcreteCompositeNode(id: 'root', name: 'Root Composite');
      final childLeaf = ConcreteLeafNode(id: 'child1', name: 'Child Leaf');
      final nestedComposite = ConcreteCompositeNode(id: 'nested', name: 'Nested Composite');
      final nestedChildLeaf = ConcreteLeafNode(id: 'nestedChild1', name: 'Nested Child Leaf');

      rootComposite.addChild(childLeaf);
      rootComposite.addChild(nestedComposite);
      nestedComposite.addChild(nestedChildLeaf);

      final observer = TestLeafNodeObserver();
      rootComposite.attach(observer);

      // Verify that changes in children notify the observer attached to the root composite
      childLeaf.setNext(ConcreteLeafNode(id: 'dummy', name: 'Dummy'));
      expect(observer.lastUpdatedNode, childLeaf);

      observer.lastUpdatedNode = null;
      nestedChildLeaf.setPrevious(ConcreteLeafNode(id: 'dummy2', name: 'Dummy2'));
      expect(observer.lastUpdatedNode, nestedChildLeaf);

      // Detach observer from root and verify no more notifications from children
      rootComposite.detach(observer);
      observer.lastUpdatedNode = null;
      childLeaf.setNext(ConcreteLeafNode(id: 'dummy3', name: 'Dummy3'));
      expect(observer.lastUpdatedNode, isNull);
    });
  });

  group('TreeNode', () {
    late ConcreteTreeNode root;
    late ConcreteLeafNode leaf1, leaf2, leaf3, leaf4;
    late ConcreteCompositeNode comp1, comp2;

    setUp(() {
      // Set up a sample tree structure for traversal and search tests.
      // Root
      //  ├── Composite 1 (comp1)
      //  │    ├── Leaf 1 (leaf1)
      //  │    ├── Leaf 2 (leaf2)
      //  │    └── Composite 2 (comp2)
      //  │         └── Leaf 3 (leaf3)
      //  └── Leaf 4 (leaf4)
      //  └── Composite 3 (comp3)
      //       └── Composite 4 (comp4)
      //            └── Leaf 5 (leaf5)
      root = ConcreteTreeNode(id: 'root', name: 'Root');
      comp1 = ConcreteCompositeNode(id: 'comp1', name: 'Composite 1');
      leaf1 = ConcreteLeafNode(id: 'leaf1', name: 'Leaf 1');
      leaf2 = ConcreteLeafNode(id: 'leaf2', name: 'Leaf 2');
      comp2 = ConcreteCompositeNode(id: 'comp2', name: 'Composite 2');
      leaf3 = ConcreteLeafNode(id: 'leaf3', name: 'Leaf 3');
      leaf4 = ConcreteLeafNode(id: 'leaf4', name: 'Leaf 4');
      final comp3 = ConcreteCompositeNode(id: 'comp3', name: 'Composite 3');
      final comp4 = ConcreteCompositeNode(id: 'comp4', name: 'Composite 4');
      final leaf5 = ConcreteLeafNode(id: 'leaf5', name: 'Leaf 5');

      root.addChild(comp1);
      root.addChild(leaf4);
      root.addChild(comp3);

      comp1.addChild(leaf1);
      comp1.addChild(leaf2);
      comp1.addChild(comp2);

      comp2.addChild(leaf3);

      comp3.addChild(comp4);
      comp4.addChild(leaf5);
    });

    test('createIterator defaults to depth-first', () {
      final iterator = root.createIterator();
      final visitedNodes = <String>[];
      while (iterator.moveNext()) {
        visitedNodes.add(iterator.current.properties.getProperty('id') as String);
      }
      expect(visitedNodes, ['root', 'comp1', 'leaf1', 'leaf2', 'comp2', 'leaf3', 'leaf4', 'comp3', 'comp4', 'leaf5']);
    });

    test('depthFirstIterator traverses correctly', () {
      final iterator = root.depthFirstIterator;
      final visitedNodes = <String>[];
      while (iterator.moveNext()) {
        visitedNodes.add(iterator.current.properties.getProperty('id') as String);
      }
      expect(visitedNodes, ['root', 'comp1', 'leaf1', 'leaf2', 'comp2', 'leaf3', 'leaf4', 'comp3', 'comp4', 'leaf5']);
    });

    test('breadthFirstIterator traverses correctly', () {
      final iterator = root.breadthFirstIterator;
      final visitedNodes = <String>[];
      while (iterator.moveNext()) {
        visitedNodes.add(iterator.current.properties.getProperty('id') as String);
      }
      expect(visitedNodes, ['root', 'comp1', 'leaf4', 'comp3', 'leaf1', 'leaf2', 'comp2', 'comp4', 'leaf3', 'leaf5']);
    });

    test('find method works correctly', () {
      // Test case 1: Find all leaf nodes (nodes that are not composite)
      final allLeafNodes = root.find((node) => !node.isComposite);
      expect(allLeafNodes, hasLength(5));
      expect(allLeafNodes.map((n) => n.properties.getProperty('id')), containsAll(['leaf1', 'leaf2', 'leaf3', 'leaf4', 'leaf5']));

      // Test case 2: Find nodes with a specific name containing 'Composite'
      final namedNodes = root.find((node) => (node.properties.getProperty('name') as String).contains('Composite'));
      expect(namedNodes, hasLength(4));
      expect(namedNodes.map((n) => n.properties.getProperty('id')), containsAll(['comp1', 'comp2', 'comp3', 'comp4']));

      // Test case 3: Find a specific node by its ID
      final specificNode = root.find((node) => node.properties.getProperty('id') == 'leaf3');
      expect(specificNode, hasLength(1));
      expect(specificNode.first.properties.getProperty('id'), 'leaf3');

      // Test case 4: Find nodes that do not exist
      final nonExistentNode = root.find((node) => node.properties.getProperty('id') == 'non_existent');
      expect(nonExistentNode, isEmpty);
    });
  });
}