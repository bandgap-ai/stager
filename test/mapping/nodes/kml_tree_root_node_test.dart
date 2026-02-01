// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/nodes/kml_tree_root_node.dart';
import 'package:stager_platform/mapping/style/kml_style.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// Unit tests for the [KMLTreeRootNode] class.
///
/// These tests verify that the root node correctly initializes as the entry
/// point for a KML tree and leverages the [KMLStylable] mixin for style 
/// resolution.
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
      expect(root.properties.getProperty('id'), 'root1');
      expect(root.properties.getProperty('name'), 'KML Document');
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
  });
}
