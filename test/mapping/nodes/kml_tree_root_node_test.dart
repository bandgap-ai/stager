// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// External packages
import 'package:latlong2/latlong.dart';

// Project files
import 'package:stager_platform/mapping/kml_hole.dart';
import 'package:stager_platform/mapping/nodes/kml_path_node.dart';
import 'package:stager_platform/mapping/nodes/kml_placemark_node.dart';
import 'package:stager_platform/mapping/nodes/kml_point_node.dart';
import 'package:stager_platform/mapping/nodes/kml_polygon_node.dart';
import 'package:stager_platform/mapping/nodes/kml_tree_root_node.dart';
import 'package:stager_platform/mapping/style/kml_style.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// Unit tests for the [KMLTreeRootNode] class.
///
/// These tests verify that the root node correctly initializes as the entry
/// point for a KML tree and leverages the [KMLStylable] mixin for style 
/// resolution. It also verifies the specialized geographic summarization logic.
void main() {
  group('KMLTreeRootNode', () {
    late KMLStyleManager manager;

    setUp(() {
      // Initialize a fresh style manager for each test to ensure isolation.
      manager = KMLStyleManager();
    });

    /// Verifies that the constructor correctly applies the 'default' styleUrl 
    /// and initializes metadata.
    test('Constructor correctly initializes with default styleUrl', () {
      // Arrange & Act
      final root = KMLTreeRootNode(
        id: 'root1',
        name: 'KML Document',
        styleManager: manager,
      );

      // Assert
      expect(root.properties.get<String>('id'), 'root1');
      expect(root.properties.get<String>('name'), 'KML Document');
      expect(root.styleUrl, 'default');
      expect(root.kmlStyle.id, 'default');
    });

    /// Verifies that the root node correctly resolves a style registered 
    /// in the manager.
    test('Resolves registered style from manager', () {
      // Arrange
      const style = KMLStyle(id: 'rootStyle');
      manager.registerStyle(style);

      // Act
      final root = KMLTreeRootNode(
        id: 'root2',
        name: 'Styled Root',
        styleManager: manager,
        styleUrl: 'rootStyle',
      );

      // Assert
      expect(root.kmlStyle, equals(style));
    });

    /// Verifies that the root node correctly inherits traversal capabilities 
    /// from the base ConcreteTreeNode class.
    test('Inherits traversal capabilities from ConcreteTreeNode', () {
      // Arrange & Act
      final root = KMLTreeRootNode(
        id: 'root3',
        name: 'Traversable Root',
        styleManager: manager,
      );

      // Assert: Verify it provides functional iterators for tree traversal.
      expect(root.depthFirstIterator, isNotNull);
      expect(root.breadthFirstIterator, isNotNull);
    });

    /// Verifies that accessing the style throws an ArgumentError if the 
    /// styleUrl references a non-existent style ID.
    test('Throws ArgumentError for missing non-default style', () {
      // Arrange
      final root = KMLTreeRootNode(
        id: 'root4',
        name: 'Invalid Style Root',
        styleManager: manager,
        styleUrl: 'bad-style',
      );

      // Assert: The mixin delegates to the manager, which enforces valid lookups.
      expect(() => root.kmlStyle, throwsArgumentError);
    });

    group('summarize()', () {
      test('throws StateError if tree contains no geographic data', () {
        // Arrange
        final root = KMLTreeRootNode(
          id: 'root_empty',
          name: 'Empty Root',
          styleManager: manager,
        );

        // Act & Assert
        expect(() => root.summarize(), throwsStateError);
      });

      test('correctly summarizes a complex KML tree', () {
        // Arrange
        final root = KMLTreeRootNode(
          id: 'root_complex',
          name: 'Complex Root',
          styleManager: manager,
        );

        // Level 2: Placemark with Point
        final pm1 = KMLPlacemarkNode(
          id: 'pm1',
          name: 'Point Placemark',
          styleManager: manager,
        );
        pm1.addChild(KMLPointNode(
          id: 'pt1',
          name: 'Point',
          styleManager: manager,
          location: const LatLng(10, 10),
        ));
        root.addChild(pm1);

        // Level 2: Placemark with Path
        final pm2 = KMLPlacemarkNode(
          id: 'pm2',
          name: 'Path Placemark',
          styleManager: manager,
        );
        pm2.addChild(KMLPathNode(
          id: 'path1',
          name: 'Path',
          styleManager: manager,
          outline: [const LatLng(20, 20), const LatLng(25, 25)],
        ));
        root.addChild(pm2);

        // Level 2: Placemark with Polygon + Hole
        final pm3 = KMLPlacemarkNode(
          id: 'pm3',
          name: 'Polygon Placemark',
          styleManager: manager,
        );
        pm3.addChild(KMLPolygonNode(
          id: 'poly1',
          name: 'Polygon',
          styleManager: manager,
          outline: [
            const LatLng(0, 0),
            const LatLng(5, 0),
            const LatLng(5, 5),
            const LatLng(0, 5),
            const LatLng(0, 0),
          ],
          holes: [
            KMLHole(points: [const LatLng(1, 1), const LatLng(2, 1), const LatLng(1, 1)]),
          ],
        ));
        root.addChild(pm3);

        // Act
        final summary = root.summarize();

        // Assert: Node counts
        // Root(1) + PMs(3) + Pt(1) + Path(1) + Poly(1) = 7
        expect(summary.totalNodes, 7);
        
        // Assert: Node counts by level
        expect(summary.nodeCountsByLevel[1], 1); // Root
        expect(summary.nodeCountsByLevel[2], 3); // PMs
        expect(summary.nodeCountsByLevel[3], 3); // Geometry nodes

        // Assert: Center point calculation
        // Points: (10,10), (20,20), (25,25), (0,0), (5,0), (5,5), (0,5), (0,0), (1,1), (2,1), (1,1)
        // Lats: 10 + 20 + 25 + 0 + 5 + 5 + 0 + 0 + 1 + 2 + 1 = 69
        // Lngs: 10 + 20 + 25 + 0 + 0 + 5 + 5 + 0 + 1 + 1 + 1 = 68
        // Count: 11
        expect(summary.centerPoint?.latitude, closeTo(69 / 11, 0.0001));
        expect(summary.centerPoint?.longitude, closeTo(68 / 11, 0.0001));

        // Assert: Convex hull
        expect(summary.boundingPolygon.length, greaterThanOrEqualTo(3));

        // Assert: Additional stats
        expect(summary.additionalStats['kml_points'], 1);
        expect(summary.additionalStats['kml_paths'], 1);
        expect(summary.additionalStats['kml_polygons'], 1);
      });
    });
  });
}
