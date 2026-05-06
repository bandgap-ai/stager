// Flutter packages
import 'package:flutter_test/flutter_test.dart';

import 'package:stager_platform/mapping/nodes/kml_document_node.dart';
import 'package:stager_platform/mapping/nodes/kml_feature_node.dart';
import 'package:stager_platform/mapping/nodes/kml_folder_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// Unit tests for the [KMLFolderNode] class.
void main() {
  group('KMLFolderNode', () {
    test('should correctly instantiate and inherit from KMLFeatureNode', () {
      // Arrange & Act
      final node = KMLFolderNode(
        name: 'My Folder',
      );

      // Assert
      expect(node, isA<KMLFeatureNode>());
      expect(node.name, 'My Folder');
      expect(node.isComposite, isTrue);
    });

    test('should support children as a composite node', () {
      // Arrange
      final parent = KMLFolderNode(
        name: 'Parent Folder',
      );
      final child = KMLFolderNode(
        name: 'Child Folder',
      );

      // Act
      parent.addChild(child);

      // Assert
      expect(parent.children.length, 1);
      expect(parent.children.first, equals(child));
    });

    test('should throw ArgumentError when adding a KMLDocumentNode as a child', () {
      // Arrange
      final manager = KMLStyleManager();
      final folder = KMLFolderNode(
        name: 'Test Folder',
      );
      final doc = KMLDocumentNode(
        name: 'Invalid Child Document',
        styleManager: manager,
      );

      // Act & Assert: Folders cannot contain Documents per KML spec enforcement.
      expect(() => folder.addChild(doc), throwsArgumentError);
    });
  });
}
