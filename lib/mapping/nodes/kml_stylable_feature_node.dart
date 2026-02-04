// Project files
import '../style/kml_style_manager.dart';
import '../style/kml_stylable.dart';
import 'kml_feature_node.dart';

/// An intermediate base class for KML feature nodes that support styling.
///
/// This class combines the organizational capabilities of [KMLFeatureNode] 
/// with the style resolution logic of the [KMLStylable] mixin. Subclasses 
/// such as Documents and Placemarks inherit this shared infrastructure, 
/// reducing redundancy across the KML node hierarchy.
class KmlStylableFeatureNode extends KMLFeatureNode with KMLStylable {
  /// Creates a [KmlStylableFeatureNode] instance.
  ///
  /// [id]: The unique identifier for the node.
  /// [name]: The display name of the node.
  /// [styleManager]: The manager used to resolve shared styles.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional initial metadata.
  KmlStylableFeatureNode({
    required super.id,
    required super.name,
    required KMLStyleManager styleManager,
    String styleUrl = 'default',
    super.initialProperties,
  }) {
    // Initializing the late final fields from the KMLStylable mixin.
    this.styleManager = styleManager;
    this.styleUrl = styleUrl;
  }
}
