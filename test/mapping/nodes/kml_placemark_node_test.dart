// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/nodes/kml_placemark_node.dart';
import 'package:stager_platform/mapping/nodes/kml_feature_node.dart';
import 'package:stager_platform/mapping/nodes/kml_geometry_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// A concrete implementation of [KMLGeometryNode] for testing purposes.
class MockGeometryNode extends KMLGeometryNode {
  MockGeometryNode({
    required super.id,
    required super.name,
    required super.styleManager,
    super.styleUrl = 'default',
  });
}

void main() {
  group('KMLPlacemarkNode', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('should correctly instantiate and inherit from KMLFeatureNode', () {
      // Arrange & Act
      final node = KMLPlacemarkNode(
        id: 'pm1',
        name: 'My Placemark',
        styleManager: manager,
      );

      // Assert
      expect(node, isA<KMLFeatureNode>());
      expect(node.properties.get<String>('id'), 'pm1');
      expect(node.isComposite, isTrue);
    });

    test('isMultiGeometry should return true if multiple geometry nodes are present', () {
      // Arrange
      final node = KMLPlacemarkNode(
        id: 'pm2',
        name: 'Multi Placemark',
        styleManager: manager,
      );
      
      // Act & Assert: Initially false (0 children)
      expect(node.isMultiGeometry, isFalse);

      // Add one geometry child
      node.addChild(MockGeometryNode(id: 'pt1', name: 'P1', styleManager: manager));
      expect(node.isMultiGeometry, isFalse); // Still false (1 child)

      // Add second geometry child
      node.addChild(MockGeometryNode(id: 'pt2', name: 'P2', styleManager: manager));
      expect(node.isMultiGeometry, isTrue); // Now true (2 children)
    });
  });
}
