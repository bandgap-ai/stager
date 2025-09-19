import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/editors/selection.dart';
import 'package:stager_platform/editors/stager_pin.dart';
import 'package:stager_platform/site_state.dart';
import 'package:stager_platform/editors/stager_navigator.dart';
import 'package:stager_platform/editors/tree_view.dart';
import 'package:stager_platform/tree/concrete_tree.dart';
import 'package:stager_platform/tree/tree.dart';
import 'mock_file_handler.dart';
import 'mock_selection_observer.dart';
import 'mock_site_controls.dart';

void main() {
  group('StagerNavigator Widget Tests (Header mostly)', () {
    late SiteState siteState;
    late MockFileHandler mockFileHandler;
    late MockSiteControls mockSiteControls;
    late Selection<LeafNode> selection;

    setUp(() {
      siteState = SiteState();
      selection = Selection<LeafNode>();
      mockFileHandler = MockFileHandler();
      mockSiteControls = MockSiteControls();
    });

    // Helper to build the widget
    Future<void> pumpWidget(WidgetTester tester, {StagerPin? pin}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            // Pass the state object directly to the constructor
            body: StagerNavigator(
              siteState: siteState,
              selection: selection,
              fileHandler: mockFileHandler,
              siteControls: mockSiteControls,
              pin: pin,
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
      await tester.pump();
      expect(find.byType(TreeView), findsOneWidget);
    });

    testWidgets('should display editor button when a node is selected', (WidgetTester tester) async {

      // Add a node
      final node = ConcreteLeafNode(id: '1', name: 'Test Node');
      siteState.selectedNode = node;
      final TreeNode parent = siteState.addSite("Test Site");
      parent.addChild(node);

      // Register an observer on the selection so we can check it
      MockSelectionObserver<LeafNode> selectionObserver
          = MockSelectionObserver<LeafNode>();
      selection.attach(selectionObserver);

      // Act
      await pumpWidget(tester);
      await tester.pump(); // Rebuild

      // Find the tree view
      final treeViewFinder = find.byType(TreeView);
      expect(treeViewFinder, findsOneWidget);
      // The Tree View displaces the full list of sites in the site state in a
      // ListView. Select the first site from the list, which is named
      // "Test Site," and when it expands select the "Test Node" node.
      final siteFinder = find.text('Test Site');
      expect(find.text('Test Site'), findsOneWidget);
      await tester.tap(siteFinder);
      await tester.pumpAndSettle();

      // There's a subtly here: Two Icons.edit will appear on the screen since
      // clicking the tree view sends the selected node to the property editor.
      // Thus, we need to find the Icon *inside* the TreeView.
      final navigatorFinder = find.byType(StagerNavigator);
      expect(navigatorFinder, findsOneWidget);
      await tester.pump();
      // Find the icon within the StagerNavigatorHeader
      final iconFinder = find.descendant(
        of: navigatorFinder,
        matching: find.byIcon(Icons.edit),
      );
      expect(iconFinder, findsOneWidget);
      await tester.tap(iconFinder);
      await tester.pumpAndSettle();

      // Assert the mock was called
      expect(mockSiteControls.buildEditNodeCalled, isTrue);
      mockSiteControls.reset();

      // Assert the selection was updated
      expect(selectionObserver.updated, isTrue);
      expect(selection.value == parent, isTrue);

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

    testWidgets('should display pin when provided and call onPinChanged on tap', (WidgetTester tester) async {
      // Arrange
      bool callbackCalled = false;
      final StagerPin pin = StagerPin(
        initialPinState: false,
        onPinChanged: (bool isPinned) {
          callbackCalled = true;
        },
      );

      // Act
      await pumpWidget(tester, pin: pin);
      await tester.pump();

      // Assert the widget is found
      final pinFinder = find.byType(StagerPin);
      expect(pinFinder, findsOneWidget);

      // Tap the pin
      await tester.tap(pinFinder);
      await tester.pump();

      // Assert callback is called
      expect(callbackCalled, isTrue);
    });

    testWidgets('tapping delete on a composite node and confirming it is deleted', (WidgetTester tester) async {
      // Arrange
      final nodeToDelete = siteState.treeData.first;
      final initialSiteCount = siteState.treeData.length;

      await pumpWidget(tester);
      await tester.pump();

      // Find the selected node in the TreeView
      final treeFinder = find.byType(TreeView);
      final nodeViewFinder = find.descendant(
        of: treeFinder,
        matching: find.text(nodeToDelete.properties.getProperty('name') as String),
      );
      expect(nodeViewFinder, findsOneWidget);
      await tester.tap(nodeViewFinder);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle(); // Show the dialog
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle(); // Close the dialog

      // Assert
      expect(siteState.treeData.length, initialSiteCount - 1);
      expect(siteState.treeData.contains(nodeToDelete), isFalse);
    });

    testWidgets('tapping delete on a leaf node and confirming it is deleted', (WidgetTester tester) async {

      // The funny thing about this test is that it doesn't actually check a
      // leaf node. It checks a mid-tier composite node instead... Gemini, you
      // so crazy...

      // Note: debugDumpApp() is your friend.

      // Set a more realistic screen size
      // Example: A common phone portrait size
      // This test won't run at the default size because it obscures the tree
      // view.
      const Size realisticPhoneSize = Size(1080 / 2, 1920 / 2); // Logical pixels
      const double pixelRatio = 2.0;
      tester.view.physicalSize = Size(realisticPhoneSize.width * pixelRatio, realisticPhoneSize.height * pixelRatio);
      tester.view.devicePixelRatio = pixelRatio;
      await tester.pumpAndSettle();

      // Arrange
      final parent = siteState.treeData.first as CompositeNode;
      final nodeToDelete = parent.children.first;
      final initialChildCount = parent.children.length;

      await pumpWidget(tester);
      await tester.pump();

      // Click through the parent to expand the list of children. Find the tree:
      final treeFinder = find.byType(TreeView);
      expect(treeFinder, findsOneWidget);
      await tester.ensureVisible(treeFinder);
      await tester.tap(treeFinder);
      await tester.pumpAndSettle();

      // Find the parent in the TreeView
      final parentFinder = find.descendant( of: treeFinder,
          matching: find.text(parent.properties.getProperty('name') as String));
      // Tap the parent to expand the list of children
      await tester.ensureVisible(parentFinder);
      await tester.tap(parentFinder);
      await tester.pumpAndSettle();
      expect(parentFinder, findsOneWidget);

      // Find the selected node in the TreeView. Note that even though it
      // is a "child" of parentFinder in the data, it is not a child of
      // the actual widget since that widget is a member of a ListView. All the
      // items in the list view are children of the TreeView.
      final nodeFinder = find.descendant(
          of: treeFinder,
          matching: find.text(nodeToDelete.properties.getProperty('name') as String));
      await tester.ensureVisible(nodeFinder);
      await tester.tap(nodeFinder);
      await tester.pumpAndSettle();
      expect(nodeFinder, findsOneWidget);

      // Act
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle(); // Show the dialog
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle(); // Close the dialog

      // Assert
      expect(parent.children.contains(nodeToDelete), isFalse);
      expect(parent.children.length, initialChildCount - 1);
      expect(nodeFinder, findsNothing);
    });

    testWidgets('tapping delete and canceling does not delete the node', (WidgetTester tester) async {
      // Arrange
      final nodeToTest = siteState.treeData.first;
      final initialSiteCount = siteState.treeData.length;

      await pumpWidget(tester);
      await tester.pump();

      // Find the selected node in the TreeView
      final treeFinder = find.byType(TreeView);
      final nodeViewFinder = find.descendant(
        of: treeFinder,
        matching: find.text(nodeToTest.properties.getProperty('name') as String),
      );
      expect(nodeViewFinder, findsOneWidget);
      await tester.tap(nodeViewFinder);
      await tester.pumpAndSettle();

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
