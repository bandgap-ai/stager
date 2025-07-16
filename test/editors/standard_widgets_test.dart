
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:stager/editors/standard_widgets.dart';
import 'package:stager/editors/single_point_map_editor.dart';
import 'package:flutter_map/flutter_map.dart';

class MockTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer options) {
    return const AssetImage('test/assets/map_tile.png');
  }
}

void main() {
  group('Standard Widget Tests', () {
    testWidgets('buildTextFieldEditor builds a text field', (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => buildTextFieldEditor(
              context,
              controller,
              'Test Label',
              'Test Hint',
            ),
          ),
        ),
      ));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Test Hint'), findsOneWidget);
    });

    testWidgets('buildInfoLabel builds a text widget', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) => buildInfoLabel(context)),
        ),
      ));

      expect(find.text('Please configure the site information.'), findsOneWidget);
    });

    testWidgets('buildPositionMethodWidget builds a segmented button', (WidgetTester tester) async {
      bool selection = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => SizedBox( // Wrap in SizedBox to give it a defined size
              width: 400,
              height: 100,
              child: buildPositionMethodWidget(
                context,
                selection,
                (value) {
                  selection = value;
                },
              ),
            ),
          ),
        ),
      ));

      expect(find.byType(SegmentedButton<bool>), findsOneWidget);
      expect(find.text('Input Coordinates'), findsOneWidget);
      expect(find.text('Select on Map'), findsOneWidget);

      await tester.tap(find.text('Select on Map'));
      await tester.pump();

      expect(selection, isTrue);
    });

    testWidgets('buildMapEditor builds a map editor', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => buildSinglePointMapEditor(
              context,
              LatLng(0, 0),
              (point) {},
              tileLayers: [
                TileLayer(
                  tileProvider: MockTileProvider(),
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
              ],
            ),
          ),
        ),
      ));

      // This is a basic test. A more thorough test would require a mock map implementation.
      expect(find.byType(SinglePointMapEditor), findsOneWidget);
    });

    testWidgets('buildGeoCoordEditor builds a coordinate editor', (WidgetTester tester) async {
      final latController = TextEditingController();
      final lonController = TextEditingController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => buildGeoCoordEditor(
              context,
              latController,
              lonController,
            ),
          ),
        ),
      ));

      expect(find.text('Latitude:'), findsOneWidget);
      expect(find.text('Longitude:'), findsOneWidget);
      expect(latController.text, '0.0');
      expect(lonController.text, '0.0');
    });
  });
}
