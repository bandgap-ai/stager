import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/editors/message_dialog.dart';

void main() {
  group('MessageDialog Widget Tests', () {
    testWidgets('should display title and content correctly', (tester) async {
      const title = 'Test Title';
      const content = 'Test message content';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => const MessageDialog(
                    title: title,
                    content: content,
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify the dialog is displayed with correct title and content
      expect(find.text(title), findsOneWidget);
      expect(find.text(content), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('should close dialog when OK button is tapped', (tester) async {
      const title = 'Test Title';
      const content = 'Test message content';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => const MessageDialog(
                    title: title,
                    content: content,
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify the dialog is displayed
      expect(find.byType(MessageDialog), findsOneWidget);

      // Tap the OK button
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify the dialog is closed
      expect(find.byType(MessageDialog), findsNothing);
    });

    testWidgets('should return false when OK button is tapped', (tester) async {
      const title = 'Test Title';
      const content = 'Test message content';
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<bool>(
                    context: context,
                    builder: (context) => const MessageDialog(
                      title: title,
                      content: content,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap the OK button
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify the result is false
      expect(result, false);
    });
  });
}
