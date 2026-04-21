// Flutter packages
import 'package:flutter_test/flutter_test.dart';

import 'package:stager_platform/mapping/nodes/kml_feature_node.dart';

/// A concrete implementation of [KMLFeatureNode] for testing purposes.
class TestFeatureNode extends KMLFeatureNode {

  TestFeatureNode({
    required super.id,
    required super.name,
  });
}

void main() {
  group('KMLFeatureNode', () {

    test('should store and retrieve KML-specific properties', () {
      // Arrange
      final node = TestFeatureNode(id: 'feat1', name: 'Feature 1');

      // Act
      node.visibility = false;
      node.snippet = 'A brief snippet';
      expect(node.hasExtendedData,false);
      node.extendedData = {'key': 'value'};

      // Assert: Verify retrieval from the underlying NodeProperties.
      expect(node.visibility, isFalse);
      expect(node.snippet, 'A brief snippet');
      expect(node.hasExtendedData,true);
      expect(node.extendedData['key'], 'value');
      
      expect(node.properties.get<bool>('kml_visibility'), isFalse);
      expect(node.properties.get<String>('kml_snippet'), 'A brief snippet');
    });
  });
}
