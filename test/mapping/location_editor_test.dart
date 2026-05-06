import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:stager_platform/mapping/location_editor.dart';
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
      expect(find.text('Get my location'), findsOneWidget);

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

      // Find and tap the 'Enter Address' icon (Icons.edit_location)
      final addressIcon = find.byIcon(Icons.edit_location);
      expect(addressIcon, findsOneWidget);
      await tester.tap(addressIcon);
      await tester.pumpAndSettle();

      // Verify that the address text field and lookup button are now visible
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Lookup Address'), findsOneWidget);
    });

    testWidgets('Should update coordinates when address lookup is used', (WidgetTester tester) async {
      // Arrange
      mockLocationProvider.mockAddressLocation = const LatLng(34.0522, -118.2437);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationEditor(locationProvider: mockLocationProvider),
          ),
        ),
      );

      // Switch to address mode
      await tester.tap(find.byIcon(Icons.edit_location));
      await tester.pumpAndSettle();

      // Enter an address
      await tester.enterText(find.widgetWithText(TextField, 'Address'), 'Los Angeles, CA');
      
      // Act
      await tester.tap(find.text('Lookup Address'));
      await tester.pumpAndSettle();

      // Assert
      expect(mockLocationProvider.lastAddressLookedUp, 'Los Angeles, CA');
      
      final latitudeField = tester.widget<TextField>(find.ancestor(
        of: find.text('Latitude:'),
        matching: find.byType(TextField),
      ));
      expect(latitudeField.controller!.text, '34.0522');

      final longitudeField = tester.widget<TextField>(find.ancestor(
        of: find.text('Longitude:'),
        matching: find.byType(TextField),
      ));
      expect(longitudeField.controller!.text, '-118.2437');
    });

    testWidgets('Should trigger onLocationChanged callback when address lookup is used', (WidgetTester tester) async {
      // Arrange
      late LatLng receivedLocation;
      mockLocationProvider.mockAddressLocation = const LatLng(51.5074, -0.1278);
      
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

      // Switch to address mode
      await tester.tap(find.byIcon(Icons.edit_location));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Lookup Address'));
      await tester.pumpAndSettle();

      // Assert
      expect(receivedLocation.latitude, 51.5074);
      expect(receivedLocation.longitude, -0.1278);
    });

    testWidgets('Should log an error when location services are disabled', (WidgetTester tester) async {
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
      await tester.pumpAndSettle();

      // Assert: Verify that the correct error message was logged.
      expect(memoryOutput.buffer.length, 1);
      expect(memoryOutput.buffer.first.level, Level.error);
      expect(memoryOutput.buffer.first.lines[4].contains('Location services are disabled.'), isTrue);
    });

    testWidgets('Should log an error when address lookup fails', (WidgetTester tester) async {
      // Arrange
      final memoryOutput = MemoryOutput();
      final testLogger = Logger(output: memoryOutput);
      mockLocationProvider.shouldThrowOnLookup = true;

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

      // Switch to address mode
      await tester.tap(find.byIcon(Icons.edit_location));
      await tester.pumpAndSettle();

      // Enter an address
      await tester.enterText(find.widgetWithText(TextField, 'Address'), 'Invalid Address');

      // Act
      await tester.tap(find.text('Lookup Address'));
      await tester.pumpAndSettle();

      // Assert
      expect(memoryOutput.buffer.length, 1);
      expect(memoryOutput.buffer.first.level, Level.error);
      expect(memoryOutput.buffer.first.lines[4].contains('Failed to lookup address'), isTrue);
    });

    testWidgets('Should update and notify when coordinates are manually edited', (WidgetTester tester) async {
      // Arrange: Set up the initial state and the callback to capture changes.
      LatLng? receivedLocation;
      const initialLocation = LatLng(39.0, -77.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationEditor(
              initialLocation: initialLocation,
              onLocationChanged: (loc) => receivedLocation = loc,
            ),
          ),
        ),
      );

      // Find the text fields for latitude and longitude.
      final latitudeFinder = find.ancestor(
        of: find.text('Latitude:'),
        matching: find.byType(TextField),
      );
      final longitudeFinder = find.ancestor(
        of: find.text('Longitude:'),
        matching: find.byType(TextField),
      );

      // Verify that the initial values are correctly displayed.
      expect(tester.widget<TextField>(latitudeFinder).controller!.text, '39.0');
      expect(tester.widget<TextField>(longitudeFinder).controller!.text, '-77.0');

      // Act: Manually enter new coordinates into the text fields.
      await tester.enterText(latitudeFinder, '40.0');
      await tester.enterText(longitudeFinder, '-78.0');
      await tester.pump();

      // Assert: Verify that the controllers reflect the new values and the
      // callback was triggered with the updated LatLng.
      expect(tester.widget<TextField>(latitudeFinder).controller!.text, '40.0');
      expect(tester.widget<TextField>(longitudeFinder).controller!.text, '-78.0');
      expect(receivedLocation, isNotNull);
      expect(receivedLocation!.latitude, 40.0);
      expect(receivedLocation!.longitude, -78.0);
    });
  });
}
