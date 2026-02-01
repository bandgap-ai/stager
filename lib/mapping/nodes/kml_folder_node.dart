import 'package:stager_platform/tree/concrete_composite_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';
import 'package:stager_platform/mapping/style/kml_stylable.dart';

/// A [ConcreteCompositeNode] specialized for representing KML Folders.
///
/// In the KML specification, a `<Folder>` is a container used to organize 
/// other features (Folders or Placemarks) into a hierarchy. This class 
/// maps that concept to the Stager [CompositeNode], allowing for nested 
/// geographic data structures and providing robust, non-nullable style 
/// resolution via the [KMLStylable] mixin.
class KMLFolderNode extends ConcreteCompositeNode with KMLStylable {
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
