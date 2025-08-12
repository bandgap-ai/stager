/// This file contains widget tests for the AddNodeDialog widget.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/editors/add_node_dialog.dart';
import 'package:stager_platform/site_state.dart';
import 'package:stager_platform/tree/tree_node.dart';

void main() {

  group('AddNodeDialog Widget Tests', () {
    testWidgets('should return entered text when Add is tapped', (WidgetTester tester) async {
      // The key to access the dialog's result.
      final resultKey = GlobalKey<NavigatorState>();

      // Site State needs to be configured with a composite for this test.
      final SiteState state = SiteState();
      TreeNode root = state.addSite('Test Site');
      state.selectedNode = root;

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: resultKey,
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await showDialog<Map<String, dynamic>?>(
                  context: context,
                  builder: (context) => AddNodeDialog(state: root),
                );
                // Verify the form of the results.
                expect(result, isNotNull);
                expect(result!['name'], 'New Test Node');
                expect(result['isGroup'], isFalse);
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Tap the button to show the dialog.
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle(); // Wait for the dialog to appear.

      // Verify the dialog is visible.
      expect(find.byType(AddNodeDialog), findsOneWidget);
      expect(find.text('Create an Object'), findsOneWidget);

      // Enter text into the TextField.
      const nodeName = 'New Test Node';
      await tester.enterText(find.byType(TextField), nodeName);
      await tester.pump();

      // Tap the 'Add' button.
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle(); // Wait for the dialog to close.

      return;
    });

    testWidgets('should create a group when box is checked', (WidgetTester tester) async {
      // The key to access the dialog's result.
      final resultKey = GlobalKey<NavigatorState>();

      // Site State needs to be configured with a composite for this test.
      final SiteState state = SiteState();
      TreeNode root = state.addSite('Test Site');
      state.selectedNode = root;

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: resultKey,
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                final result = await showDialog<Map<String, dynamic>?>(
                  context: context,
                  builder: (context) => AddNodeDialog(state: root),
                );
                // Verify the form of the results.
                expect(result, isNotNull);
                expect(result!['name'], 'New Test Node');
                expect(result['isGroup'], isTrue);
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Tap the button to show the dialog.
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle(); // Wait for the dialog to appear.

      // Verify the dialog is visible.
      expect(find.byType(AddNodeDialog), findsOneWidget);
      expect(find.text('Create an Object'), findsOneWidget);

      // Enter text into the TextField.
      const nodeName = 'New Test Node';
      await tester.enterText(find.byType(TextField), nodeName);
      await tester.pump();

      // Check the group checkbox. Should be false initially.
      Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
      // Switch it to true.
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      // Confirm it.
      checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isTrue);

      // Tap the 'Add' button.
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle(); // Wait for the dialog to close.

      return;
    });

    testWidgets('should return null when Cancel is tapped', (WidgetTester tester) async {

      // Site State needs to be configured with a composite for this test.
      final SiteState state = SiteState();
      TreeNode root = state.addSite('Test Site');
      state.selectedNode = root;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (context) => AddNodeDialog(state: root),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(AddNodeDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AddNodeDialog), findsNothing);

      return;
    });
  });
}
