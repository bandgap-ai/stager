import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/editors/dialog_control_button.dart';
import 'mock_stager_editor.dart';

void main() {
  group('StagerControlWidget', () {
    late MockStagerEditor mockEditor;
    const IconData expectedIconButtonIcon = Icons
        .add_home_work; // Icon hardcoded in StagerControlWidget

    setUp(() {
      mockEditor = MockStagerEditor();
      // mockEditor.reset(); // Reset before each test if 'built' status is critical between tests
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
      final controlWidget = DialogControlButton(
        icon: Icons.settings,
        // This icon is passed but not used by IconButton's display
        editor: mockEditor,
      );

      await pumpStagerControlWidget(tester, controlWidget);

      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets(
        'tapping IconButton should show dialog with the provided editor',
            (WidgetTester tester) async {
          // Ensure the mock editor's built flag is false before the interaction
          mockEditor
              .reset(); // Or create a new instance: mockEditor = MockStagerEditor();
          expect(mockEditor.built, isFalse,
              reason: "MockEditor should not be built yet");

          final controlWidget = DialogControlButton(
            icon: Icons.play_arrow,
            editor: mockEditor,
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
        });

    testWidgets('IconButton should use the IconData passed to the constructor',
            (WidgetTester tester) async {
          // Define the IconData to be passed and expected
          const IconData expectedIconData = Icons.settings;

          final controlWidget = DialogControlButton(
            icon: expectedIconData, // Pass IconData directly
            editor: mockEditor,
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
          expect(actualIconWidget.icon, equals(expectedIconData),
              reason: "The IconData of the IconButton's Icon should match the IconData passed to StagerControlWidget's constructor");

          // Optionally, you can also check other properties like the color if it's consistently applied
          // This requires a Theme to be properly set up in pumpStagerControlWidget.
          final ThemeData theme = Theme.of(tester.element(find.byType(MaterialApp))); // Get the theme used
          expect(actualIconWidget.color, equals(theme.colorScheme.onPrimary),
              reason: "Icon's color should match theme.colorScheme.onPrimary");
        });

    testWidgets('tapping IconButton should show dialog with the provided editor',
            (WidgetTester tester) async {
          mockEditor.reset();
          const testIconData = Icons.play_arrow; // Use any valid IconData for this test

          final controlWidget = DialogControlButton(
            icon: testIconData,
            editor: mockEditor,
          );

          await pumpStagerControlWidget(tester, controlWidget);

          expect(find.byType(Dialog), findsNothing);
          expect(find.byKey(MockStagerEditor.mockStagerEditorKey), findsNothing);

          await tester.tap(find.byType(IconButton));
          await tester.pumpAndSettle();

          expect(find.byType(Dialog), findsOneWidget);
          expect(mockEditor.built, isTrue);
          expect(find.byKey(MockStagerEditor.mockStagerEditorKey), findsOneWidget);

        });

  });
}