/// This file contains widget tests for the TreeView widget.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/editors/tree_view.dart';

void main() {
  group('TreeView Widget Tests', () {
    // Create a mock list of sites for testing.
    final site1 = ConcreteTreeNode(id: 'site1', name: 'Site 1');
    final leaf1 = ConcreteLeafNode(id: 'leaf1', name: 'Leaf 1');
    final comp1 = ConcreteCompositeNode(id: 'comp1', name: 'Composite 1');
    final leaf2 = ConcreteLeafNode(id: 'leaf2', name: 'Leaf 2');
    comp1.addChild(leaf2);
    site1.addChild(leaf1);
    site1.addChild(comp1);

    final mockSites = [site1];

    testWidgets('should render the tree structure correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TreeView(sites: mockSites, onNodeTap: (_) {}),
          ),
        ),
      );

      // Verify that the top-level site and its children are displayed.
      expect(find.text('Site 1'), findsOneWidget);
      expect(find.text('Leaf 1'), findsNothing); // Initially hidden
      expect(find.text('Composite 1'), findsNothing); // Initially hidden

      // Expand the top-level site.
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Verify that the children are now visible.
      expect(find.text('Leaf 1'), findsOneWidget);
      expect(find.text('Composite 1'), findsOneWidget);
    });

    testWidgets('should trigger onNodeTap when a node is tapped', (WidgetTester tester) async {
      LeafNode? tappedNode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TreeView(
              sites: mockSites,
              onNodeTap: (node) {
                tappedNode = node;
              },
            ),
          ),
        ),
      );

      // Expand the tree to make the leaf node visible.
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Tap the leaf node.
      await tester.tap(find.text('Leaf 1'));
      await tester.pump();

      // Verify that the callback was triggered with the correct node.
      expect(tappedNode, isNotNull);
      expect(tappedNode?.properties.get<String>('name'), 'Leaf 1');
    });

    testWidgets('should highlight the selected node', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TreeView(
              sites: mockSites,
              selectedNode: leaf1, // Select the leaf node.
              onNodeTap: (_) {},
            ),
          ),
        ),
      );

      // Expand the tree.
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Find the ListTile for the selected node and check its 'selected' property.
      final leaf1Tile = tester.widget<ListTile>(find.widgetWithText(ListTile, 'Leaf 1'));
      expect(leaf1Tile.selected, isTrue);
    });
  });
}