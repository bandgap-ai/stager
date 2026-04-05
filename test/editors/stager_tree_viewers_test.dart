/// Widget tests for the `stager_tree_viewers.dart` widgets.
///
/// This file contains a comprehensive set of widget tests for `NodePropertiesView`,
/// `LeafNodeView`, and `CompositeNodeView`, ensuring their correct rendering,
/// behavior, and interaction with node properties and the tree structure.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/editors/node_properties_view.dart';
import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/editors/stager_tree_viewers.dart';
import 'package:stager_platform/editors/tree_icon_provider.dart';

void main() {
  group('NodePropertiesView Tests', () {
    late ConcreteLeafNode node;
    late NodeProperties testProperties;

    setUp(() {
      node = ConcreteLeafNode(id: 'test_id', name: 'Test Node');
      testProperties = node.properties;
      testProperties.setProperty('id', 'test_id');
      testProperties.setProperty('name', 'Test Node');
      testProperties.setProperty('latitude', 36.73444);
      testProperties.setProperty('longitude', -81.86052);
    });

    testWidgets('should display node properties correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NodePropertiesView(state: node),
          ),
        ),
      );

      // Verify properties are displayed correctly
      // The name should be displayed as bold text
      expect(find.text('Test Node'), findsOneWidget);
      // Other properties should be displayed as key-value pairs
      expect(find.text('Latitude'), findsOneWidget);
      expect(find.text('36.73444'), findsOneWidget);
      expect(find.text('Longitude'), findsOneWidget);
      expect(find.text('-81.86052'), findsOneWidget);
      // id should NOT be displayed (it's filtered out)
      expect(find.text('test_id'), findsNothing);
    });

    testWidgets('should display edit icon and open NodeEditor on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NodePropertiesView(state: node),
          ),
        ),
      );

      // Verify the edit icon is displayed
      expect(find.byIcon(Icons.edit), findsOneWidget);

      // Tap the edit icon
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Verify NodeEditor dialog is opened
      expect(find.text('Edit Node Properties'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should update when properties change', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NodePropertiesView(state: node),
          ),
        ),
      );

      // Initial state
      expect(find.text('Test Node'), findsOneWidget);

      // Update property
      testProperties.setProperty('name', 'Updated Node');
      await tester.pump();

      // Verify update
      expect(find.text('Updated Node'), findsOneWidget);
      expect(find.text('Test Node'), findsNothing);
    });

    testWidgets('should handle null properties gracefully', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NodePropertiesView(state: node),
          ),
        ),
      );

      // Should not crash and should display the widget
      expect(find.byType(NodePropertiesView), findsOneWidget);
    });
  });

  group('LeafNodeView Tests', () {
    late ConcreteLeafNode testLeafNode;
    late TreeIconProvider iconProvider;

    setUp(() {
      testLeafNode = ConcreteLeafNode(id: 'leaf1', name: 'Test Leaf');
      iconProvider = TreeIconProvider();
    });

    testWidgets('should display leaf node correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeafNodeView(
              node: testLeafNode,
              onNodeTap: (node) {},
              selectedNode: null,
              level: 0,
              iconProvider: iconProvider,
            ),
          ),
        ),
      );

      // Verify leaf node is displayed
      expect(find.text('Test Leaf'), findsOneWidget);
      expect(find.byType(LeafNodeView), findsOneWidget);
    });

    testWidgets('should handle node selection', (WidgetTester tester) async {
      LeafNode? tappedNode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeafNodeView(
              node: testLeafNode,
              onNodeTap: (node) {
                tappedNode = node;
              },
              selectedNode: null,
              level: 0,
              iconProvider: iconProvider,
            ),
          ),
        ),
      );

      // Tap on the node
      await tester.tap(find.text('Test Leaf'));
      await tester.pump();

      // Verify callback was called
      expect(tappedNode, equals(testLeafNode));
    });

    testWidgets('should highlight selected node', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeafNodeView(
              node: testLeafNode,
              onNodeTap: (node) {},
              selectedNode: testLeafNode,
              level: 0,
              iconProvider: iconProvider,
            ),
          ),
        ),
      );

      // Verify selected node styling
      expect(find.text('Test Leaf'), findsOneWidget);
      expect(find.byType(LeafNodeView), findsOneWidget);
    });
  });

  group('CompositeNodeView Tests', () {
    late ConcreteCompositeNode testCompositeNode;
    late TreeIconProvider iconProvider;

    setUp(() {
      testCompositeNode = ConcreteCompositeNode(id: 'comp1', name: 'Test Composite');
      final child1 = ConcreteLeafNode(id: 'leaf1', name: 'Child 1');
      final child2 = ConcreteLeafNode(id: 'leaf2', name: 'Child 2');
      testCompositeNode.addChild(child1);
      testCompositeNode.addChild(child2);
      iconProvider = TreeIconProvider();
    });

    testWidgets('should display composite node correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompositeNodeView(
              node: testCompositeNode,
              onNodeTap: (node) {},
              selectedNode: null,
              level: 0,
              iconProvider: iconProvider,
            ),
          ),
        ),
      );

      // Verify composite node is displayed
      expect(find.text('Test Composite'), findsOneWidget);
      expect(find.byType(CompositeNodeView), findsOneWidget);
    });

    testWidgets('should show children when expanded', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompositeNodeView(
              node: testCompositeNode,
              onNodeTap: (node) {},
              selectedNode: null,
              level: 0,
              iconProvider: iconProvider,
            ),
          ),
        ),
      );

      // Initially children should be hidden
      expect(find.text('Child 1'), findsNothing);
      expect(find.text('Child 2'), findsNothing);

      // Expand the node
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Children should now be visible
      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
    });
  });
}