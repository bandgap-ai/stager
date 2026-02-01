// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/nodes/kml_folder_node.dart';
import 'package:stager_platform/mapping/style/kml_style.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// Unit tests for the [KMLFolderNode] class.
///
/// These tests verify that folder nodes correctly initialize their properties
/// and leverage the [KMLStylable] mixin for robust style resolution.
void main() {
  group('KMLFolderNode', () {
    late KMLStyleManager manager;

    setUp(() {
      // Initialize a fresh style manager for each test to ensure isolation.
      manager = KMLStyleManager();
    });

    /// Verifies that the constructor correctly applies the 'default' styleUrl 
    /// when none is provided, and that the mixin resolves it to a default 
    /// style instance.
    test('Constructor correctly initializes with default styleUrl', () {
      // Arrange & Act
      final folder = KMLFolderNode(
        id: 'f1',
        name: 'Default Folder',
        styleManager: manager,
      );

      // Assert
      expect(folder.styleUrl, 'default');
      // The KMLStylable mixin should return a spec-compliant default KMLStyle 
      // when the ID is 'default' and not present in the manager.
      expect(folder.kmlStyle.id, 'default');
    });

    /// Verifies that a node correctly resolves a style that has been 
    /// explicitly registered in the manager.
    test('Resolves registered style from manager', () {
      // Arrange
      const style = KMLStyle(id: 'folderStyle');
      manager.registerStyle(style);

      // Act
      final folder = KMLFolderNode(
        id: 'f2',
        name: 'Styled Folder',
        styleManager: manager,
        styleUrl: '#folderStyle',
      );

      // Assert
      expect(folder.kmlStyle, equals(style));
    });

    /// Verifies that accessing the style throws an ArgumentError if the 
    /// styleUrl references a non-existent, non-default style ID.
    test('Throws ArgumentError for missing non-default style', () {
      // Arrange
      final folder = KMLFolderNode(
        id: 'f3',
        name: 'Missing Style Folder',
        styleManager: manager,
        styleUrl: 'missing-id',
      );

      // Assert: The mixin delegates to the manager, which enforces valid lookups.
      expect(() => folder.kmlStyle, throwsArgumentError);
    });

    /// Verifies that the style resolution logic correctly handles the 
    /// KML-standard '#' prefix for internal style references.
    test('Handles styleUrl starting with #', () {
      // Arrange
      const style = KMLStyle(id: 'hashStyle');
      manager.registerStyle(style);

      // Act
      final folder = KMLFolderNode(
        id: 'f4',
        name: 'Hash Style Folder',
        styleManager: manager,
        styleUrl: '#hashStyle',
      );

      // Assert: The KMLStyleManager should strip the '#' before lookup.
      expect(folder.kmlStyle.id, 'hashStyle');
    });
  });
}
