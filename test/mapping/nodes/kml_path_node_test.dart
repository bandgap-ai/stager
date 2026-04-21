// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// External packages
import 'package:latlong2/latlong.dart';

// Project files
import 'package:stager_platform/mapping/nodes/kml_path_node.dart';
import 'package:stager_platform/mapping/nodes/kml_geometry_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// Unit tests for the [KMLPathNode] class.
void main() {
  group('KMLPathNode', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('should correctly instantiate and inherit from KMLGeometryNode', () {
      // Arrange & Act
      final node = KMLPathNode(
        id: 'path1',
        name: 'My Path',
        styleManager: manager,
        outline: [],
      );

      // Assert
      expect(node, isA<KMLGeometryNode>());
      expect(node.properties.get<String>('id'), 'path1');
      expect(node.isComposite, isFalse);
    });

    test('should initialize with the provided outline', () {
      // Arrange
      final points = [
        LatLng(40.0, -70.0),
        LatLng(41.0, -71.0),
      ];

      // Act
      final node = KMLPathNode(
        id: 'path_init',
        name: 'Initial Path',
        styleManager: manager,
        outline: points,
      );

      // Assert
      expect(node.outline, equals(points));
    });

    test('should retrieve outline via strongly-typed accessor', () {
      // Arrange
      final points = [
        LatLng(40.0, -70.0),
        LatLng(41.0, -71.0),
      ];
      final node = KMLPathNode(
        id: 'path2',
        name: 'River Path',
        styleManager: manager,
        outline: points,
      );

      // Act
      final retrievedOutline = node.outline;

      // Assert: Verify via accessor.
      expect(retrievedOutline, equals(points));
      
      // Assert: Verify internal storage in NodeProperties.
      final rawOutline = node.properties.get<List<LatLng>>('outline');
      expect(rawOutline.length, 2);
      expect(rawOutline[0], equals(points[0]));
    });

  });
}
