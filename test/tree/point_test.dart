import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:stager_platform/builders/stager_context.dart';
import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/system/point.dart';

void main() {
  group('Point Properties', () {
    test('Test setting up a point',() {
      Point point = Point();
      // Default values should be set correctly.
      expect(point.x, 0.0);
      expect(point.y, 0.0);
      expect(point.z, 0.0);
      expect(point.system, CoordinateSystem.wgs84);
      expect(point.coords, [0.0, 0.0, 0.0]);
      // Inject some points
      point = Point(coords: [1.0, 2.0, 3.0], system: CoordinateSystem.grid);
      expect(point.x, 1.0);
      expect(point.y, 2.0);
      expect(point.z, 3.0);
      expect(point.system, CoordinateSystem.grid);
      expect(point.coords, [1.0, 2.0, 3.0]);
    });

    test('Test equality', () {
      Point point1 = Point();
      Point point2 = Point();
      expect(point1 == point2, isTrue);
      expect(point1.hashCode, point2.hashCode);
      Point point3 = Point(coords: [1.0, 2.0, 3.0], system: CoordinateSystem.grid);
      expect(point1 == point3, isFalse);
      expect(point1.hashCode, isNot(point3.hashCode));
      // Test something that is a little more robust.
      Point point4 = Point(coords: [-77.96876463574121, 38.98951052421746]);
      Point point5 = Point(coords: [-77.96876463574121, 38.98951052421746]);
      expect(point4 == point5, isTrue);
      expect(point4.hashCode, point5.hashCode);
    });
  });

  group('Point Conversion', () {
    test('Test converting a point to LatLng',() {
      Point point = Point(coords: [-74.0060, 40.7128]);
      // Test normal conversion with the default converter
      LatLng latLng = point.toLatLng();
      expect(latLng.longitude, -74.0060);
      expect(latLng.latitude, 40.7128);
      // Try to catch the exception if there's a problem. In this case, state
      // (projected) coordinates are not converted to LatLng by default.
      point = Point(coords: [1.0, 2.0, 3.0], system: CoordinateSystem.projected);
      expect(() => point.toLatLng(), throwsA(isA<PointConversionException>()));
      // Try for a 1D system
      point = Point(coords: [1.0], system: CoordinateSystem.wgs84);
      expect(() => point.toLatLng(), throwsA(isA<PointConversionException>()));
      // Check the content of the exception
      try {
        point.toLatLng();
      } catch (e) {
        expect(e.toString(), 'PointConversionException: Cannot convert to LatLng'
            ' for system wgs84 and coordinates [1.0].');
      }
      // Try a custom converter
      point = Point(coords: [1.0, 2.0],
          system: CoordinateSystem.wgs84,
          converter: (coords, system) => LatLng(6.0, 7.0));
      latLng = point.toLatLng();
      expect(latLng.latitude, 6.0);
      expect(latLng.longitude, 7.0);
    });

    test('Test toMap()', () {
      Point point = Point(coords: [1.0, 2.0, 3.0], system: CoordinateSystem.grid);
      print(point.toMap());
      var pointMap = point.toMap();
      final coords = pointMap['coords'] as List<double>;
      expect(coords, [1.0, 2.0, 3.0]);
      expect(pointMap['system'] is String, true);
      expect(pointMap['system'], 'grid');
      // Create another point with the default coordinate system and make sure
      // that wgs84 doesn't show up in the map.
      point = Point(coords: [1.0, 2.0, 3.0]);
      pointMap = point.toMap();
      expect(pointMap['system'] is String, false);
    });

    test('Test toString()',() {
      Point point = Point(coords: [1.0, 2.0, 3.0], system: CoordinateSystem.grid);
      expect(point.toString(), '1.0,2.0,3.0,grid');
    });
  });

  group('Point Builder', () {
    test('Test the basic builder for the point',() {
      Point point = Point(coords: [1.0, 2.0, 3.0], system: CoordinateSystem.grid);
      StagerContext context = StagerContext(point.toMap());
      Point builtPoint = buildPoint(context);
      expect(point.toString(), builtPoint.toString());
      // Send a point with the default coordinate system and make sure that the
      // build function automatically defaults to wgs84.
      point = Point(coords: [1.0, 2.0, 3.0]);
      context = StagerContext(point.toMap());
      builtPoint = buildPoint(context);
      expect(point.toString(), builtPoint.toString());
      expect(builtPoint.system, CoordinateSystem.wgs84);
    });
  });
}