import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/lat_lon_box.dart';
import 'package:stager_platform/system/typed_value.dart';

void main() {
  group('LatLonBox Tests', () {
    test('should store and retrieve boundaries', () {
      const north = 40.8;
      const south = 40.7;
      const east = -73.9;
      const west = -74.0;

      const box = LatLonBox(
        north: north,
        south: south,
        east: east,
        west: west,
      );

      expect(box.north, north);
      expect(box.south, south);
      expect(box.east, east);
      expect(box.west, west);
    });

    test('should support value-based equality', () {
      const box1 = LatLonBox(north: 1, south: 0, east: 1, west: 0);
      const box2 = LatLonBox(north: 1, south: 0, east: 1, west: 0);
      const box3 = LatLonBox(north: 2, south: 0, east: 1, west: 0);

      expect(box1, equals(box2));
      expect(box1.hashCode, equals(box2.hashCode));
      expect(box1, isNot(equals(box3)));
    });

    test('should export and rehydrate correctly via toMap and fromMap', () {
      const box = LatLonBox(north: 45.0, south: 44.0, east: -90.0, west: -91.0);
      final map = box.toMap();

      // Verify that the map contains reified typed values.
      expect(map['north'], const TypedValue<double>(45.0));
      expect(map['south'], const TypedValue<double>(44.0));

      // Rehydrate.
      final newBox = LatLonBox.fromMap(map);
      expect(newBox, equals(box));
    });
  });
}
