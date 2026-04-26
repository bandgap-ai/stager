import '../../system/typed_value.dart';
import '../../tree/concrete_composite_node.dart';

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
abstract class KMLFeatureNode extends ConcreteCompositeNode {

  /// Whether the feature is drawn in the geographic view.
  bool _visibility = true;

  /// The short description of the feature.
  String _snippet = '';

  /// The map of custom data associated with the feature.
  Map<String, Object> _extendedData = {};

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
  bool get hasExtendedData {
    return _extendedData.isNotEmpty;
  }

  /// Returns the map of custom data associated with the feature.
  ///
  /// Maps to the `<ExtendedData>` element in the KML specification.
  /// 
  /// Throws a [StateError] if [hasExtendedData] is false.
  Map<String, Object> get extendedData {
    if (hasExtendedData) {
      return _extendedData;
    } else {
      throw KMLFeatureNodeException('KML Feature does not have extended data.');
    }
  }

  set extendedData(Map<String, Object> value) {
    _extendedData = value;
    notify();
  }

  @override
  Map<String, Object> toMap() {
    // Add visibility, snippet, and extended data to the map
    final map = super.toMap();
    map.addAll({
      'visibility' : visibility,
      'snippet' : _snippet,
      'extendedData' : TypedValue<Map<String, Object>>(_extendedData),
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
    if (map.containsKey('extendedData')) {
      _extendedData = (map['extendedData']!
        as TypedValue<Map<String, Object>>).value;
      map.remove('extendedData');
    }
    // Let the base class handle the rest
    super.fromMap(map);

    return;
  }

}
