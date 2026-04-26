import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/nodes/kml_point_node.dart';
import 'package:stager_platform/mapping/nodes/kml_geometry_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';
import 'package:stager_platform/system/point.dart';

void main() {
  group('KMLPointNode Tests', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('should correctly instantiate and inherit from KMLGeometryNode', () {
      // Create a node and verify its type and initial metadata.
      final node = KMLPointNode(
        name: 'My Point',
        styleManager: manager,
      );

      expect(node, isA<KMLGeometryNode>());
      expect(node.name, 'My Point');
      expect(node.isComposite, isFalse);
    });

    test('should initialize with a default position', () {
      // Verify that the node initializes to the platform's default spatial 
      // origin (defined in LeafNode).
      final node = KMLPointNode(
        name: 'Default Point',
        styleManager: manager,
      );

      // The default Point coords are typically [0.0, 0.0, 0.0] or the platform 
      // standard coordinates.
      expect(node.position, isA<Point>());
      expect(node.position.x, isNotNull);
    });

    test('should store and retrieve location via the position member', () {
      // Setup a specific geographic location.
      final testLocation = Point(coords: [-90.0, 45.0]);
      
      // Act
      final node = KMLPointNode(
        name: 'Geo Point',
        styleManager: manager,
      )..position = testLocation;

      // Assert: Verify retrieval via the intrinsic position member.
      expect(node.position, equals(testLocation));
      expect(node.position.x, -90.0);
      expect(node.position.y, 45.0);
    });

    test('should participate in cascading rehydration', () {
       // Create a reified map representing a dehydrated KML point.
      final testLocation = Point(coords: [1.0, 2.0]);
      final node = KMLPointNode(
        name: 'Persisted Point',
        styleManager: manager,
      )..position = testLocation;

      final map = node.toMap();

      // Verify that the position is correctly captured in the export.
      expect(map.containsKey('position'), isTrue);
      
      // Create a blank node and rehydrate it.
      final newNode = KMLPointNode(
        name: 'Blank',
        styleManager: manager,
      );
      newNode.fromMap(map);

      // Confirm rehydration of identity and spatial data.
      expect(newNode.name, 'Persisted Point');
      expect(newNode.position, equals(testLocation));
    });
  });
}
