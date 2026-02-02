// Project files
import '../style/kml_style_manager.dart';
import 'kml_feature_node.dart';

/// A concrete [KMLFeatureNode] specialized for representing KML Folders.
///
/// In the KML specification, a `<Folder>` is a container used to organize 
/// other features (Folders or Placemarks) into a hierarchy. This class 
/// maps that concept to the Stager tree, allowing for nested geographic 
/// data structures and providing robust, non-nullable style resolution 
/// inherited from [KMLFeatureNode].
class KMLFolderNode extends KMLFeatureNode {
  @override
  final KMLStyleManager styleManager;

  @override
  final String styleUrl;

  /// Creates a [KMLFolderNode].
  ///
  /// [id]: A unique identifier for this node within the Stager tree.
  /// [name]: The display name of the folder, typically from the KML `<name>` tag.
  /// [styleManager]: The registry where shared styles are stored.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional map of initial metadata for the node.
  KMLFolderNode({
    required super.id,
    required super.name,
    required this.styleManager,
    this.styleUrl = 'default',
    super.initialProperties,
  });
}
