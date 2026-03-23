// Flutter packages
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

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
      // Arrange
      final state = MapState(SiteState());
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapEditor(state: state),
          ),
        ),
      );

      // Assert
      // Verify that the MapEditor itself is rendered.
      expect(find.byType(MapEditor), findsOneWidget);
      
      // Verify that the underlying FlutterMap widget is present.
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('tapping search button should open the location dialog', (WidgetTester tester) async {
      // Arrange
      final state = MapState(SiteState());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapEditor(state: state),
          ),
        ),
      );

      // Act
      // Find the search icon within the floating action button and tap it.
      final searchButton = find.widgetWithIcon(FloatingActionButton, Icons.search);
      expect(searchButton, findsOneWidget);
      await tester.tap(searchButton);
      await tester.pumpAndSettle();

      // Assert
      // Verify that the "Set Location" dialog is displayed.
      expect(find.text('Set Location'), findsOneWidget);
    });
  });
}
