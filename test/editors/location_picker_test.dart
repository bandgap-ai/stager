import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/editors/location_picker.dart';

void main() {
  group('LocationPicker', () {
    testWidgets('Should build with the correct default selection', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationPicker(
              onSelectionChanged: (LocationPickerMethod method) {
                // Nothing to do.
              },
            ),
          ),
        ),
      );

      // Find the segmented button
      final segmentedButton = find.byType(SegmentedButton<LocationPickerMethod>);
      expect(segmentedButton, findsOneWidget);

      // Check that the 'auto' option's icon is visible.
      // We use find.byIcon because the Icon is wrapped in a Tooltip.
      final autoIcon = find.byIcon(Icons.my_location);
      expect(autoIcon, findsOneWidget);

      // Verify that the button's internal state shows 'auto' as selected.
      expect(tester.widget<SegmentedButton>(segmentedButton).selected.first, LocationPickerMethod.auto);
    });

    testWidgets('Should call onSelectionChanged when a new method is tapped', (WidgetTester tester) async {
      LocationPickerMethod? selectedMethod;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationPicker(
              initialSelection: LocationPickerMethod.auto,
              onSelectionChanged: (LocationPickerMethod method) {
                selectedMethod = method;
              },
            ),
          ),
        ),
      );

      // Find and tap the 'map' icon
      final mapIcon = find.byIcon(Icons.pin_drop);
      expect(mapIcon, findsOneWidget);
      await tester.tap(mapIcon);
      await tester.pumpAndSettle();

      // Verify that the callback was called with the correct value
      expect(selectedMethod, LocationPickerMethod.map);
    });
  });
}
