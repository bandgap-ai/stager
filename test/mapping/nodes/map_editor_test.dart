// Flutter packages
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/map_editor.dart';
import 'package:stager_platform/mapping/map_state.dart';

/// Unit tests for the [MapEditor] widget.
///
/// These tests verify that the MapEditor correctly loads its state and 
/// renders the expected FlutterMap components.
void main() {
  group('MapEditor Widget Tests', () {
    testWidgets('should load and contain a FlutterMap widget', (WidgetTester tester) async {
      // Arrange
      const state = MapState();
      
      // Act
      await tester.pumpWidget(
        const MaterialApp(
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
  });
}
