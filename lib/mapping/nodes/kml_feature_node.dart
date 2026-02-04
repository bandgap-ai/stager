import '../../tree/concrete_composite_node.dart';
import '../style/kml_style_manager.dart';
import '../style/kml_stylable.dart';

/// An abstract base class for all KML feature nodes in the Stager tree.
///
/// This class represents common KML feature attributes such as visibility, 
/// snippets, and extended data. It extends [ConcreteCompositeNode].
abstract class KMLFeatureNode extends ConcreteCompositeNode {
  /// Internal key for storing the visibility property.
  static const String visibilityKey = 'kml_visibility';

  /// Internal key for storing the snippet property.
  static const String snippetKey = 'kml_snippet';

  /// Internal key for storing the extended data property.
  static const String extendedDataKey = 'kml_extended_data';

  /// Creates a [KMLFeatureNode] instance.
  ///
  /// [id]: The unique identifier for the node.
  /// [name]: The display name of the feature.
  /// [styleManager]: The manager used to resolve shared styles.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional initial metadata.
  KMLFeatureNode({
    required super.id,
    required super.name,
    super.initialProperties,
  });

  /// Indicates whether the feature is drawn in the geographic view.
  ///
  /// Maps to the `<visibility>` element in the KML specification.
  bool get visibility {
    bool result = true;
    // Adhering to the project standard of using containsProperty() instead 
    // of null checks.
    if (properties.containsProperty(visibilityKey)) {
      result = properties.getProperty(visibilityKey) as bool;
    }
    return result;
  }

  set visibility(bool value) {
    properties.setProperty(visibilityKey, value);
  }

  /// Returns `true` if this feature has a snippet description.
  bool get hasSnippet {
    return properties.containsProperty(snippetKey);
  }

  /// Returns the short description of the feature.
  ///
  /// Maps to the `<Snippet>` element in the KML specification.
  /// 
  /// Throws a [StateError] if [hasSnippet] is false.
  String get snippet {
    late String result;
    // Adhering to the standard of using the "has" method for initial check.
    if (hasSnippet) {
      result = properties.getProperty(snippetKey) as String;
    } else {
      throw StateError('KML Feature does not have a snippet.');
    }
    return result;
  }

  set snippet(String value) {
    properties.setProperty(snippetKey, value);
  }

  /// Returns `true` if this feature has custom extended data.
  bool get hasExtendedData {
    return properties.containsProperty(extendedDataKey);
  }

  /// Returns the map of custom data associated with the feature.
  ///
  /// Maps to the `<ExtendedData>` element in the KML specification.
  /// 
  /// Throws a [StateError] if [hasExtendedData] is false.
  Map<String, dynamic> get extendedData {
    late Map<String, dynamic> result;
    // Adhering to the standard of using the "has" method for initial check.
    if (hasExtendedData) {
      result = properties.getProperty(extendedDataKey) as Map<String, dynamic>;
    } else {
      throw StateError('KML Feature does not have extended data.');
    }
    return result;
  }

  set extendedData(Map<String, dynamic> value) {
    properties.setProperty(extendedDataKey, value);
  }
}
