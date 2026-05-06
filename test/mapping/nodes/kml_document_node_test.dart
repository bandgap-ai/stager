// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/nodes/kml_document_node.dart';
import 'package:stager_platform/mapping/nodes/kml_feature_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// Unit tests for the [KMLDocumentNode] class.
void main() {
  group('KMLDocumentNode', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('should correctly instantiate and inherit from KMLFeatureNode', () {
      // Arrange & Act
      final node = KMLDocumentNode(
        name: 'My Document',
        styleManager: manager,
      );

      // Assert
      expect(node, isA<KMLFeatureNode>());
      expect(node.name, 'My Document');
      expect(node.isComposite, isTrue);
    });

    test('should support children as a composite node', () {
      // Arrange
      final parent = KMLDocumentNode(
        name: 'Parent Document',
        styleManager: manager,
      );
      final child = KMLDocumentNode(
        name: 'Child Document',
        styleManager: manager,
      );

      // Act
      parent.addChild(child);

      // Assert
      expect(parent.children.length, 1);
      expect(parent.children.first, equals(child));
    });
  });
}
