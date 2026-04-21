import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/system/selection.dart';
import 'package:stager_platform/editors/stager_navigator_header.dart';
import 'package:stager_platform/editors/tree_view.dart';
import 'package:stager_platform/site_state.dart';
import 'package:stager_platform/system/selection_service.dart';
import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/editors/add_site_dialog.dart';
import 'package:stager_platform/editors/stager_navigator.dart';

void main() {
  group('Site Editor functions', () {

    SelectionService selectionService = SelectionService();

    final Selection<LeafNode> selection = Selection<LeafNode>(ConcreteLeafNode(id: '1', name: 'name'));

    setUp(() {
      selectionService.selection = selection;
    });

    // Test for the "Add Site" button functionality.
    testWidgets('should display the add site button and open a dialog on tap', (WidgetTester tester) async {
      // Arrange
      final siteState = SiteState();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StagerNavigator(siteState: siteState),
        ),
      ));

      // Act
      final addButton = find.byIcon(Icons.add_home_work);
      await tester.tap(addButton);
      await tester.pumpAndSettle(); // Wait for the dialog to appear

      // Assert
      expect(addButton, findsOneWidget);
      expect(find.byType(AddSiteDialog), findsOneWidget);
    });

    // Test that adding a site through the dialog correctly updates the state.
    testWidgets('should call addSite on SiteState when a site is added through the dialog', (WidgetTester tester) async {
      // Arrange
      final siteState = SiteState();
      final initialSiteCount = siteState.treeData.length;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StagerNavigator(siteState: siteState),
        ),
      ));

      // Act
      await tester.tap(find.byIcon(Icons.add_home_work));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.ancestor(
            of: find.text('Site Name:'),
            matching: find.byType(TextField),
          ),
          'New Test Site');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Assert
      expect(siteState.treeData.length, initialSiteCount + 1);
      expect(siteState.treeData.last.properties.get<String>('name'), 'New Test Site');
    });

    // Test that the "Create New Folder" button is visible when a composite node is selected.
    testWidgets('should show add button when a composite node is selected',
        (WidgetTester tester) async {
      final siteState = SiteState();
      TreeNode nodeToTest = siteState.addSite('Test Site');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StagerNavigator(siteState: siteState),
        ),
      ));

      // Find the selected node in the TreeView
      final treeFinder = find.byType(TreeView);
      final nodeViewFinder = find.descendant(
        of: treeFinder,
        matching: find.text(nodeToTest.properties.get<String>('name')),
      );
      expect(nodeViewFinder, findsOneWidget);
      await tester.tap(nodeViewFinder);
      await tester.pumpAndSettle();

      // Find the *correct* add button
      final headerFinder = find.byType(StagerNavigatorHeader);
      final addButtonFinder = find.descendant(of: headerFinder, matching: find.byIcon(Icons.add));
      expect(addButtonFinder, findsOneWidget);
    });

    testWidgets('should add a new composite node when add button is tapped', (WidgetTester tester) async {
      // Arrange
      final siteState = SiteState();
      final parentNode = siteState.addSite('Test Parent Site');
      final initialChildCount = parentNode.children.length;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StagerNavigator(siteState: siteState),
        ),
      ));

      // Find the selected node in the TreeView
      final treeFinder = find.byType(TreeView);
      final nodeViewFinder = find.descendant(
        of: treeFinder,
        matching: find.text(parentNode.properties.get<String>('name')),
      );
      expect(nodeViewFinder, findsOneWidget);
      await tester.tap(nodeViewFinder);
      await tester.pumpAndSettle();

      // Find the *correct* add button
      final headerFinder = find.byType(StagerNavigatorHeader);
      final addButtonFinder = find.descendant(of: headerFinder, matching: find.byIcon(Icons.add));
      // Act
      await tester.tap(addButtonFinder);
      await tester.pumpAndSettle(); // Wait for dialog

      // Enter name in the dialog and submit
      await tester.enterText(find.byType(TextField), 'New Folder');
      await tester.tap(find.byType(CheckboxListTile)); //This is the fix
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle(); // Wait for state update

      // Assert
      expect(parentNode.children.length, initialChildCount + 1);
      final newNode = parentNode.children.last;
      expect(newNode.properties.get<String>('name'), 'New Folder');
      expect(newNode.isComposite, isTrue);
    });
  });
}
