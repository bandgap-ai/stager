// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// External packages
import 'package:latlong2/latlong.dart';

// Project files
import 'package:stager_platform/mapping/kml_hole.dart';

/// Unit tests for the [KMLHole] class.
///
/// These tests verify that the KMLHole correctly stores a list of geographic 
/// coordinates representing an inner boundary and provides a descriptive 
/// string representation.
void main() {
  group('KMLHole', () {
    test('should store and retrieve coordinate points', () {
      // Arrange
      final points = [
        LatLng(40.771, -73.970),
        LatLng(40.775, -73.968),
        LatLng(40.771, -73.965),
        LatLng(40.771, -73.970),
      ];

      // Act
      final hole = KMLHole(points: points);

      // Assert
      expect(hole.points, equals(points));
      expect(hole.points.length, 4);
    });

    test('toString should contain the number of points', () {
      // Arrange
      final points = [
        LatLng(0.0, 0.0),
        LatLng(1.0, 1.0),
        LatLng(0.0, 1.0),
        LatLng(0.0, 0.0),
      ];
      final hole = KMLHole(points: points);

      // Act & Assert
      expect(hole.toString(), contains('points: 4'));
    });
  });
}
