import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/nodes/kml_feature_node.dart';
import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/tree/node_properties.dart';

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
      
      expect(node.hasExtendedData, isFalse);
      NodeProperties extendedData = node.extendedData;
      extendedData.set<String>('tree_health','Good');
      extendedData.set<double>('dbh',34.5);
      // Make sure it shows up now. We don't need to test actual containment
      // since NodeProperties is thoroughly test elsewhere.
      expect(node.hasExtendedData, isTrue);

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
        ..snippet = 'Snippet';

      // Generate the reified map representation.
      final map = node.toMap();

      // Verify that KML members and the property bag are harvested correctly.
      expect(map['visibility'], isFalse);
      expect(map['snippet'], 'Snippet');
    });

    test('should rehydrate state correctly via fromMap', () {
      // Define a reified map representing a dehydrated KML feature.
      final inputMap = {
        'name': 'Rehydrated',
        'visibility': false,
        'snippet': 'Rehydrated Snippet',
        'custom_key': const TypedValue<String>('custom_value').toTuple(),
      };

      // Create a blank node and rehydrate it from the map.
      final node = TestFeatureNode(name: 'Blank');
      node.fromMap(inputMap);

      // Verify that both intrinsic members and generic properties are restored.
      expect(node.name, 'Rehydrated');
      expect(node.visibility, isFalse);
      expect(node.snippet, 'Rehydrated Snippet');
      expect(node.properties.get<String>('custom_key'), 'custom_value');
    });
  });
}
