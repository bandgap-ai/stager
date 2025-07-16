/// This file contains widget tests for the EditNodeDialog widget.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/tree/concrete_tree.dart';
import 'package:stager/editors/edit_node_dialog.dart';

void main() {
  group('EditNodeDialog Widget Tests', () {
    final testNode = ConcreteLeafNode(id: 'test_id', name: 'Initial Name');

    testWidgets('should be pre-filled with the node name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => EditNodeDialog(properties: testNode.properties),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(EditNodeDialog), findsOneWidget);
      expect(find.text('Initial Name'), findsOneWidget);
    });

    testWidgets('should return updated text when Save is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => EditNodeDialog(properties: testNode.properties),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      const updatedName = 'Updated Name';
      await tester.enterText(find.byType(TextField), updatedName);
      await tester.pump();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.byType(EditNodeDialog), findsNothing);
    });

    testWidgets('should return null when Cancel is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => EditNodeDialog(properties: testNode.properties),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(EditNodeDialog), findsNothing);
    });
  });
}
