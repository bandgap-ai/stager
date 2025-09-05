import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/editors/stager_pin.dart';

void main() {
  group('StagerPin Widget Tests', () {
    testWidgets('should display lock_open icon when not pinned initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StagerPin(
              initialPinState: false,
              onPinChanged: (bool isPinned) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock_open), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsNothing);
    });

    testWidgets('should display lock icon when pinned initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StagerPin(
              initialPinState: true,
              onPinChanged: (bool isPinned) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.lock_open), findsNothing);
    });

    testWidgets('should toggle from unpinned to pinned on tap and call onPinChanged', (WidgetTester tester) async {
      bool? reportedPinState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StagerPin(
              initialPinState: false,
              onPinChanged: (bool isPinned) {
                reportedPinState = isPinned;
              },
            ),
          ),
        ),
      );

      // Initial state
      expect(find.byIcon(Icons.lock_open), findsOneWidget);
      expect(reportedPinState, isNull);

      // Tap the icon
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // New state
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.lock_open), findsNothing);
      expect(reportedPinState, isTrue);
    });

    testWidgets('should toggle from pinned to unpinned on tap and call onPinChanged', (WidgetTester tester) async {
      bool? reportedPinState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StagerPin(
              initialPinState: true,
              onPinChanged: (bool isPinned) {
                reportedPinState = isPinned;
              },
            ),
          ),
        ),
      );

      // Initial state
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(reportedPinState, isNull);

      // Tap the icon
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // New state
      expect(find.byIcon(Icons.lock_open), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsNothing);
      expect(reportedPinState, isFalse);
    });

    testWidgets('icon color should match theme onPrimary color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue).copyWith(
              onPrimary: Colors.red, // Use a distinct color for testing
            ),
          ),
          home: Scaffold(
            // A colored AppBar to provide a primary background for onPrimary to contrast with
            appBar: AppBar(
              title: StagerPin(
                initialPinState: false,
                onPinChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      final Icon icon = tester.widget(find.byType(Icon));
      final ThemeData theme = Theme.of(tester.element(find.byType(StagerPin)));

      expect(icon.color, theme.colorScheme.onPrimary);
      expect(icon.color, Colors.red);
    });
  });
}