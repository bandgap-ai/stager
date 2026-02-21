import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:stager_platform/editors/location_editor.dart';
import 'package:logger/logger.dart';
// Test dependency
import 'mock_location_provider.dart';

void main() {
  group('LocationEditor', () {
    late MockLocationProvider mockLocationProvider;

    setUp(() {
      mockLocationProvider = MockLocationProvider();
    });

    testWidgets('Should update location when auto-locate is used', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationEditor(locationProvider: mockLocationProvider),
          ),
        ),
      );

      // Ensure the 'auto' method is selected by default
      expect(find.widgetWithText(ElevatedButton, 'Get my location'), findsOneWidget);

      // Tap the button to get the location
      await tester.tap(find.text('Get my location'));
      await tester.pumpAndSettle();

      // Check if the text fields are updated by inspecting their controllers.
      final latitudeField = tester.widget<TextField>(find.ancestor(
        of: find.text('Latitude:'),
        matching: find.byType(TextField),
      ));
      expect(latitudeField.controller!.text, '42.0');

      final longitudeField = tester.widget<TextField>(find.ancestor(
        of: find.text('Longitude:'),
        matching: find.byType(TextField),
      ));
      expect(longitudeField.controller!.text, '-42.0');
    });

    testWidgets('Should trigger onLocationChanged callback when auto-locate is used', (WidgetTester tester) async {
      late LatLng receivedLocation;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationEditor(
              locationProvider: mockLocationProvider,
              onLocationChanged: (loc) => receivedLocation = loc,
            ),
          ),
        ),
      );

      // Tap the button to get the location
      await tester.tap(find.text('Get my location'));
      await tester.pumpAndSettle();

      // Assert: Verify callback was called with mock data (42.0, -42.0)
      expect(receivedLocation.latitude, 42.0);
      expect(receivedLocation.longitude, -42.0);
    });

    testWidgets('Should show address field when address method is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationEditor(locationProvider: mockLocationProvider),
          ),
        ),
      );

      // Find and tap the 'Enter Address' icon
      final addressIcon = find.byIcon(Icons.edit_location);
      expect(addressIcon, findsOneWidget);
      await tester.tap(addressIcon);
      await tester.pumpAndSettle();

      // Verify that the address text field is now visible
      expect(find.widgetWithText(TextField, 'Address'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Get my location'), findsNothing);
    });

    testWidgets('Should log an error when location services are disabled', (WidgetTester tester) async {
      //
      final memoryOutput = MemoryOutput();
      final testLogger = Logger(output: memoryOutput);

      // Arrange: Configure the mock to simulate disabled location services.
      mockLocationProvider.isServiceEnabled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationEditor(
              locationProvider: mockLocationProvider,
              logger: testLogger,
            ),
          ),
        ),
      );

      // Act: Tap the button to trigger the location fetch.
      await tester.tap(find.text('Get my location'));
      await tester.pump();

      // Assert: Verify that the correct error message was logged.
      expect(memoryOutput.buffer.length, 1);
      expect(memoryOutput.buffer.first.level, Level.error);
      expect(memoryOutput.buffer.first.lines[4].contains('Location services are disabled.'), isTrue);
    });
  });
}
