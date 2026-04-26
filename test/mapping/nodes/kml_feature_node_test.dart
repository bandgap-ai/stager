import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/nodes/kml_feature_node.dart';
import 'package:stager_platform/system/typed_value.dart';

/// A concrete implementation of [KMLFeatureNode] for testing purposes.
class TestFeatureNode extends KMLFeatureNode {
  TestFeatureNode({
    required super.name,
    super.initialProperties,
  });
}

void main() {
  group('KMLFeatureNode Tests', () {
    test('should store and retrieve intrinsic KML members', () {
      // Create a test node and modify its intrinsic KML members.
      final node = TestFeatureNode(name: 'Feature 1');
      node.visibility = false;
      node.snippet = 'A brief snippet';

      // Verify that the members are updated and accessible via their getters.
      expect(node.visibility, isFalse);
      expect(node.snippet, 'A brief snippet');
    });

    test('should pipe extended data to and from the properties bag', () {
      // Create a test node and provide it with a map of custom extended data.
      final node = TestFeatureNode(name: 'Feature 1');
      final customData = {'tree_health': 'Good', 'dbh': 34.5};
      
      expect(node.hasExtendedData, isFalse);
      node.extendedData = customData;

      // Verify that the data is accessible via the extendedData getter 
      // and has been correctly reified in the underlying property bag.
      expect(node.hasExtendedData, isTrue);
      expect(node.extendedData['tree_health'], 'Good');
      expect(node.extendedData['dbh'], 34.5);
      expect(node.property('tree_health'), 'Good');
    });

    test('should throw exception when accessing missing snippet', () {
      // Create a node with an empty snippet (default).
      final node = TestFeatureNode(name: 'No Snippet');

      // Verify that the "Loud Failure" pattern is enforced for uninitialized snippets.
      expect(
        () => node.snippet,
        throwsA(isA<KMLFeatureNodeException>().having(
          (e) => e.message,
          'message',
          contains('does not have a snippet'),
        )),
      );
    });

    test('should export state correctly via toMap', () {
      // Setup a node with specific KML attributes and extended data.
      final node = TestFeatureNode(name: 'Export Node')
        ..visibility = false
        ..snippet = 'Snippet'
        ..extendedData = {'meta': 'data'};

      // Generate the reified map representation.
      final map = node.toMap();

      // Verify that KML members and the property bag are harvested correctly.
      expect(map['visibility'], TypedValue<bool>(false));
      expect(map['snippet'], TypedValue<String>('Snippet'));
      expect(map['meta'], TypedValue<String>('data'));
    });

    test('should rehydrate state correctly via fromMap', () {
      // Define a reified map representing a dehydrated KML feature.
      final inputMap = {
        'name': const TypedValue<String>('Rehydrated'),
        'visibility': const TypedValue<bool>(false),
        'snippet': const TypedValue<String>('Rehydrated Snippet'),
        'custom_key': const TypedValue<String>('custom_value'),
      };

      // Create a blank node and rehydrate it from the map.
      final node = TestFeatureNode(name: 'Blank');
      node.fromMap(inputMap);

      // Verify that both intrinsic members and generic properties are restored.
      expect(node.name, 'Rehydrated');
      expect(node.visibility, isFalse);
      expect(node.snippet, 'Rehydrated Snippet');
      expect(node.property('custom_key'), 'custom_value');
    });
  });
}
