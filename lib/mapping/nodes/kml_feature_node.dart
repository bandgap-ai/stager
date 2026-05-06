import '../../system/typed_value.dart';
import '../../tree/concrete_composite_node.dart';
import '../../tree/node_properties.dart';

/// This is a custom exception for KMLFeatureNodes.
class KMLFeatureNodeException implements Exception {
  final String message;

  KMLFeatureNodeException(this.message);

  @override
  String toString() => 'KMLFeatureNodeException: $message';
}

/// An abstract base class for all KML feature nodes in the Stager tree.
///
/// This class represents common KML feature attributes such as visibility, 
/// snippets, and extended data. It extends [ConcreteCompositeNode].
///
/// The KML feature visibility and snippet are treated as intrinsic properties
/// of this node. KML feature extended data is identical to Stager's generic
/// node properties, and the normal node property methods from the LeafNode
/// API provide that functionality here. Two additional helper methods,
/// hasExtendedData() and extendedData(), are provided on KMLFeatureNode as
/// markers of the required extended data functionality. KML-focused development
/// can call these methods to determine if extended data should be supported for
/// any given feature node.
abstract class KMLFeatureNode extends ConcreteCompositeNode {

  /// Whether the feature is drawn in the geographic view.
  bool _visibility = true;

  /// The short description of the feature.
  String _snippet = '';

  /// Creates a [KMLFeatureNode] instance.
  ///
  /// [id]: The unique identifier for the node.
  /// [name]: The display name of the feature.
  /// [styleManager]: The manager used to resolve shared styles.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional initial metadata.
  KMLFeatureNode({
    required super.name,
    super.initialProperties,
  });

  /// Indicates whether the feature is drawn in the geographic view.
  ///
  /// Maps to the `<visibility>` element in the KML specification.
  bool get visibility => _visibility;

  /// Sets whether the feature is drawn in the geographic view.
  ///
  /// Maps to the `<visibility>` element in the KML specification.
  set visibility(bool value) {
    _visibility = value;
    notify();
  }

  /// Returns `true` if this feature has a snippet description.
  bool get hasSnippet {
    return _snippet.isNotEmpty;
  }

  /// Returns the short description of the feature.
  ///
  /// Maps to the `<Snippet>` element in the KML specification.
  /// 
  /// Throws a [StateError] if [hasSnippet] is false.
  String get snippet {
    if (hasSnippet) {
      return _snippet;
    } else {
      throw KMLFeatureNodeException('KML Feature does not have a snippet.');
    }
  }

  /// Sets the short description of the feature.
  ///
  /// Maps to the `<Snippet>` element in the KML specification.
  set snippet(String value) {
    if (value.isNotEmpty) {
      _snippet = value;
      notify();
    } else {
      throw KMLFeatureNodeException('Snippet cannot be empty.');
    }
  }

  /// Returns `true` if this feature has custom extended data.
  ///
  /// This is a semantic convenience function to preserve the notion of KML
  /// extended data for KML features and it is equivalent to the base LeafNode's
  /// hasProperties property.
  bool get hasExtendedData {
    return hasProperties;
  }

  /// Returns the extended data for this feature.
  ///
  /// This is a semantic convenience function to preserve the notion of KML
  /// extended data for KML features and it is equivalent to the base LeafNode's
  /// properties property.
  NodeProperties get extendedData => properties;

  @override
  Map<String, Object> toMap() {
    // Add visibility, snippet, and extended data to the map
    final map = super.toMap();
    map.addAll({
      'visibility' : visibility,
      'snippet' : _snippet,
    });
    return map;
  }

  @override
  void fromMap(Map<String, Object> inputMap) {

    var map = Map.of(inputMap);

    // Pull the visibility, snippet and extended data from the map
    if (map.containsKey('visibility')) {
      _visibility = map['visibility']! as bool;
      map.remove('visibility');
    }
    if (map.containsKey('snippet')) {
      _snippet = map['snippet'] as String;
      map.remove('snippet');
    }
    // Let the base class handle the rest
    super.fromMap(map);

    return;
  }

}
