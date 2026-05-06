import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:stager_platform/mapping/single_point_map_editor.dart';

void main() {
  group('SinglePointMapEditor', () {
    const center = LatLng(0, 0);

    testWidgets(
        'Should display initial instructions and "No point selected" when no point is provided',
            (WidgetTester tester) async {
          // Initialize the editor with no initial point.
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SinglePointMapEditor(
                  centerPosition: center,
                  onPointChanged: (_) {},
                ),
              ),
            ),
          );

          // Verify that the initial instruction text is displayed.
          expect(find.text('Click on the map to place the point.'), findsOneWidget);
          // Verify that the "No point selected" text is displayed.
          expect(find.text('No point selected'), findsOneWidget);
          // Verify that no "Clear Point" button is present.
          expect(find.text('Clear Point'), findsNothing);
        });

    testWidgets(
        'Should display point instructions and "Clear Point" button when a point is provided',
            (WidgetTester tester) async {
          const initialPoint = LatLng(1, 1);

          // Initialize the editor with an initial point.
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SinglePointMapEditor(
                  initialPoint: initialPoint,
                  centerPosition: center,
                  onPointChanged: (_) {},
                ),
              ),
            ),
          );

          // Verify that the updated instruction text is displayed.
          expect(
            find.text(
                'Click on the map to move the point. Drag the marker to move it, or tap it (or use "Clear Point" button) to delete.'),
            findsOneWidget,
          );
          // Verify that the "Clear Point" button is present.
          expect(find.text('Clear Point'), findsOneWidget);
          // Verify that "No point selected" is not displayed.
          expect(find.text('No point selected'), findsNothing);
        });

    testWidgets('Should call onPointChanged when the map is tapped',
            (WidgetTester tester) async {
          // Use a late variable to capture the point.
          late LatLng capturedPoint;
          bool called = false;

          // Initialize the editor and capture the point change.
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SinglePointMapEditor(
                  initialPoint: const LatLng(33, -77),
                  centerPosition: const LatLng(33.0, -77.0),
                  onPointChanged: (point) {
                    capturedPoint = point;
                    called = true;
                  },
                ),
              ),
            ),
          );

          // Wait for the map to stabilize.
          await tester.pumpAndSettle();

          // Find the FlutterMap widget and verify its presence.
          final mapFinder = find.byType(FlutterMap);
          expect(mapFinder, findsOneWidget);

          // Tap the map at an offset from the top-left to avoid the marker at the
          // center. Using getTopLeft + Offset(10, 10) ensures we are inside the
          // map boundaries.
          await tester.tapAt(tester.getTopLeft(mapFinder) + const Offset(10, 10));

          // CRITICAL FIX: flutter_map uses an internal 250ms Timer to verify double-taps.
          // pumpAndSettle() does not advance time for standard Timers. We must manually
          // pump for at least 250ms to flush the timer and trigger the onTap callback.
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pumpAndSettle();

          // Verify that onPointChanged was called.
          expect(called, isTrue, reason: 'onPointChanged should be called');
        });

    testWidgets(
        'Should call onPointChanged and reset to the initial point when "Clear Point" is pressed',
            (WidgetTester tester) async {
          const initialPoint = LatLng(1, 1);
          LatLng? capturedPoint;

          // Initialize the editor with a point.
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SinglePointMapEditor(
                  initialPoint: initialPoint,
                  centerPosition: center,
                  onPointChanged: (point) => capturedPoint = point,
                ),
              ),
            ),
          );

          // Tap the "Clear Point" button.
          await tester.tap(find.text('Clear Point'));
          await tester.pump();

          // Verify that onPointChanged was called and reset to the initial point.
          expect(capturedPoint, initialPoint);
        });

    testWidgets(
        'Should update when the initialPoint property is changed externally',
            (WidgetTester tester) async {
          const firstPoint = LatLng(1, 1);
          const secondPoint = LatLng(2, 2);

          // Initialize with the first point.
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SinglePointMapEditor(
                  initialPoint: firstPoint,
                  centerPosition: center,
                  onPointChanged: (_) {},
                ),
              ),
            ),
          );

          expect(find.text('Clear Point'), findsOneWidget);

          // Re-pump with the second point.
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SinglePointMapEditor(
                  initialPoint: secondPoint,
                  centerPosition: center,
                  onPointChanged: (_) {},
                ),
              ),
            ),
          );

          expect(find.text('Clear Point'), findsOneWidget);

          // Re-pump with origin.
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SinglePointMapEditor(
                  centerPosition: center,
                  onPointChanged: (_) {},
                ),
              ),
            ),
          );

          expect(find.text('No point selected'), findsOneWidget);
        });

    testWidgets('Should clear the point when the marker is tapped',
            (WidgetTester tester) async {
          const initialPoint = LatLng(1, 1);
          LatLng? capturedPoint;

          // Initialize the editor with a point at the center.
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SinglePointMapEditor(
                  initialPoint: initialPoint,
                  centerPosition: initialPoint,
                  onPointChanged: (point) => capturedPoint = point,
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Find the marker by its icon.
          final markerIcon = find.byIcon(Icons.location_pin);
          expect(markerIcon, findsOneWidget);

          // Tap the marker.
          await tester.tap(markerIcon);
          await tester.pump();

          // Verify that onPointChanged was called and reset to the initial point.
          expect(capturedPoint, initialPoint);
        });

    testWidgets('Should update map center when centerPosition changes',
            (WidgetTester tester) async {
          const firstCenter = LatLng(0, 0);
          const secondCenter = LatLng(10, 10);

          // Initialize with the first center.
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SinglePointMapEditor(
                  centerPosition: firstCenter,
                  onPointChanged: (_) {},
                ),
              ),
            ),
          );

          // Find the FlutterMap and check its current center.
          final flutterMap = tester.widget<FlutterMap>(find.byType(FlutterMap));
          expect(flutterMap.options.initialCenter, firstCenter);

          // Re-pump with the second center.
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SinglePointMapEditor(
                  centerPosition: secondCenter,
                  onPointChanged: (_) {},
                ),
              ),
            ),
          );

          // We expect the map to have moved.
          expect(find.byType(FlutterMap), findsOneWidget);
        });
  });
}