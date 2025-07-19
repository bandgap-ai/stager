// test/basic_widget_factory_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/editors/basic_widget_factory.dart';

// Helper function to pump a widget tree with a Scaffold and MaterialApp
Future<void> pumpBaseWidget(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  // Test group for BasicWidgetFactory
  group('BasicWidgetFactory', () {
    late BasicWidgetFactory widgetFactory;

    setUp(() {
      widgetFactory = const BasicWidgetFactory();
    });

    testWidgets('infoLabel returns a widget from buildInfoLabel', (
        WidgetTester tester) async {
      String info = 'Text info';
      // Pump a MaterialApp to provide a valid BuildContext with theme, etc.
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            // Call the factory method
            final Widget resultWidget = widgetFactory.infoLabel(context,info);

            // Basic check: Ensure it returns some Widget
            expect(resultWidget, isA<Widget>());

            // More specific check
            expect(resultWidget, isA<Padding>());

            // To avoid "setState() or markNeedsBuild() called during build" errors
            // when just checking types, return a placeholder.
            return const SizedBox.shrink();
          },
        ),
      ));
    });

    testWidgets(
        'positionMethodWidget returns a widget from buildPositionMethodWidget', (
        WidgetTester tester) async {
      bool testSelection = false;
      void testOnChanged(bool val) {
        testSelection = val;
      }

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            final Widget resultWidget = widgetFactory.positionMethodWidget(
              context,
              testSelection,
              testOnChanged,
            );

            expect(resultWidget, isA<Widget>());
            expect(resultWidget, isA<Row>());
            return const SizedBox.shrink();
          },
        ),
      ));
    });

    testWidgets('textFieldEditor returns a widget from buildTextFieldEditor', (
        WidgetTester tester) async {
      final TextEditingController controller = TextEditingController();
      const String labelText = 'Test Label';
      const String hintText = 'Test Hint';

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            final Widget resultWidget = widgetFactory.textFieldEditor(
              context,
              controller,
              labelText,
              hintText,
            );

            expect(resultWidget, isA<Widget>());
            expect(resultWidget, isA<Padding>());
            return const SizedBox.shrink();
          },
        ),
      ));

      // Clean up the controller
      controller.dispose();
    });

  });

  group('editDialog', () {

    late BasicWidgetFactory widgetFactory;
    late TextEditingController testController;
    bool saveCalled = false;
    bool cancelCalled = false;

    setUp(() {
      widgetFactory = const BasicWidgetFactory();
      // Initialize before each test in this group
      testController = TextEditingController(text: 'Initial Value');
      saveCalled = false;
      cancelCalled = false;
    });

    tearDown(() {
      // Clean up after each test
      testController.dispose();
    });

    testWidgets('happy path - shows dialog, updates text, calls save, and dismisses',
            (WidgetTester tester) async {
          const String dialogTitle = 'Test Edit Title';
          const String dialogInputLabel = 'Enter data:';
          const String newText = 'Updated Value';

          bool buttonPressed = false;

          // Build the widget that will trigger the dialog

          await pumpBaseWidget(
            tester,
            Builder(
              builder: (BuildContext context) {
                // Add a print here to ensure this builder is run
                print("[TEST] Outer Builder widget built.");
                return ElevatedButton(
                  onPressed: () {
                    buttonPressed = true; // Mark that button was pressed
                    print("[TEST] ElevatedButton onPressed CALLED.");
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        print("[TEST] showDialog builder CALLED.");
                        Widget widget = widgetFactory.editDialog(
                          dialogContext,
                          dialogTitle,
                          dialogInputLabel,
                          testController,
                              () {
                            saveCalled = true;
                            Navigator.of(dialogContext).pop();
                          },
                              () {
                            cancelCalled = true;
                            Navigator.of(dialogContext).pop();
                          },
                        );
                        print("[TEST] Dialog widget type: ${widget.runtimeType}"); // Print its type

                        return widget;
                      },
                    ).then((_) {
                      print("[TEST] showDialog future COMPLETED.");
                    }).catchError((e,s) {
                      print("[TEST] showDialog future ERRORED: $e");
                      print(s);
                    });
                  },
                  child: const Text('Show Factory Edit Dialog'),
                );
              },
            ),
          );
          print("[TEST] pumpBaseWidget COMPLETED.");

          // Tap the button to show the dialog
          final buttonFinder = find.text('Show Factory Edit Dialog');
          expect(buttonFinder, findsOneWidget, reason: "Button to show dialog should be present");
          print("[TEST] About to TAP button.");
          await tester.tap(buttonFinder);
          print("[TEST] TAP completed.");

          // IMPORTANT: Let's see if onPressed was actually triggered
          expect(buttonPressed, isTrue, reason: "ElevatedButton's onPressed should have been called.");

          print("[TEST] About to PUMP AND SETTLE after tap.");
          await tester.pumpAndSettle(); // Allow dialog to appear and animations to finish
          print("[TEST] PUMP AND SETTLE completed.");

          // --- Verify initial dialog state ---
          // This is the failing line
          expect(find.byType(AlertDialog), findsOneWidget, reason: "AlertDialog should be shown");
          print("[TEST] AlertDialog found successfully (if this prints).");
          final textFieldFinder = find.byType(TextField);
          expect(textFieldFinder, findsOneWidget, reason: "TextField should be present");
          final TextField textField = tester.widget<TextField>(textFieldFinder);
          expect(textField.controller, equals(testController), reason: "TextField should use the provided controller");
          expect(testController.text, equals('Initial Value'), reason: "Controller should have the initial value");
          expect(textField.decoration?.labelText, equals(dialogInputLabel), reason: "Input label should be correct");

          // Verify Save and Cancel buttons are present (assuming standard text from buildEditAndSubmitDialog)
          expect(find.widgetWithText(TextButton, 'Save'), findsOneWidget);
          expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);


          // --- Interact with the dialog ---
          await tester.enterText(textFieldFinder, newText);
          await tester.pump(); // Allow controller and text field to update

          expect(testController.text, equals(newText), reason: "Controller text should be updated after typing");

          // Tap the "Save" button
          await tester.tap(find.widgetWithText(TextButton, 'Save'));
          await tester.pumpAndSettle(); // Allow dialog to dismiss and animations to finish

          // --- Verify outcomes ---
          expect(find.byType(AlertDialog), findsNothing, reason: "Dialog should be dismissed after save");
          expect(saveCalled, isTrue, reason: "Save callback should have been invoked");
          expect(cancelCalled, isFalse, reason: "Cancel callback should NOT have been invoked");
          // The testController.text will still be newText, which is correct.
          // The actual persistence or use of this value happens inside the save callback's implementation.
        });
  });
}