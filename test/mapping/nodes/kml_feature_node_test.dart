// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/nodes/kml_feature_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// A concrete implementation of [KMLFeatureNode] for testing purposes.
class TestFeatureNode extends KMLFeatureNode {
  @override
  final KMLStyleManager styleManager;

  @override
  final String styleUrl;

  TestFeatureNode({
    required super.id,
    required super.name,
    required this.styleManager,
    this.styleUrl = 'default',
  });
}

void main() {
  group('KMLFeatureNode', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('should store and retrieve KML-specific properties', () {
      // Arrange
      final node = TestFeatureNode(id: 'feat1', name: 'Feature 1', styleManager: manager);

      // Act
      node.visibility = false;
      node.snippet = 'A brief snippet';
      node.extendedData = {'key': 'value'};

      // Assert: Verify retrieval from the underlying NodeProperties.
      expect(node.visibility, isFalse);
      expect(node.snippet, 'A brief snippet');
      expect(node.extendedData?['key'], 'value');
      
      expect(node.properties.getProperty('kml_visibility'), isFalse);
      expect(node.properties.getProperty('kml_snippet'), 'A brief snippet');
    });

    test('should support style resolution via KMLStylable', () {
      // Arrange
      final node = TestFeatureNode(id: 'feat2', name: 'Styled Feature', styleManager: manager);

      // Act & Assert: Should resolve to default style initially.
      expect(node.kmlStyle.id, 'default');
    });
  });
}
