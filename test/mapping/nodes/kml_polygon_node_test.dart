// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// External packages
import 'package:latlong2/latlong.dart';

// Project files
import 'package:stager_platform/mapping/nodes/kml_polygon_node.dart';
import 'package:stager_platform/mapping/nodes/kml_geometry_node.dart';
import 'package:stager_platform/mapping/kml_hole.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// Unit tests for the [KMLPolygonNode] class.
void main() {
  group('KMLPolygonNode', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('should correctly instantiate and inherit from KMLGeometryNode', () {
      // Arrange & Act
      final node = KMLPolygonNode(
        id: 'poly1',
        name: 'My Polygon',
        styleManager: manager,
        outline: [],
      );

      // Assert
      expect(node, isA<KMLGeometryNode>());
      expect(node.properties.get<String>('id'), 'poly1');
      expect(node.isComposite, isFalse);
    });

    test('should initialize with the provided outline and holes', () {
      // Arrange
      final outline = [
        LatLng(40.0, -70.0),
        LatLng(41.0, -71.0),
        LatLng(40.0, -71.0),
        LatLng(40.0, -70.0),
      ];
      final holes = [
        KMLHole(points: [LatLng(0, 0), LatLng(1, 1), LatLng(0, 1)]),
      ];

      // Act
      final node = KMLPolygonNode(
        id: 'poly_init',
        name: 'Initial Polygon',
        styleManager: manager,
        outline: outline,
        holes: holes,
      );

      // Assert
      expect(node.outline, equals(outline));
      expect(node.holes, equals(holes));
    });

    test('should retrieve outline and holes via strongly-typed accessors', () {
      // Arrange
      final outline = [LatLng(0, 0), LatLng(1, 1), LatLng(0, 1)];
      final holes = [KMLHole(points: [LatLng(0.1, 0.1), LatLng(0.2, 0.2), LatLng(0.1, 0.2)])];
      
      final node = KMLPolygonNode(
        id: 'poly2',
        name: 'Geo Polygon',
        styleManager: manager,
        outline: outline,
        holes: holes,
      );

      // Act
      final retrievedOutline = node.outline;
      final retrievedHoles = node.holes;

      // Assert
      expect(retrievedOutline, equals(outline));
      expect(retrievedHoles, equals(holes));
      
      // Assert: Verify internal storage in NodeProperties.
      expect(node.properties.get<List<LatLng>>('outline'), equals(outline));
      expect(node.properties.get<List<KMLHole>>('kml_holes'), equals(holes));
    });

  });
}
