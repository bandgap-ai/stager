import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/nodes/kml_path_node.dart';
import 'package:stager_platform/mapping/nodes/kml_geometry_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';
import 'package:stager_platform/system/point.dart';
import 'package:stager_platform/system/typed_value.dart';

void main() {
  group('KMLPathNode Tests', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('should correctly instantiate and inherit from KMLGeometryNode', () {
      // Create a node with an empty outline and verify its type and initial state.
      final node = KMLPathNode(
        name: 'My Path',
        styleManager: manager,
        outline: [],
      );

      expect(node, isA<KMLGeometryNode>());
      expect(node.name, 'My Path');
      expect(node.isComposite, isFalse);
    });

    test('should initialize and retrieve outline as intrinsic member', () {
      // Setup a set of coordinates using the new Point abstraction.
      final points = [
        Point(coords: [-70.0, 40.0]),
        Point(coords: [-71.0, 41.0]),
      ];

      // Instantiate the node and verify that the points are stored as members.
      final node = KMLPathNode(
        name: 'Initial Path',
        styleManager: manager,
        outline: points,
      );

      expect(node.outline, equals(points));
    });

    test('should update outline via setter', () {
       final node = KMLPathNode(
        name: 'Update Path',
        styleManager: manager,
        outline: [],
      );

      final newPoints = [Point(coords: [1.0, 1.0])];
      node.outline = newPoints;

      expect(node.outline, equals(newPoints));
    });

    test('should export and rehydrate correctly via toMap and fromMap', () {
      // Setup a node with specific path geometry.
      final points = [Point(coords: [2.0, 3.0])];
      final node = KMLPathNode(
        name: 'Export Path',
        styleManager: manager,
        outline: points,
      );

      // Export to reified map.
      final map = node.toMap();

      // Verify that the outline is exported as a reified list of points.
      expect(map.containsKey('outline'), isTrue);
      final reifiedOutline = map['outline']! as List<Object>;
      expect(reifiedOutline.length, 1);
      
      // Perform rehydration from the map into a new node.
      final newNode = KMLPathNode(
        name: 'Blank',
        styleManager: manager,
        outline: [],
      );
      newNode.fromMap(map);

      // Confirm that the geometry is faithfully restored.
      expect(newNode.name, 'Export Path');
      expect(newNode.outline, equals(points));
    });
  });
}
