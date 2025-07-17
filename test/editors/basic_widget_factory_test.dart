// test/basic_widget_factory_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/editors/basic_widget_factory.dart';

void main() {
  // Test group for BasicWidgetFactory
  group('BasicWidgetFactory', () {
    late BasicWidgetFactory widgetFactory;

    setUp(() {
      widgetFactory = const BasicWidgetFactory();
    });

    testWidgets('infoLabel returns a widget from buildInfoLabel', (
        WidgetTester tester) async {
      // Pump a MaterialApp to provide a valid BuildContext with theme, etc.
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            // Call the factory method
            final Widget resultWidget = widgetFactory.infoLabel(context);

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
}