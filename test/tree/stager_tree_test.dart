/// This file contains unit tests for the Stager tree data structure
/// defined in `lib/stager/tree.dart` and its concrete implementation
/// in `lib/stager/concrete_tree.dart`.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/system/stager_context.dart';
import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/system/point.dart';
import 'package:uuid/uuid.dart';

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

  group('LeafNode', () {
    test('ConcreteLeafNode can load properties from a map', () {
      UuidValue id = Uuid().v7obj();
      final leaf = ConcreteLeafNode(name: 'Leaf 1');
      TestLeafNodeObserver observer = TestLeafNodeObserver();
      leaf.attach(observer);
      expect(observer.lastUpdatedNode, isNull);
      // Make some new property values
      Map<String, Object> mapInput = {
        'id': id,
        'name': 'Updated Name',
        'value': TypedValue<int>(456).toTuple(),
        'is_active': TypedValue<bool>(false).toTuple(),
        'position': Point(coords: [-77.9687646357412,
          38.98951052421746]).toMap()
      };

      // Make sure no properties are set in the node to start.
      expect(leaf.hasProperties,isFalse);
      // Set them.
      leaf.fromMap(mapInput);

      // Get and check the properties. The id should be unchanged:
      expect(leaf.id, id);
      expect(leaf.name, 'Updated Name');
      expect(leaf.position, Point(coords: [-77.9687646357412,
        38.98951052421746]));
      NodeProperties properties = leaf.properties;
      expect(properties.get<int>('value'), 456);
      expect(properties.get<bool>('is_active'), false);
      // There should now be 6 properties - type is added for reference
      expect(leaf.toMap().length, 6);
      // Ensure that observers were notified the state changed.
      expect(observer.lastUpdatedNode, isNotNull);
      // Make sure hasProperties behaves as expected.
      expect(leaf.hasProperties,isTrue);
      expect(leaf.hasProperty('value'),isTrue);
    });

    test('ConcreteLeafNode initializes correctly', () {
      final leaf = ConcreteLeafNode(name: 'Leaf 1');
      expect(Uuid.isValidUUID(fromString: leaf.id.toString()), true);
      expect(leaf.name, 'Leaf 1');
      expect(leaf.position == Point(coords: [-77.96876463574121, 38.98951052421746]), true);
      expect(leaf.hasParent(), isFalse);
      expect(leaf.hasNext(), isFalse);
      expect(leaf.hasPrevious(), isFalse);
      expect(() => leaf.parent, throwsA(isA<NodeStructureException>().having(
          (e) => e.toString(), 'toString()', contains('NodeStructureException: '
          'parent node is not available.'),
      )));
      expect(() => leaf.next, throwsA(isA<NodeStructureException>().having(
            (e) => e.toString(), 'toString()', contains('NodeStructureException: '
          'next node is not available.'),
      )));
      expect(() => leaf.previous, throwsA(isA<NodeStructureException>().having(
            (e) => e.toString(), 'toString()', contains('NodeStructureException: '
          'previous node is not available.'),
      )));
      expect(leaf.isComposite, isFalse);
    });

    test('ConcreteLeafNode sets parent, next, and previous correctly', () {
      final leaf1 = ConcreteLeafNode(name: 'Leaf 1');
      final leaf2 = ConcreteLeafNode(name: 'Leaf 2');
      final leaf3 = ConcreteLeafNode(name: 'Leaf 3');

      leaf2.setParent(leaf1);
      leaf2.setNext(leaf3);
      leaf2.setPrevious(leaf1);

      expect(leaf2.parent, leaf1);
      expect(leaf2.next, leaf3);
      expect(leaf2.previous, leaf1);

      // Reset the node's relative
      leaf2.resetRelatives();
      expect(() => leaf2.parent, throwsA(isA<NodeStructureException>().having(
            (e) => e.toString(), 'toString()', contains('NodeStructureException: '
          'parent node is not available.'),
      )));
      expect(() => leaf2.next, throwsA(isA<NodeStructureException>().having(
            (e) => e.toString(), 'toString()', contains('NodeStructureException: '
          'next node is not available.'),
      )));
      expect(() => leaf2.previous, throwsA(isA<NodeStructureException>().having(
            (e) => e.toString(), 'toString()', contains('NodeStructureException: '
          'previous node is not available.'),
      )));
    });

    test('ConcreteLeafNode notifies observers on structural changes', () {
      final leaf = ConcreteLeafNode(name: 'Leaf 1');
      final observer = TestLeafNodeObserver();
      leaf.attach(observer);

      leaf.setParent(ConcreteLeafNode(name: 'Parent'));
      expect(observer.lastUpdatedNode, leaf);

      observer.lastUpdatedNode = null; // Reset for next assertion
      leaf.setNext(ConcreteLeafNode(name: 'Next'));
      expect(observer.lastUpdatedNode, leaf);

      observer.lastUpdatedNode = null; // Reset for next assertion
      leaf.setPrevious(ConcreteLeafNode(name: 'Previous'));
      expect(observer.lastUpdatedNode, leaf);
    });

    test('ConcreteLeafNode can be visited', () {
      final leaf = ConcreteLeafNode(name: 'Leaf 1');
      final visitor = MockNodeVisitor();

      leaf.accept(visitor);
      expect(visitor.hasVisited, true);
    });

    test('ConcreteLeafNode and LeafNode builders work', () {
      Map<String, Object> map = {
        'name': 'Leaf'
      };
      // Add a couple properties to the map. They should appear as node
      // properties.
      map['name'] = "Tree";
      map['health'] = TypedValue<String>("Good").toTuple();
      map['age'] = TypedValue<int>(10).toTuple();
      final tree = buildConcreteLeafNode(StagerContext(map));
      expect(tree.name, 'Tree');
      expect(tree.runtimeType, ConcreteLeafNode);
      expect(tree.properties.get<String>('health'), 'Good');
      expect(tree.properties.get<int>('age'), 10);
    });

    test('ConcreteLeafNode will complain for incorrect typed values', () {
      Map<String, Object> map = {
        'name': 'Leaf'
      };
      // Check a basic leaf node. This should be a concrete leaf node.
      final leaf = buildConcreteLeafNode(StagerContext(map));
      expect(leaf.name, 'Leaf');
      expect(leaf.runtimeType, ConcreteLeafNode);
      // Add a couple properties to the map. They should appear as node
      // properties.
      map['name'] = "Tree";
      // The following value is not allowed because the maps accepted by
      // ConcreteLeafNode are expected to be serialized to its tuple form.
      map['health'] = TypedValue<String>("Good");
      expect(
            () => buildConcreteLeafNode(StagerContext(map)),
        throwsA(
          isA<NodePropertyException>().having(
                (e) => e.toString(),
            'toString()',
            'NodePropertyException: Property "health" with type '
                'TypedValue<String> is not a TypedValue tuple (List<Object>) but '
                'must be since it is a generic property. If this property was '
                'created programmatically, ensure that TypedValue.toTuple() was '
                'called.',
          ),
        ),);
    });
  });

  group('CompositeNode', () {
    test('ConcreteCompositeNode initializes correctly', () {
      final composite = ConcreteCompositeNode(name: 'Composite 1');
      expect(Uuid.isValidUUID(fromString: composite.id.toString()), true);
      expect(composite.name, 'Composite 1');
      expect(composite.isComposite, isTrue);
      expect(composite.children, isEmpty);
    });

    test('ConcreteCompositeNode builder works', () {
      Map<String, Object> map = {
        'name': 'Branch'
      };
      // Check a composite node. This should be a concrete composite node.
      final node = buildConcreteCompositeNode(StagerContext(map));
      expect(node.name, 'Branch');
      expect(node.runtimeType, ConcreteCompositeNode);
    });

    test('ConcreteCompositeNode adds and removes children correctly', () {
      final composite = ConcreteCompositeNode(name: 'Composite 1');
      final leaf1 = ConcreteLeafNode(name: 'Leaf 1');
      final leaf2 = ConcreteLeafNode(name: 'Leaf 2');
      final nestedComposite = ConcreteCompositeNode(name: 'Nested Composite');

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
      expect(leaf1.hasParent(), isFalse);
      expect(leaf1.hasNext(), isFalse);
      expect(leaf1.hasPrevious(), isFalse);
      expect(() => leaf1.parent, throwsA(isA<NodeStructureException>().having(
            (e) => e.toString(), 'toString()', contains('NodeStructureException: '
          'parent node is not available.'),
      )));
    });

    test('ConcreteCompositeNode notifies observers on child changes', () {
      final composite = ConcreteCompositeNode(name: 'Composite 1');
      final observer = TestLeafNodeObserver();
      composite.attach(observer);

      final leaf = ConcreteLeafNode(name: 'Leaf 1');
      composite.addChild(leaf);
      expect(observer.lastUpdatedNode, composite);

      observer.lastUpdatedNode = null; // Reset for next assertion
      composite.removeChild(leaf);
      expect(observer.lastUpdatedNode, composite);
    });

    test('ConcreteCompositeNode attach/detach observers to children', () {
      final rootComposite = ConcreteCompositeNode(name: 'Root Composite');
      final childLeaf = ConcreteLeafNode(name: 'Child Leaf');
      final nestedComposite = ConcreteCompositeNode(name: 'Nested Composite');
      final nestedChildLeaf = ConcreteLeafNode(name: 'Nested Child Leaf');

      rootComposite.addChild(childLeaf);
      rootComposite.addChild(nestedComposite);
      nestedComposite.addChild(nestedChildLeaf);

      final observer = TestLeafNodeObserver();
      rootComposite.attach(observer);

      // Verify that changes in children notify the observer attached to the root composite
      childLeaf.setNext(ConcreteLeafNode(name: 'Dummy'));
      expect(observer.lastUpdatedNode, childLeaf);

      observer.lastUpdatedNode = null;
      nestedChildLeaf.setPrevious(ConcreteLeafNode(name: 'Dummy2'));
      expect(observer.lastUpdatedNode, nestedChildLeaf);

      // Detach observer from root and verify no more notifications from children
      rootComposite.detach(observer);
      observer.lastUpdatedNode = null;
      childLeaf.setNext(ConcreteLeafNode(name: 'Dummy3'));
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
      root = ConcreteTreeNode(name: 'root');
      comp1 = ConcreteCompositeNode(name: 'comp1');
      leaf1 = ConcreteLeafNode(name: 'leaf1');
      leaf2 = ConcreteLeafNode(name: 'leaf2');
      comp2 = ConcreteCompositeNode(name: 'comp2');
      leaf3 = ConcreteLeafNode(name: 'leaf3');
      leaf4 = ConcreteLeafNode(name: 'leaf4');
      final comp3 = ConcreteCompositeNode(name: 'comp3');
      final comp4 = ConcreteCompositeNode(name: 'comp4');
      final leaf5 = ConcreteLeafNode(name: 'leaf5');

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

    test('ConcreteTreeNode builder works', () {
      Map<String, Object> map = {
        'name': 'Tree'
      };
      // Check a composite node. This should be a concrete composite node.
      final node = buildConcreteTreeNode(StagerContext(map));
      expect(node.name, 'Tree');
      expect(node.runtimeType, ConcreteTreeNode);
    });

    test('createIterator defaults to depth-first', () {
      final iterator = root.createIterator();
      final visitedNodes = <String>[];
      while (iterator.moveNext()) {
        visitedNodes.add(iterator.current.name);
      }
      expect(visitedNodes, ['root', 'comp1', 'leaf1', 'leaf2', 'comp2', 'leaf3', 'leaf4', 'comp3', 'comp4', 'leaf5']);
    });

    test('depthFirstIterator traverses correctly', () {
      final iterator = root.depthFirstIterator;
      final visitedNodes = <String>[];
      while (iterator.moveNext()) {
        visitedNodes.add(iterator.current.name);
      }
      expect(visitedNodes, ['root', 'comp1', 'leaf1', 'leaf2', 'comp2', 'leaf3', 'leaf4', 'comp3', 'comp4', 'leaf5']);
    });

    test('breadthFirstIterator traverses correctly', () {
      final iterator = root.breadthFirstIterator;
      final visitedNodes = <String>[];
      while (iterator.moveNext()) {
        visitedNodes.add(iterator.current.name);
      }
      expect(visitedNodes, ['root', 'comp1', 'leaf4', 'comp3', 'leaf1', 'leaf2', 'comp2', 'comp4', 'leaf3', 'leaf5']);
    });

    test('find method works correctly', () {
      // Test case 1: Find all leaf nodes (nodes that are not composite)
      final allLeafNodes = root.find((node) => !node.isComposite);
      expect(allLeafNodes, hasLength(5));
      expect(allLeafNodes.map((n) => n.name), containsAll(['leaf1', 'leaf2', 'leaf3', 'leaf4', 'leaf5']));

      // Test case 2: Find nodes with a specific name containing 'comp'
      final namedNodes = root.find((node) => (node.name).contains('comp'));
      expect(namedNodes, hasLength(4));
      expect(namedNodes.map((n) => n.name), containsAll(['comp1', 'comp2', 'comp3', 'comp4']));

      // Test case 3: Find a specific node by its ID
      final specificNode = root.find((node) => node.name == 'leaf3');
      expect(specificNode, hasLength(1));
      expect(specificNode.first.name, 'leaf3');

      // Test case 4: Find nodes that do not exist
      final nonExistentNode = root.find((node) => node.name == 'non_existent');
      expect(nonExistentNode, isEmpty);
    });
  });
}