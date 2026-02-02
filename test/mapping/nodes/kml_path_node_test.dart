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
      );

      // Assert
      expect(node, isA<KMLGeometryNode>());
      expect(node.properties.getProperty('id'), 'path1');
      expect(node.isComposite, isFalse);
    });

    test('should store and retrieve outline via strongly-typed accessors', () {
      // Arrange
      final node = KMLPathNode(
        id: 'path2',
        name: 'River Path',
        styleManager: manager,
      );
      final points = [
        LatLng(40.0, -70.0),
        LatLng(41.0, -71.0),
      ];

      // Act
      node.outline = points;

      // Assert: Verify via accessor.
      expect(node.outline, equals(points));
      
      // Assert: Verify internal storage format (List of Maps) for Stager compatibility.
      final rawOutline = node.properties.getProperty('outline') as List;
      expect(rawOutline.length, 2);
      expect(rawOutline[0]['latitude'], 40.0);
      expect(rawOutline[1]['longitude'], -71.0);
    });
  });
}
