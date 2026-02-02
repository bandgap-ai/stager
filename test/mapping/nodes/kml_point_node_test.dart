// Flutter packages
import 'package:flutter_test/flutter_test.dart';

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
      expect(node.properties.getProperty('id'), 'pt1');
      expect(node.isComposite, isFalse);
    });

    test('should store and retrieve coordinates via strongly-typed accessors', () {
      // Arrange
      final node = KMLPointNode(
        id: 'pt2',
        name: 'Geo Point',
        styleManager: manager,
      );

      // Act
      node.latitude = 45.0;
      node.longitude = -90.0;

      // Assert: Verify via accessors and underlying properties.
      expect(node.latitude, 45.0);
      expect(node.longitude, -90.0);
      expect(node.properties.getProperty('latitude'), 45.0);
      expect(node.properties.getProperty('longitude'), -90.0);
    });
  });
}
