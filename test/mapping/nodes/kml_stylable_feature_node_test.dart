// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/nodes/kml_stylable_feature_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// A concrete implementation of [KMLFeatureNode] for testing purposes.
class TestStylableFeatureNode extends KmlStylableFeatureNode {

  TestStylableFeatureNode({
    required super.name, required super.styleManager,
  });
}

void main() {
  group('KMLFeatureNode', () {

    test('should store and retrieve KML-specific properties', () {
      KMLStyleManager styleManager = KMLStyleManager();
      final node = TestStylableFeatureNode(name: 'Feature 1', styleManager: styleManager);

      // Try the setters
      node.visibility = false;
      node.snippet = 'A brief snippet';
      node.extendedData = {'key': 'value'};

      // Verify the getters
      expect(node.visibility, isFalse);
      expect(node.snippet, 'A brief snippet');
      expect(node.extendedData['key'], 'value');
    });

    test('should support style resolution via KMLStylable', () {
      // Arrange
      KMLStyleManager styleManager = KMLStyleManager();
      final node = TestStylableFeatureNode(name: 'Styled Feature', styleManager: styleManager);

      // Act & Assert: Should resolve to default style initially.
      expect(node.kmlStyle.id, 'default');
    });
  });
}
