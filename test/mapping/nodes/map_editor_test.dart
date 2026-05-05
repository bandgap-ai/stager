// Flutter packages
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

// Project files
import 'package:stager_platform/mapping/map_editor.dart';
import 'package:stager_platform/mapping/map_state.dart';
import 'package:stager_platform/site_state.dart';

/// Unit tests for the [MapEditor] widget.
///
/// These tests verify that the MapEditor correctly loads its state and 
/// renders the expected FlutterMap components and interactive controls.
void main() {
  group('MapEditor Widget Tests', () {
    testWidgets('should load and contain a FlutterMap widget', (WidgetTester tester) async {
      // Create the state for the map editor.
      final state = MapState(SiteState());
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapEditor(state: state),
          ),
        ),
      );

      // Verify that the MapEditor itself is rendered.
      expect(find.byType(MapEditor), findsOneWidget);
      
      // Verify that the underlying FlutterMap widget is present.
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('tapping search button should open the location dialog', (WidgetTester tester) async {
      // Create the state for the map editor.
      final state = MapState(SiteState());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapEditor(state: state),
          ),
        ),
      );

      // Find the search icon within the floating action button and tap it.
      final searchButton = find.widgetWithIcon(FloatingActionButton, Icons.search);
      expect(searchButton, findsOneWidget);
      await tester.tap(searchButton);
      await tester.pumpAndSettle();

      // Verify that the "Set Location" dialog is displayed.
      expect(find.text('Set Location'), findsOneWidget);
    });

    testWidgets('tapping set button in location dialog should update map center', (WidgetTester tester) async {
      // Create the state for the map editor.
      final state = MapState(SiteState());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapEditor(state: state),
          ),
        ),
      );

      final initialCenter = state.mapController.camera.center;

      // Open the location dialog.
      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.search));
      await tester.pumpAndSettle();

      // Find the text fields for latitude and longitude.
      final latFinder = find.ancestor(
        of: find.text('Latitude:'),
        matching: find.byType(TextField),
      );
      final lngFinder = find.ancestor(
        of: find.text('Longitude:'),
        matching: find.byType(TextField),
      );
      
      // Update the coordinates in the text fields.
      await tester.enterText(latFinder, '10.0');
      await tester.enterText(lngFinder, '20.0');
      await tester.pump();

      // Verify the map center has NOT updated yet (it should wait for "Set").
      expect(state.mapController.camera.center, initialCenter);

      // Tap the "Set" button to confirm and close the dialog.
      await tester.tap(find.text('Set'));
      await tester.pumpAndSettle();

      // Verify that the dialog is closed.
      expect(find.text('Set Location'), findsNothing);
      
      // Verify the map center has been updated to the new coordinates.
      expect(state.mapController.camera.center.latitude, 10.0);
      expect(state.mapController.camera.center.longitude, 20.0);
    });

    testWidgets('tapping cancel button in location dialog should NOT update map center', (WidgetTester tester) async {
      // Create the state for the map editor.
      final state = MapState(SiteState());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapEditor(state: state),
          ),
        ),
      );

      final initialCenter = state.mapController.camera.center;

      // Open the location dialog.
      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.search));
      await tester.pumpAndSettle();

      // Find coordinate fields.
      final latFinder = find.ancestor(of: find.text('Latitude:'), matching: find.byType(TextField));
      
      // Enter coordinates.
      await tester.enterText(latFinder, '10.0');
      await tester.pump();

      // Tap the "Cancel" button.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify that the dialog is closed.
      expect(find.text('Set Location'), findsNothing);
      
      // Verify the map center has NOT changed.
      expect(state.mapController.camera.center, initialCenter);
    });
  });
}
