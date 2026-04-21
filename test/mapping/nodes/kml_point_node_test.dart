// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// External packages
import 'package:latlong2/latlong.dart';

// Project files
import 'package:stager_platform/mapping/nodes/kml_point_node.dart';
import 'package:stager_platform/mapping/nodes/kml_geometry_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// Unit tests for the [KMLPointNode] class.
void main() {
  group('KMLPointNode', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('should correctly instantiate and inherit from KMLGeometryNode', () {
      // Arrange & Act
      final node = KMLPointNode(
        id: 'pt1',
        name: 'My Point',
        styleManager: manager,
      );

      // Assert
      expect(node, isA<KMLGeometryNode>());
      expect(node.properties.get<String>('id'), 'pt1');
      expect(node.isComposite, isFalse);
    });

    test('should initialize with a default position of (0, 0)', () {
      // Arrange & Act
      final node = KMLPointNode(
        id: 'pt_default',
        name: 'Default Point',
        styleManager: manager,
      );

      // Assert
      expect(node.location, equals(const LatLng(0, 0)));
    });

    test('should store and retrieve coordinates via strongly-typed accessors', () {
      // Arrange
      final testLocation = LatLng(45.0, -90.0);
      
      // Act
      final node = KMLPointNode(
        id: 'pt2',
        name: 'Geo Point',
        styleManager: manager,
        location: testLocation,
      );

      // Assert: Verify via accessors and underlying properties.
      expect(node.location, equals(testLocation));
      expect(node.properties.get<LatLng>('position'), equals(testLocation));
    });

  });
}
