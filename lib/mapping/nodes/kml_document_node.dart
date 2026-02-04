// Project files
import 'kml_stylable_feature_node.dart';

/// A concrete [KMLFeatureNode] representing a KML Document.
///
/// In the KML specification, a `<Document>` is a container for other features 
/// (Folders, Placemarks, or other Documents). It serves as a root or a 
/// high-level organizational element within a KML tree.
class KMLDocumentNode extends KmlStylableFeatureNode {
  /// Creates a [KMLDocumentNode] instance.
  ///
  /// [id]: The unique identifier for the node.
  /// [name]: The display name of the document.
  /// [styleManager]: The manager used to resolve shared styles.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional initial metadata.
  KMLDocumentNode({
    required super.id,
    required super.name,
    required super.styleManager,
    super.styleUrl = 'default',
    super.initialProperties,
  });
}
