// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/nodes/kml_ground_overlay_node.dart';
import 'package:stager_platform/mapping/nodes/kml_geometry_node.dart';
import 'package:stager_platform/mapping/kml_icon.dart';
import 'package:stager_platform/mapping/lat_lon_box.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// Unit tests for the [KMLGroundOverlayNode] class.
void main() {
  group('KMLGroundOverlayNode', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('should correctly instantiate and inherit from KMLGeometryNode', () {
      // Arrange & Act
      final node = KMLGroundOverlayNode(
        id: 'overlay1',
        name: 'Historical Map',
        styleManager: manager,
        icon: const KMLIcon(href: 'icon.png'),
        latLonBox: const LatLonBox(north: 1, south: 0, east: 1, west: 0),
      );

      // Assert
      expect(node, isA<KMLGeometryNode>());
      expect(node.properties.getProperty('id'), 'overlay1');
      expect(node.isComposite, isFalse);
    });

    test('should initialize with provided icon and latLonBox', () {
      // Arrange
      const icon = KMLIcon(href: 'assets/map.png');
      const box = LatLonBox(north: 10, south: 0, east: 10, west: 0);

      // Act
      final node = KMLGroundOverlayNode(
        id: 'overlay2',
        name: 'Data Overlay',
        styleManager: manager,
        icon: icon,
        latLonBox: box,
      );

      // Assert: Verify via accessors.
      expect(node.icon, equals(icon));
      expect(node.latLonBox, equals(box));
    });

  });
}
