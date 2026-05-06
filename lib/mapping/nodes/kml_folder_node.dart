// Project files
import 'kml_document_node.dart';
import 'kml_feature_node.dart';
import '../../tree/tree.dart';

/// A concrete [KMLFeatureNode] specialized for representing KML Folders.
///
/// In the KML specification, a `<Folder>` is a container used to organize 
/// other features (Folders or Placemarks) into a hierarchy. This class 
/// maps that concept to the Stager tree, allowing for nested geographic 
/// data structures.
/// 
/// Note: According to the KML specification, a Folder cannot contain a 
/// Document feature. This implementation enforces that rule in [addChild].
class KMLFolderNode extends KMLFeatureNode {
  /// Creates a [KMLFolderNode].
  ///
  /// [id]: A unique identifier for this node within the Stager tree.
  /// [name]: The display name of the folder, typically from the KML `<name>` tag.
  /// [styleManager]: The registry where shared styles are stored.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional map of initial metadata for the node.
  KMLFolderNode({
    required super.name,
    super.initialProperties,
  });

  /// Adds a [child] to this folder.
  /// 
  /// This method overrides the standard composite behavior to enforce KML 
  /// nesting rules. Specifically, it rejects [KMLDocumentNode]s.
  /// 
  /// Throws an [ArgumentError] if the [child] is a [KMLDocumentNode].
  @override
  void addChild(LeafNode child) {
    if (child is KMLDocumentNode) {
      throw ArgumentError('KML specification violation: A Folder cannot contain a Document.');
    }
    super.addChild(child);
  }
}
