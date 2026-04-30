import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/nodes/kml_polygon_node.dart';
import 'package:stager_platform/mapping/nodes/kml_geometry_node.dart';
import 'package:stager_platform/mapping/kml_hole.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';
import 'package:stager_platform/system/point.dart';
import 'package:stager_platform/system/stager_context.dart';
import 'package:stager_platform/system/typed_value.dart';

void main() {
  group('KMLPolygonNode Tests', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('should correctly instantiate and inherit from KMLGeometryNode', () {
      // Create a polygon node and verify its type hierarchy and initial name.
      final node = KMLPolygonNode(
        name: 'My Polygon',
        styleManager: manager,
        outline: [],
      );

      expect(node, isA<KMLGeometryNode>());
      expect(node.name, 'My Polygon');
      expect(node.isComposite, isFalse);
    });

    test('should initialize with provided outline and holes as intrinsic members', () {
      // Setup an outer boundary and an inner hole using the Point abstraction.
      final outline = [
        Point(coords: [-70.0, 40.0]),
        Point(coords: [-71.0, 41.0]),
        Point(coords: [-71.0, 40.0]),
        Point(coords: [-70.0, 40.0]),
      ];
      final holes = [
        KMLHole(points: [Point(coords: [0.0, 0.0]), Point(coords: [1.0, 1.0])]),
      ];

      // Instantiate the node and verify that geometry is stored in intrinsic members.
      final node = KMLPolygonNode(
        name: 'Initial Polygon',
        styleManager: manager,
        outline: outline,
        holes: holes,
      );

      expect(node.outline, equals(outline));
      expect(node.holes, equals(holes));

      // Try the builder
      final node2 = buildKMLPolygonNode(StagerContext(node.toMap()));
      expect(node2.outline, equals(outline));
      expect(node2.holes, equals(holes));
    });

    test('should update geometry via intrinsic setters', () {
       final node = KMLPolygonNode(
        name: 'Update Polygon',
        styleManager: manager,
        outline: [],
      );

      final newOutline = [Point(coords: [1.0, 1.0])];
      final newHoles = [KMLHole(points: [Point(coords: [0.5, 0.5])])];
      
      node.outline = newOutline;
      node.holes = newHoles;

      expect(node.outline, equals(newOutline));
      expect(node.holes, equals(newHoles));
    });

    test('should export and rehydrate correctly via toMap and fromMap', () {
      // Setup a complex polygon with an outline and a hole.
      final outline = [Point(coords: [2.0, 3.0])];
      final holes = [KMLHole(points: [Point(coords: [2.1, 3.1])])];
      final node = KMLPolygonNode(
        name: 'Export Polygon',
        styleManager: manager,
        outline: outline,
        holes: holes,
      );

      // Export the full node state to a reified map.
      final map = node.toMap();

      // Verify that geometry members are correctly captured in the tagged record set.
      expect(map.containsKey('outline'), isTrue);
      expect(map.containsKey('kml_holes'), isTrue);
      
      // Perform rehydration into a new node instance.
      final newNode = KMLPolygonNode(
        name: 'Blank',
        styleManager: manager,
        outline: [],
      );
      newNode.fromMap(map);

      // Confirm that both identity and complex geometric structures are restored.
      expect(newNode.name, 'Export Polygon');
      expect(newNode.outline, equals(outline));
      expect(newNode.holes, equals(holes));
    });
  });
}
