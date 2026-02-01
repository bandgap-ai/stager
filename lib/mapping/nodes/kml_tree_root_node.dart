import 'package:stager_platform/tree/concrete_tree_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';
import 'package:stager_platform/mapping/style/kml_stylable.dart';

/// A [ConcreteTreeNode] specialized for representing the root of a KML document.
///
/// This class serves as the top-level entry point for a tree derived from a 
/// KML file. In the KML specification, this typically corresponds to the 
/// `<Document>` element or the root `<kml>` tag.
///
/// Because it inherits from [ConcreteTreeNode] and uses the [KMLStylable] 
/// mixin, it provides standard Stager mechanisms for tree traversal and 
/// robust, non-nullable KML style resolution.
class KMLTreeRootNode extends ConcreteTreeNode with KMLStylable {
  @override
  final KMLStyleManager styleManager;

  @override
  final String styleUrl;

  /// Creates a [KMLTreeRootNode].
  ///
  /// [id]: A unique identifier for this node within the Stager tree.
  /// [name]: The display name of the tree, typically from the KML `<name>` tag.
  /// [styleManager]: The registry where shared styles are stored.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional map of initial metadata for the node.
  KMLTreeRootNode({
    required super.id,
    required super.name,
    required this.styleManager,
    this.styleUrl = 'default',
    super.initialProperties,
  });
}
