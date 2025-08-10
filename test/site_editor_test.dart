import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/site_state.dart';
import 'package:stager/tree/concrete_tree.dart';
import 'package:stager/tree/tree.dart';
import 'package:stager/editors/add_site_dialog.dart';
import 'package:stager/editors/stager_navigator.dart';

void main() {
  group('Site Editor functions', () {
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
      expect(siteState.treeData.last.properties.getProperty('name'), 'New Test Site');
    });

    // Test that the "Create New Folder" button is visible when a composite node is selected.
    testWidgets('should show add button when a composite node is selected',
        (WidgetTester tester) async {
      final siteState = SiteState();
      siteState.addSite('Test Site');
      siteState.selectedNode = siteState.treeData.first as LeafNode?;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StagerNavigator(siteState: siteState),
        ),
      ));

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should show add button when a leaf node is selected',
        (WidgetTester tester) async {
      final siteState = SiteState();
      siteState.addSite('Test Site');
      final leaf = ConcreteLeafNode(id: '1', name: 'Leaf');
      (siteState.treeData.first as CompositeNode).addChild(leaf);
      siteState.selectedNode = leaf; // Select the leaf

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StagerNavigator(siteState: siteState),
        ),
      ));

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should add a new composite node when add button is tapped', (WidgetTester tester) async {
      // Arrange
      final siteState = SiteState();
      siteState.addSite('Test Site');
      // Select a composite node to add the new folder to.
      final parentNode = siteState.treeData.first as CompositeNode;
      siteState.selectedNode = parentNode;
      final initialChildCount = parentNode.children.length;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StagerNavigator(siteState: siteState),
        ),
      ));

      // Act
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle(); // Wait for dialog

      // Enter name in the dialog and submit
      await tester.enterText(find.byType(TextField), 'New Folder');
      await tester.tap(find.byType(CheckboxListTile)); //This is the fix
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle(); // Wait for state update

      // Assert
      expect(parentNode.children.length, initialChildCount + 1);
      final newNode = parentNode.children.last;
      expect(newNode.properties.getProperty('name'), 'New Folder');
      expect(newNode.isComposite, isTrue);
    });
  });
}
