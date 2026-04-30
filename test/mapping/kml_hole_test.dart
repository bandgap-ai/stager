import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/kml_hole.dart';
import 'package:stager_platform/system/point.dart';
import 'package:stager_platform/system/typed_value.dart';

void main() {
  group('KMLHole Tests', () {
    test('should store and retrieve Point coordinates', () {
      // Create a set of coordinates using the new Point abstraction.
      final points = [
        Point(coords: [-73.970, 40.771]),
        Point(coords: [-73.968, 40.775]),
        Point(coords: [-73.965, 40.771]),
        Point(coords: [-73.970, 40.771]),
      ];

      // Instantiate the hole and verify its contents.
      final hole = KMLHole(points: points);

      expect(hole.points, equals(points));
      expect(hole.points.length, 4);
    });

    test('should support value-based equality', () {
      // Create two identical hole instances.
      final hole1 = KMLHole(points: [Point(coords: [1.0, 1.0])]);
      final hole2 = KMLHole(points: [Point(coords: [1.0, 1.0])]);
      
      // Verify that they are considered equal.
      expect(hole1, equals(hole2));
      expect(hole1.hashCode, equals(hole2.hashCode));
    });

    test('should export and rehydrate correctly via toMap and fromMap', () {
      // Setup a hole with specific geometry.
      final points = [Point(coords: [10.0, 20.0])];
      final hole = KMLHole(points: points);

      // Export to reified map.
      final map = hole.toMap();

      // Verify that the points are exported as a reified list of maps.
      expect(map.containsKey('points'), isTrue);
      final reifiedPoints = map['points'] as List<Object>;

      // Perform rehydration from the map.
      final newHole = KMLHole.fromMap(map);

      // Confirm that the geometry is faithfully restored.
      expect(newHole.points, equals(points));
    });
  });
}
