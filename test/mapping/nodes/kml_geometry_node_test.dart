// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/nodes/kml_geometry_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// A concrete implementation of [KMLGeometryNode] for testing purposes.
class TestGeometryNode extends KMLGeometryNode {
  TestGeometryNode({
    required super.id,
    required super.name,
    required super.styleManager,
    super.styleUrl = 'default',
  });
}

void main() {
  group('KMLGeometryNode', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('should correctly instantiate and inherit from ConcreteLeafNode', () {
      // Arrange & Act
      final node = TestGeometryNode(
        id: 'geo1',
        name: 'Geometry 1',
        styleManager: manager,
      );

      // Assert
      expect(node.properties.get<String>('id'), 'geo1');
      expect(node.properties.get<String>('name'), 'Geometry 1');
      expect(node.isComposite, isFalse);
    });

    test('should support style resolution via KMLStylable', () {
      // Arrange
      final node = TestGeometryNode(
        id: 'geo2',
        name: 'Styled Geometry',
        styleManager: manager,
      );

      // Act & Assert
      expect(node.kmlStyle.id, 'default');
    });
  });
}
