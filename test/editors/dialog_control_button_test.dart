import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/editors/dialog_control_button.dart';
import 'package:stager/site_state.dart';
import 'package:stager/tree/tree_node.dart';
import 'mock_controller.dart';
import 'mock_dialog_control_button.dart';
import 'mock_editor_factory.dart';
import 'mock_site_state_observer.dart';
import 'mock_stager_editor.dart';

void main() {

  group('DialogControlButton', () {
    late SiteState state;
    late MockSiteStateObserver observer;
    late MockController mockController;
    late MockEditorFactory mockEditorFactory;

    setUp(() {
      state = SiteState();
      TreeNode root = state.addSite('Test Site');
      state.selectedNode = root;
      state.attach(observer = MockSiteStateObserver());
      mockEditorFactory = MockEditorFactory(state);
      mockController = MockController(state, mockEditorFactory);
    });

    Future<void> pumpStagerControlWidget(WidgetTester tester,
        DialogControlButton widget) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      );
    }

    testWidgets('should render an IconButton', (WidgetTester tester) async {
      final controlWidget = MockDialogControlButton(controller: mockController, state: state,);

      await pumpStagerControlWidget(tester, controlWidget);

      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets(
        'tapping IconButton should show dialog with the provided editor',
            (WidgetTester tester) async {

          // Ensure the mock controller's wasProcessed flag is false before the interaction
          mockController.reset();
          expect(mockController.wasProcessed, isFalse,
              reason: "MockController should not have been processed yet");

          // Ensure the mock editor's built flag is false before the interaction
          MockStagerEditor mockEditor = mockController.editorRef as MockStagerEditor;
          mockEditor
              .reset(); // Or create a new instance: mockEditor = MockStagerEditor();
          expect(mockEditor.built, isFalse,
              reason: "MockEditor should not be built yet");

          final MockDialogControlButton controlWidget = MockDialogControlButton(
            controller: mockController,
            state: state,
          );

          await pumpStagerControlWidget(tester, controlWidget);

          // Verify no dialog or our mock editor's default view is present initially
          expect(find.byType(Dialog), findsNothing);
          expect(
              find.byKey(MockStagerEditor.mockStagerEditorKey), findsNothing);

          // Tap the IconButton
          await tester.tap(find.byType(IconButton));
          await tester.pumpAndSettle(); // pumpAndSettle for dialog animations

          // Verify a Dialog is shown
          expect(find.byType(Dialog), findsOneWidget,
              reason: "A Dialog should be displayed");

          // Verify that the mock editor's build method was called
          expect(mockEditor.built, isTrue,
              reason: "MockEditor's build method should have been called");

          // Find and tap the 'OK' button.
          final okButton = find.widgetWithText(TextButton, 'OK');
          expect(okButton, findsOneWidget,
              reason: "MockStagerEditor should have an 'OK' button.");
          await tester.tap(okButton);
          await tester.pumpAndSettle();

          // Verify that the editor was created with the button and that
          // _processResults was called.
          expect(controlWidget.built, isTrue,
              reason: "Override of DialogControlButton's processResults "
                  "method should have been called");
          expect(mockController.wasProcessed, isTrue,);
        });

    testWidgets('IconButton should use the IconData passed to the constructor',
            (WidgetTester tester) async {

          final controlWidget = MockDialogControlButton(
            controller: mockController,
            state: state,
          );

          await pumpStagerControlWidget(tester, controlWidget);

          // Find the IconButton
          final iconButtonFinder = find.byType(IconButton);
          expect(iconButtonFinder, findsOneWidget,
              reason: "IconButton should be rendered by StagerControlWidget");

          // Get the IconButton widget from the finder
          final iconButtonWidget = tester.widget<IconButton>(iconButtonFinder);

          // The 'icon' property of IconButton should be an Icon widget
          expect(iconButtonWidget.icon, isA<Icon>(),
              reason: "IconButton's icon property should be an Icon widget");

          // Cast the icon to an Icon widget to inspect its properties
          final actualIconWidget = iconButtonWidget.icon as Icon;

          // Assert that the IconData of this Icon widget matches our expectedIconData
          expect(actualIconWidget.icon, equals(mockController.iconData()),
              reason: "The IconData of the IconButton's Icon should match the IconData passed to StagerControlWidget's constructor");

          // Optionally, you can also check other properties like the color if it's consistently applied
          // This requires a Theme to be properly set up in pumpStagerControlWidget.
          final ThemeData theme = Theme.of(tester.element(find.byType(MaterialApp))); // Get the theme used
          expect(actualIconWidget.color, equals(theme.colorScheme.onPrimary),
              reason: "Icon's color should match theme.colorScheme.onPrimary");
        });

  });
}