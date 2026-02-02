import '../../tree/concrete_composite_node.dart';
import '../style/kml_stylable.dart';

/// An abstract base class for all KML feature nodes in the Stager tree.
///
/// This class represents common KML feature attributes such as visibility, 
/// snippets, and extended data. It extends [ConcreteCompositeNode] and 
/// leverages the [KMLStylable] mixin to provide robust style resolution for 
/// both containers (Documents, Folders) and geographic features.
abstract class KMLFeatureNode extends ConcreteCompositeNode with KMLStylable {
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
    return properties.getProperty(visibilityKey) as bool? ?? true;
  }

  set visibility(bool value) {
    properties.setProperty(visibilityKey, value);
  }

  /// A short description of the feature.
  ///
  /// Maps to the `<Snippet>` element in the KML specification.
  String? get snippet {
    return properties.getProperty(snippetKey) as String?;
  }

  set snippet(String? value) {
    properties.setProperty(snippetKey, value);
  }

  /// A map of custom data associated with the feature.
  ///
  /// Maps to the `<ExtendedData>` element in the KML specification.
  Map<String, dynamic>? get extendedData {
    return properties.getProperty(extendedDataKey) as Map<String, dynamic>?;
  }

  set extendedData(Map<String, dynamic>? value) {
    properties.setProperty(extendedDataKey, value);
  }
}
