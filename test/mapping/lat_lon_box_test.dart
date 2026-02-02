// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/lat_lon_box.dart';

/// Unit tests for the [LatLonBox] class.
///
/// These tests verify that the LatLonBox correctly stores geographic 
/// boundaries and provides a descriptive string representation.
void main() {
  group('LatLonBox', () {
    test('should store and retrieve boundaries', () {
      // Arrange
      const north = 40.8;
      const south = 40.7;
      const east = -73.9;
      const west = -74.0;

      // Act
      const box = LatLonBox(
        north: north,
        south: south,
        east: east,
        west: west,
      );

      // Assert
      expect(box.north, north);
      expect(box.south, south);
      expect(box.east, east);
      expect(box.west, west);
    });

    test('toString should contain all boundary values', () {
      // Arrange
      const box = LatLonBox(
        north: 10.0,
        south: 5.0,
        east: 20.0,
        west: 15.0,
      );

      // Act & Assert
      final stringRep = box.toString();
      expect(stringRep, contains('north: 10.0'));
      expect(stringRep, contains('south: 5.0'));
      expect(stringRep, contains('east: 20.0'));
      expect(stringRep, contains('west: 15.0'));
    });
  });
}
