import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/nodes/kml_placemark_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';
import 'package:stager_platform/system/selection_visitor.dart';
import 'package:stager_platform/tree/concrete_leaf_node.dart';

/// Unit tests for [GenericSelectionVisitor].
void main() {
  group('GenericSelectionVisitor Tests', () {
    test('should initialize with the provided default value', () {
      // Arrange & Act
      final visitor = GenericSelectionVisitor<String>('default');

      // Assert
      expect(visitor.value, 'default');
    });

    test('should update value when visit is called with correct type', () {
      // Arrange
      final visitor = GenericSelectionVisitor<int>(0);

      // Act
      visitor.visit(42);

      // Assert
      expect(visitor.value, 42);
    });

    test('should work with ConcreteLeafNode', () {
      // Arrange
      final initialNode = ConcreteLeafNode(id: '0', name: 'Initial');
      final visitor = GenericSelectionVisitor<ConcreteLeafNode>(initialNode);
      final newNode = ConcreteLeafNode(id: '1', name: 'New Node');

      // Act
      visitor.visit(newNode);

      // Assert
      expect(visitor.value, newNode);
      expect(visitor.value.properties.getProperty('name'), 'New Node');
    });

    test('should work with KMLPlacemarkNode', () {
      // Arrange
      final styleManager = KMLStyleManager();
      final initialNode = KMLPlacemarkNode(
        id: 'p0',
        name: 'Initial Placemark',
        styleManager: styleManager,
      );
      final visitor = GenericSelectionVisitor<KMLPlacemarkNode>(initialNode);
      final newNode = KMLPlacemarkNode(
        id: 'p1',
        name: 'New Placemark',
        styleManager: styleManager,
      );

      // Act
      visitor.visit(newNode);

      // Assert
      expect(visitor.value, newNode);
      expect(visitor.value.properties.getProperty('name'), 'New Placemark');
    });

    test('should work with complex types', () {
      // Arrange
      final initialList = [1, 2, 3];
      final visitor = GenericSelectionVisitor<List<int>>(initialList);
      final newList = [4, 5, 6];

      // Act
      visitor.visit(newList);

      // Assert
      expect(visitor.value, newList);
      expect(visitor.value, isNot(same(initialList)));
    });
  });
}
