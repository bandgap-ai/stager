import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/site_state.dart';
import 'package:stager/editors/stager_navigator.dart';
import 'package:stager/editors/tree_view.dart';
import 'package:stager/tree/concrete_tree.dart';
import 'package:stager/tree/tree.dart';
import 'mock_file_handler.dart';

void main() {
  group('StagerNavigator Widget Tests', () {
    late SiteState siteState;
    late MockFileHandler mockFileHandler;

    setUp(() {
      siteState = SiteState();
      mockFileHandler = MockFileHandler();
    });

    // Helper to build the widget
    Future<void> pumpWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            // Pass the state object directly to the constructor
            body: StagerNavigator(
              siteState: siteState,
              fileHandler: mockFileHandler,
            ),
          ),
        ),
      );
    }

    testWidgets('should display the label from SiteState', (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.text('Sites'), findsOneWidget);
    });

    testWidgets('should contain a TreeView', (WidgetTester tester) async {
      await pumpWidget(tester);
      expect(find.byType(TreeView), findsOneWidget);
    });

    testWidgets('should display editor buttons when a node is selected', (WidgetTester tester) async {
      // Arrange: Select a node in the state
      final node = ConcreteLeafNode(id: '1', name: 'Test Node');
      siteState.selectedNode = node;

      /// FIXME! This test is failing because the edit button is currently disabled in the StagerNavigator.
      /// Disregard until the merge is complete!

      // Act
      await pumpWidget(tester);
      await tester.pump(); // Rebuild

      // Assert
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('should not display editor buttons when no node is selected', (WidgetTester tester) async {
      // Arrange: Ensure no node is selected
      siteState.selectedNode = null;

      // Act
      await pumpWidget(tester);
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('tapping delete on a composite node and confirming deletes it', (WidgetTester tester) async {
      // Arrange
      final nodeToDelete = siteState.treeData.first;
      siteState.selectedNode = nodeToDelete;
      final initialSiteCount = siteState.treeData.length;

      await pumpWidget(tester);
      await tester.pump();

      // Act
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle(); // Show the dialog
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle(); // Close the dialog

      // Assert
      expect(siteState.treeData.length, initialSiteCount - 1);
      expect(siteState.treeData.contains(nodeToDelete), isFalse);
    });

    testWidgets('tapping delete on a leaf node and confirming deletes it', (WidgetTester tester) async {
      // Arrange
      final parent = siteState.treeData.first as CompositeNode;
      final nodeToDelete = parent.children.first;
      siteState.selectedNode = nodeToDelete;
      final initialChildCount = parent.children.length;

      await pumpWidget(tester);
      await tester.pump();

      // Act
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle(); // Show the dialog
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle(); // Close the dialog

      // Assert
      expect(parent.children.length, initialChildCount - 1);
      expect(parent.children.contains(nodeToDelete), isFalse);
    });

    testWidgets('tapping delete and canceling does not delete the node', (WidgetTester tester) async {
      // Arrange
      final nodeToTest = siteState.treeData.first;
      siteState.selectedNode = nodeToTest;
      final initialSiteCount = siteState.treeData.length;

      await pumpWidget(tester);
      await tester.pump();

      // Act
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle(); // Show the dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle(); // Close the dialog

      // Assert
      expect(siteState.treeData.length, initialSiteCount);
      expect(siteState.treeData.contains(nodeToTest), isTrue);
    });

    testWidgets('tapping export button calls export on FileHandler', (WidgetTester tester) async {
      // Arrange
      await pumpWidget(tester);

      // Act
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export to File...'));
      await tester.pumpAndSettle();

      // Assert
      expect(mockFileHandler.exportCalled, isTrue);
    });

    testWidgets('tapping import button calls import on FileHandler and adds nodes', (WidgetTester tester) async {
      // Arrange
      final nodesToImport = [ConcreteTreeNode(id: 'imported', name: 'Imported Node')];
      mockFileHandler.nodesToImport = nodesToImport;
      final initialSiteCount = siteState.treeData.length;
      await pumpWidget(tester);

      // Act
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import from File...'));
      await tester.pumpAndSettle();

      // Assert
      expect(siteState.treeData.length, initialSiteCount + 1);
      expect(siteState.treeData.last, nodesToImport.first);
    });
  });
}