// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/nodes/kml_folder_node.dart';
import 'package:stager_platform/mapping/nodes/kml_feature_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// Unit tests for the [KMLFolderNode] class.
void main() {
  group('KMLFolderNode', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('should correctly instantiate and inherit from KMLFeatureNode', () {
      // Arrange & Act
      final node = KMLFolderNode(
        id: 'folder1',
        name: 'My Folder'
      );

      // Assert
      expect(node, isA<KMLFeatureNode>());
      expect(node.properties.getProperty('id'), 'folder1');
      expect(node.properties.getProperty('name'), 'My Folder');
      expect(node.isComposite, isTrue);
    });

    test('should support children as a composite node', () {
      // Arrange
      final parent = KMLFolderNode(
        id: 'folder2',
        name: 'Parent Folder'
      );
      final child = KMLFolderNode(
        id: 'folder3',
        name: 'Child Folder'
      );

      // Act
      parent.addChild(child);

      // Assert
      expect(parent.children.length, 1);
      expect(parent.children.first, equals(child));
    });
  });
}
