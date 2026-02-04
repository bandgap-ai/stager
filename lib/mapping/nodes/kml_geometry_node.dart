import '../../tree/concrete_leaf_node.dart';
import '../style/kml_style_manager.dart';
import '../style/kml_stylable.dart';

/// An abstract base class for all terminal KML geometry nodes in the Stager tree.
///
/// This class serves as the foundation for geographic data nodes such as 
/// Points, Paths, and Polygons. It extends [ConcreteLeafNode] and defines 
/// the required style management capabilities for terminal KML nodes via the 
/// [KMLStylable] mixin.
abstract class KMLGeometryNode extends ConcreteLeafNode with KMLStylable {
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
    required KMLStyleManager styleManager,
    String styleUrl = 'default',
    super.initialProperties,
  }) {
    // Initializing the late final fields from the KMLStylable mixin.
    this.styleManager = styleManager;
    this.styleUrl = styleUrl;
  }
}
