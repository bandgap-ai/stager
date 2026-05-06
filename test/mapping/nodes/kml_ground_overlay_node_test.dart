import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/nodes/kml_ground_overlay_node.dart';
import 'package:stager_platform/mapping/nodes/kml_geometry_node.dart';
import 'package:stager_platform/mapping/kml_icon.dart';
import 'package:stager_platform/mapping/lat_lon_box.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';
import 'package:stager_platform/system/typed_value.dart';

void main() {
  group('KMLGroundOverlayNode Tests', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('should correctly instantiate and inherit from KMLGeometryNode', () {
      // Create an overlay node and verify its type hierarchy and initial state.
      final node = KMLGroundOverlayNode(
        name: 'Historical Map',
        styleManager: manager,
        icon: const KMLIcon(href: 'icon.png'),
        latLonBox: const LatLonBox(north: 1, south: 0, east: 1, west: 0),
      );

      expect(node, isA<KMLGeometryNode>());
      expect(node.name, 'Historical Map');
      expect(node.isComposite, isFalse);
    });

    test('should initialize with provided icon and latLonBox as intrinsic members', () {
      // Setup icon and bounding box.
      const icon = KMLIcon(href: 'assets/map.png');
      const box = LatLonBox(north: 10, south: 0, east: 10, west: 0);

      // Instantiate the node and verify that attributes are stored in members.
      final node = KMLGroundOverlayNode(
        name: 'Data Overlay',
        styleManager: manager,
        icon: icon,
        latLonBox: box,
      );

      expect(node.icon, equals(icon));
      expect(node.latLonBox, equals(box));
    });

    test('should update attributes via intrinsic setters', () {
      final node = KMLGroundOverlayNode(
        name: 'Update Overlay',
        styleManager: manager,
        icon: const KMLIcon(href: 'old.png'),
        latLonBox: const LatLonBox(north: 1, south: 0, east: 1, west: 0),
      );

      const newIcon = KMLIcon(href: 'new.png');
      const newBox = LatLonBox(north: 2, south: 0, east: 2, west: 0);
      
      node.icon = newIcon;
      node.latLonBox = newBox;

      expect(node.icon, equals(newIcon));
      expect(node.latLonBox, equals(newBox));
    });

    test('should export and rehydrate correctly via toMap and fromMap', () {
      // Setup a node with specific overlay data.
      const icon = KMLIcon(href: 'persisted.png');
      const box = LatLonBox(north: 5, south: 4, east: 10, west: 9);
      final node = KMLGroundOverlayNode(
        name: 'Export Overlay',
        styleManager: manager,
        icon: icon,
        latLonBox: box,
      );

      // Export the full node state to a reified map.
      final map = node.toMap();

      // Verify that overlay-specific members are correctly captured.
      expect(map.containsKey('kml_icon'), isTrue);
      expect(map.containsKey('kml_latlonbox'), isTrue);
      
      // Perform rehydration into a new node instance.
      final newNode = KMLGroundOverlayNode(
        name: 'Blank',
        styleManager: manager,
        icon: const KMLIcon(href: 'temp.png'),
        latLonBox: const LatLonBox(north: 0, south: 0, east: 0, west: 0),
      );
      newNode.fromMap(map);

      // Confirm that both identity and complex overlay structures are restored.
      expect(newNode.name, 'Export Overlay');
      expect(newNode.icon, equals(icon));
      expect(newNode.latLonBox, equals(box));
    });
  });
}
