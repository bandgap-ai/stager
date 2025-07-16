/// Tests for the [AddPropertyDialog] widget.
///
/// This file contains a series of widget tests for the [AddPropertyDialog],
/// ensuring its correct rendering, input handling, and the return of new
/// property data.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/editors/add_property_dialog.dart';

void main() {
  group('AddPropertyDialog Tests', () {
    testWidgets('should display title and input fields', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const AddPropertyDialog();
                  },
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Add New Property'), findsOneWidget);
      expect(find.text('Property Name:'), findsOneWidget);
      expect(find.text('Property Value:'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('should return entered property on Add', (WidgetTester tester) async {
      Map<String, dynamic>? result;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (context) {
                    return const AddPropertyDialog();
                  },
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Property Name:'), 'newKey');
      await tester.enterText(find.widgetWithText(TextField, 'Property Value:'), 'newValue');

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!['newKey'], 'newValue');
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should return null on Cancel', (WidgetTester tester) async {
      Map<String, dynamic>? result;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (context) {
                    return const AddPropertyDialog();
                  },
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
