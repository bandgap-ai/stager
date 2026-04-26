
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:stager_platform/editors/node_properties_view.dart';
import 'package:stager_platform/editors/properties_widget.dart';
import 'package:stager_platform/system/selection.dart';
import 'package:stager_platform/editors/stager_pin.dart';
import 'package:stager_platform/editors/standard_widgets.dart';
import 'package:stager_platform/editors/single_point_map_editor.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:stager_platform/system/selection_service.dart';
import 'package:stager_platform/tree/concrete_leaf_node.dart';

class MockTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer options) {
    return const AssetImage('test/assets/map_tile.png');
  }
}

void main() {
  group('Standard Widget Tests', () {
    testWidgets('buildTextFieldEditor builds a text field', (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => buildTextFieldEditor(
              context,
              controller,
              'Test Label',
              'Test Hint',
            ),
          ),
        ),
      ));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Test Hint'), findsOneWidget);
    });

    testWidgets('buildInfoLabel builds a text widget', (WidgetTester tester) async {
      String info = 'Please configure the site information.';
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) => buildInfoLabel(context,info)),
        ),
      ));

      expect(find.text(info), findsOneWidget);
    });

    testWidgets('buildPositionMethodWidget builds a segmented button', (WidgetTester tester) async {
      bool selection = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => SizedBox( // Wrap in SizedBox to give it a defined size
              width: 400,
              height: 100,
              child: buildPositionMethodWidget(
                context,
                selection,
                (value) {
                  selection = value;
                },
              ),
            ),
          ),
        ),
      ));

      expect(find.byType(SegmentedButton<bool>), findsOneWidget);
      expect(find.byIcon(Icons.keyboard), findsOneWidget);
      Finder iconFinder = find.byIcon(Icons.pin_drop);
      expect(iconFinder, findsOneWidget);

      await tester.tap(iconFinder);
      await tester.pump();

      expect(selection, isTrue);
    });

    testWidgets('buildMapEditor builds a map editor', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => buildSinglePointMapEditor(
              context,
              LatLng(0, 0),
              (point) {},
              tileLayers: [
                TileLayer(
                  tileProvider: MockTileProvider(),
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
              ],
            ),
          ),
        ),
      ));

      // This is a basic test. A more thorough test would require a mock map implementation.
      expect(find.byType(SinglePointMapEditor), findsOneWidget);
    });

    testWidgets('buildGeoCoordEditor builds a coordinate editor', (WidgetTester tester) async {
      final latController = TextEditingController();
      final lonController = TextEditingController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => buildGeoCoordEditor(
              context,
              latController,
              lonController,
            ),
          ),
        ),
      ));

      expect(find.text('Latitude:'), findsOneWidget);
      expect(find.text('Longitude:'), findsOneWidget);
      expect(latController.text, '0.0');
      expect(lonController.text, '0.0');
    });
    const String testTitle = 'Test Dialog Title';
    const String testContent = 'This is the test content for the dialog.';

    testWidgets('renders AlertDialog with correct title and content', (WidgetTester tester) async {
      Widget? builtDialog; // To capture the dialog built by the function

      await tester.pumpWidget(MaterialApp(
        home: Scaffold( // Using Scaffold to provide a typical Material parent
          body: Builder(
            builder: (BuildContext context) {
              // Call the function to build the dialog, using the context from the Builder
              builtDialog = buildConfirmDialog(
                context, // Use the valid context from the Builder
                testTitle,
                testContent,
              );
              // We need to return some widget from the builder.
              // We'll pump the actual builtDialog separately if needed,
              // or just return it directly if we are testing it as part of this tree.
              // For direct inspection, it's often cleaner to pump it as the root of a new tree.
              return const SizedBox.shrink(); // Placeholder, actual dialog tested below
            },
          ),
        ),
      ));

      // Now pump the dialog widget that was built by the function
      // This ensures it has Material ancestors from the previous pump
      // and we are testing the actual returned widget.
      expect(builtDialog, isNotNull);
      if (builtDialog != null) {
        await tester.pumpWidget(MaterialApp(home: Material(child: builtDialog!)));
      }


      // Verify the AlertDialog is present
      expect(find.byType(AlertDialog), findsOneWidget);

      // Verify the title is correct
      expect(find.text(testTitle), findsOneWidget);
      expect(find.descendant(of: find.byType(AlertDialog), matching: find.text(testTitle)), findsOneWidget);

      // Verify the content is correct
      expect(find.text(testContent), findsOneWidget);
      expect(find.descendant(of: find.byType(AlertDialog), matching: find.text(testContent)), findsOneWidget);
    });

    testWidgets('contains "Cancel" and "Confirm" TextButtons', (WidgetTester tester) async {
      Widget? builtDialog;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              builtDialog = buildConfirmDialog(
                context, // Use the valid context from the Builder
                testTitle,
                testContent,
              );
              return const SizedBox.shrink(); // Placeholder
            },
          ),
        ),
      ));

      expect(builtDialog, isNotNull);
      if (builtDialog != null) {
        await tester.pumpWidget(MaterialApp(home: Material(child: builtDialog!)));
      }

      final Finder cancelButtonFinder = find.widgetWithText(TextButton, 'Cancel');
      final Finder confirmButtonFinder = find.widgetWithText(TextButton, 'Confirm');

      expect(cancelButtonFinder, findsOneWidget);
      expect(confirmButtonFinder, findsOneWidget);

      expect(find.descendant(of: find.byType(AlertDialog), matching: cancelButtonFinder), findsOneWidget);
      expect(find.descendant(of: find.byType(AlertDialog), matching: confirmButtonFinder), findsOneWidget);
    });

    // The tests for "pops with false" and "pops with true" remain the same
    // as they correctly use showDialog and its builder's context.

    testWidgets('"Cancel" button pops with false', (WidgetTester tester) async {
      dynamic popResult;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext builderContext) { // Renamed for clarity
              return ElevatedButton(
                onPressed: () async {
                  popResult = await showDialog<bool>(
                    context: builderContext, // Use context from ElevatedButton's parent
                    builder: (dialogContext) => buildConfirmDialog( // This is the crucial context for the dialog
                      dialogContext,
                      testTitle,
                      testContent,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(popResult, isFalse);
    });

    testWidgets('"Confirm" button pops with true', (WidgetTester tester) async {
      dynamic popResult;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext builderContext) {
              return ElevatedButton(
                onPressed: () async {
                  popResult = await showDialog<bool>(
                    context: builderContext,
                    builder: (dialogContext) => buildConfirmDialog(
                      dialogContext,
                      testTitle,
                      testContent,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Confirm'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(popResult, isTrue);
    });

    // Key for accessing ScaffoldMessengerState if needed for more complex SnackBar tests,
    // though for these basic ones, finding by type or text is usually sufficient.
    final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

    // Helper function to pump a widget tree with a Scaffold and MaterialApp
    // which are necessary for SnackBar and Dialogs to work.
    Future<BuildContext> pumpBaseWidget(WidgetTester tester, {Widget? child}) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey, // For SnackBar testing
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                capturedContext = context;
                return child ?? const SizedBox.shrink(); // Render child or an empty box
              },
            ),
          ),
        ),
      );
      return capturedContext;
    }

    group('buildNotificationCallback', () {
      testWidgets('returns a function that shows a SnackBar with the given message',
              (WidgetTester tester) async {
            final BuildContext context = await pumpBaseWidget(tester);
            const String testMessage = 'Hello from callback!';

            final Function(String) notificationCallback =
            buildNotificationCallback(context);

            // Call the returned function
            notificationCallback(testMessage);
            await tester.pump(); // Allow SnackBar to build and animate slightly

            // Verify SnackBar is shown with the correct message
            expect(find.byType(SnackBar), findsOneWidget);
            expect(find.text(testMessage), findsOneWidget);

            await tester.pumpAndSettle(); // Ensure SnackBar disappears
          });

      testWidgets('callback does nothing if context is unmounted (simulated)',
              (WidgetTester tester) async {
            // Pump a widget to get a valid context first
            final BuildContext mountedContext = await pumpBaseWidget(tester);
            const String testMessage = 'Unmounted test';

            final Function(String) notificationCallback =
            buildNotificationCallback(mountedContext);

            // Simulate context being unmounted by pumping a completely different tree
            // (This is a bit indirect; a more direct way would be to mock context.mounted if possible,
            // but that's harder with BuildContext itself.)
            // For this test, we'll rely on the internal check of context.mounted in showNotification.

            // "Unmount" the original context by navigating away or replacing the widget tree
            await tester.pumpWidget(MaterialApp(home: Container())); // Pump a new tree

            // Now, if we call the callback with the old context, it should ideally not find ScaffoldMessenger
            // or the mounted check should prevent it.
            // This part is tricky to test perfectly without direct mocking of context.mounted.
            // The `if (context.mounted)` check in `showNotification` is the primary safeguard.
            notificationCallback(testMessage);
            await tester.pump(); // Attempt to show SnackBar

            expect(find.byType(SnackBar), findsNothing,
                reason: "SnackBar should not appear if context was unmounted");
          });
    });

    group('showNotification', () {
      testWidgets('shows a SnackBar with the given message',
              (WidgetTester tester) async {
            final BuildContext context = await pumpBaseWidget(tester);
            const String testMessage = 'Hello from showNotification!';

            showNotification(context, testMessage);
            await tester.pump(); // Allow SnackBar to build

            expect(find.byType(SnackBar), findsOneWidget);
            expect(find.text(testMessage), findsOneWidget);

            await tester.pumpAndSettle();
          });

      testWidgets('does not show SnackBar if context is unmounted (simulated)',
              (WidgetTester tester) async {
            final BuildContext mountedContext = await pumpBaseWidget(tester);
            const String testMessage = 'Unmounted showNotification';

            // "Unmount" by pumping a new tree
            await tester.pumpWidget(MaterialApp(home: Container()));

            showNotification(mountedContext, testMessage); // mountedContext is now stale
            await tester.pump();

            expect(find.byType(SnackBar), findsNothing);
          });
    });

    group('buildCustomDialog', () {
      testWidgets('builds an AlertDialog with correct title and custom content',
              (WidgetTester tester) async {
            const String dialogTitle = 'Custom Title';
            const Widget customContent = Text('Custom Content Widget');

            await pumpBaseWidget(tester, child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext buildContext) {
                        return buildCustomDialog(
                            buildContext, dialogTitle, customContent);
                      },
                    );
                  },
                  child: const Text('Show Custom Dialog'),
                );
              },
            ));

            // Tap the button to show the dialog
            await tester.tap(find.byType(ElevatedButton));
            await tester.pumpAndSettle();

            // Verify dialog is shown
            expect(find.byType(AlertDialog), findsOneWidget);
            expect(find.text(dialogTitle), findsOneWidget);
            expect(find.text('Custom Content Widget'), findsOneWidget);
          });
    });

    group('buildMessageDialog', () {
      testWidgets('builds an AlertDialog with correct title, content, and OK button',
              (WidgetTester tester) async {
            const String dialogTitle = 'Test Title';
            const String dialogContent = 'This is test content.';

            await pumpBaseWidget(tester, child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext buildContext) {
                        return buildMessageDialog(
                            buildContext, dialogTitle, dialogContent);
                      },
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ));

            // Tap the button to show the dialog
            await tester.tap(find.byType(ElevatedButton));
            await tester.pumpAndSettle(); // Dialog animation

            // Verify dialog is shown
            expect(find.byType(AlertDialog), findsOneWidget);
            expect(find.text(dialogTitle), findsOneWidget);
            expect(find.text(dialogContent), findsOneWidget);
            expect(find.widgetWithText(TextButton, 'OK'), findsOneWidget);

            // Verify OK button pops the dialog
            await tester.tap(find.widgetWithText(TextButton, 'OK'));
            await tester.pumpAndSettle(); // Dialog dismiss animation

            expect(find.byType(AlertDialog), findsNothing);
          });
    });

    group('buildErrorDialogCallback', () {
      testWidgets('returns a function that shows an AlertDialog with title and content',
              (WidgetTester tester) async {
            final BuildContext context = await pumpBaseWidget(tester);
            const String errorTitle = 'Error Occurred';
            const String errorMessage = 'Something went wrong!';

            final Function() showErrorDialog =
            buildErrorDialogCallback(context, errorTitle, errorMessage);

            // Call the returned function
            // It's async, but showDialog itself handles the presentation.
            // We don't need to await the result of showErrorDialog itself if we're just testing UI.
            showErrorDialog();
            await tester.pumpAndSettle(); // Allow Dialog to build and animate

            // Verify AlertDialog is shown
            expect(find.byType(AlertDialog), findsOneWidget);
            expect(find.text(errorTitle), findsOneWidget);
            expect(find.text(errorMessage), findsOneWidget);
            expect(find.widgetWithText(TextButton, 'OK'), findsOneWidget);

            // Tap OK to dismiss
            await tester.tap(find.widgetWithText(TextButton, 'OK'));
            await tester.pumpAndSettle();
            expect(find.byType(AlertDialog), findsNothing);
          });

      testWidgets('error dialog callback does nothing if context is unmounted (simulated)',
              (WidgetTester tester) async {
            final BuildContext mountedContext = await pumpBaseWidget(tester);
            const String errorTitle = 'Unmounted Error';
            const String errorMessage = 'Context gone';

            final Function() showErrorDialog =
            buildErrorDialogCallback(mountedContext, errorTitle, errorMessage);

            // "Unmount" by pumping a new tree
            await tester.pumpWidget(MaterialApp(home: Container()));

            showErrorDialog(); // Call with stale context
            await tester.pumpAndSettle();

            expect(find.byType(AlertDialog), findsNothing,
                reason: "AlertDialog should not appear if context was unmounted");
          });
    });

    group('buildBottomSheet', () {

      WidgetBuilder getPropertiesWidgetBuilder(PropertiesWidget widget) {
        return (BuildContext context) {
          return widget;
        };
      }

      /// Pumps the [PropertiesWidget] into the tester.
      Future<void> pumpPropertiesWidget(WidgetTester tester, {StagerPin? pin}) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                  builder: (BuildContext context) {
                    // Create the widget for the test
                    PropertiesWidget propertiesWidget = PropertiesWidget(
                      selectionService: SelectionService(),
                      pin: pin,
                    );
                    // Build the bottom sheet that will actually be tested
                    return buildBottomSheet(context, getPropertiesWidgetBuilder(propertiesWidget), null);
                  },
              ),
            ),
          )
        );
      }

      testWidgets('renders BottomSheet with properties when a node is selected', (
          WidgetTester tester,
          ) async {

        // This is an older test taken from properties_widget_test.dart when
        // the PropertiesWidget directly returned a bottom sheet.

        // Arrange: Select a node
        SelectionService selectionService = SelectionService();
        selectionService.selection = Selection<ConcreteLeafNode>(ConcreteLeafNode(name: 'Test Node'));

        // Act
        await pumpPropertiesWidget(tester);
        await tester.pump(); // Let the bottom sheet animate up

        // Assert
        expect(find.byType(BottomSheet), findsOneWidget);
        expect(find.byType(NodePropertiesView), findsOneWidget);
        expect(
          find.byWidgetPredicate((widget) => widget is SegmentedButton<String>),
          findsOneWidget,
        );

        // Switch to images tab to find the Add Image button
        await tester.tap(find.byIcon(Icons.image_outlined));
        await tester.pump();
        expect(find.text('Add Image'), findsOneWidget);
      });
    });

    group('buildEditAndSubmitDialog', () {
      const String dialogTitle = 'Edit Value';
      const String inputLabel = 'Enter value:'; // Using your parameter name
      late TextEditingController testController;
      bool saveCalled = false;
      bool cancelCalled = false;

      // Helper to show the dialog
      Future<void> showTestDialog(WidgetTester tester) async {
        // Reset state for each test run using this helper
        testController = TextEditingController(text: 'Initial text');
        saveCalled = false;
        cancelCalled = false;

        await pumpBaseWidget(tester, child: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showDialog<void>( // Dialog doesn't need to return a value now
                  context: context,
                  barrierDismissible: false, // Usually good for edit dialogs
                  builder: (BuildContext dialogContext) {
                    return buildEditAndSubmitDialog(
                      dialogContext,
                      dialogTitle,
                      inputLabel,
                      testController, // Pass the controller
                          () { // Save callback
                        saveCalled = true;
                        Navigator.of(dialogContext).pop(); // Dialog must be popped by callback
                      },
                          () { // Cancel callback
                        cancelCalled = true;
                        Navigator.of(dialogContext).pop(); // Dialog must be popped by callback
                      },
                    );
                  },
                );
              },
              child: const Text('Show Edit Dialog'),
            );
          },
        ));
        await tester.tap(find.text('Show Edit Dialog'));
        await tester.pumpAndSettle(); // Allow dialog to appear
      }

      // Clean up the controller after each test
      tearDown(() {
        testController.dispose();
      });

      testWidgets('renders dialog with correct title, input label, and initial controller value',
              (WidgetTester tester) async {
            await showTestDialog(tester);

            expect(find.byType(AlertDialog), findsOneWidget);
            expect(find.text(dialogTitle), findsOneWidget); // Checks title in dialog

            // Check for the input label
            final textFieldFinder = find.byType(TextField);
            expect(textFieldFinder, findsOneWidget);
            final TextField textField = tester.widget<TextField>(textFieldFinder);
            expect(textField.decoration?.labelText, equals(inputLabel));

            // Check TextField's initial value via controller
            expect(textField.controller, equals(testController));
            expect(testController.text, equals('Initial text'));


            // Check for buttons (assuming standard text for them based on typical usage)
            expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
            expect(find.widgetWithText(TextButton, 'Save'), findsOneWidget); // Changed from "Submit" to "Save"
          });

      testWidgets('typing in TextField updates the provided controller',
              (WidgetTester tester) async {
            await showTestDialog(tester);
            const String typedText = 'New controller value';

            await tester.enterText(find.byType(TextField), typedText);
            await tester.pump(); // Allow controller and text field to update

            expect(testController.text, equals(typedText));
          });

      testWidgets('"Cancel" button calls cancel callback and dialog is dismissed',
              (WidgetTester tester) async {
            await showTestDialog(tester);
            expect(find.byType(AlertDialog), findsOneWidget);

            await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
            await tester.pumpAndSettle(); // Allow dialog to dismiss

            expect(cancelCalled, isTrue, reason: "Cancel callback should have been called");
            expect(saveCalled, isFalse, reason: "Save callback should NOT have been called");
            expect(find.byType(AlertDialog), findsNothing);
          });

      testWidgets('"Save" button calls save callback and dialog is dismissed',
              (WidgetTester tester) async {
            await showTestDialog(tester);
            expect(find.byType(AlertDialog), findsOneWidget);
            const String finalValue = "Value to save";

            // Update controller before saving
            testController.text = finalValue;
            await tester.pump();


            await tester.tap(find.widgetWithText(TextButton, 'Save'));
            await tester.pumpAndSettle(); // Allow dialog to dismiss

            expect(saveCalled, isTrue, reason: "Save callback should have been called");
            expect(cancelCalled, isFalse, reason: "Cancel callback should NOT have been called");
            expect(find.byType(AlertDialog), findsNothing);
          });
    });
  });
}

// test/standard_widgets_test.dart
