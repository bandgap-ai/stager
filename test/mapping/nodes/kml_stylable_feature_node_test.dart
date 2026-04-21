// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/nodes/kml_stylable_feature_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// A concrete implementation of [KMLFeatureNode] for testing purposes.
class TestStylableFeatureNode extends KmlStylableFeatureNode {

  TestStylableFeatureNode({
    required super.id,
    required super.name, required super.styleManager,
  });
}

void main() {
  group('KMLFeatureNode', () {

    test('should store and retrieve KML-specific properties', () {
      KMLStyleManager styleManager = KMLStyleManager();
      // Arrange
      final node = TestStylableFeatureNode(id: 'feat1', name: 'Feature 1', styleManager: styleManager);

      // Act
      node.visibility = false;
      node.snippet = 'A brief snippet';
      node.extendedData = {'key': 'value'};

      // Assert: Verify retrieval from the underlying NodeProperties.
      expect(node.visibility, isFalse);
      expect(node.snippet, 'A brief snippet');
      expect(node.extendedData['key'], 'value');
      
      expect(node.properties.get<bool>('kml_visibility'), isFalse);
      expect(node.properties.get<String>('kml_snippet'), 'A brief snippet');
    });

    test('should support style resolution via KMLStylable', () {
      // Arrange
      KMLStyleManager styleManager = KMLStyleManager();
      final node = TestStylableFeatureNode(id: 'feat2', name: 'Styled Feature', styleManager: styleManager);

      // Act & Assert: Should resolve to default style initially.
      expect(node.kmlStyle.id, 'default');
    });
  });
}
