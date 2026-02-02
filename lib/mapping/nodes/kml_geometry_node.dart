// Project files
import '../../tree/concrete_leaf_node.dart';
import '../style/kml_style_manager.dart';

/// An abstract base class for all terminal KML geometry nodes in the Stager tree.
///
/// This class serves as the foundation for geographic data nodes such as 
/// Points, Paths, and Polygons. It extends [ConcreteLeafNode] and defines 
/// the required style management capabilities for terminal KML nodes.
abstract class KMLGeometryNode extends ConcreteLeafNode {
  /// The manager used to resolve shared styles.
  final KMLStyleManager styleManager;

  /// The ID or URL of the style to apply to this geometry.
  final String styleUrl;

  /// Creates a [KMLGeometryNode] instance.
  ///
  /// [id]: The unique identifier for the node.
  /// [name]: The display name of the geometry.
  /// [styleManager]: The manager used to resolve shared styles.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional initial metadata.
  KMLGeometryNode({
    required super.id,
    required super.name,
    required this.styleManager,
    this.styleUrl = 'default',
    super.initialProperties,
  });
}
