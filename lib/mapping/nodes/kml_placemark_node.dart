import 'kml_stylable_feature_node.dart';
import 'kml_geometry_node.dart';

/// A concrete [KMLFeatureNode] representing a KML Placemark.
///
/// In the KML specification, a `<Placemark>` is a feature that represents a 
/// specific object on the map. This implementation treats the Placemark as 
/// a composite container that aggregates one or more [KMLGeometryNode] 
/// children. This structure naturally supports KML's `<MultiGeometry>` and 
/// ensures that features are clearly separated from their geographic data.
class KMLPlacemarkNode extends KmlStylableFeatureNode {
  /// Creates a [KMLPlacemarkNode] instance.
  ///
  /// [id]: The unique identifier for the node.
  /// [name]: The display name of the placemark.
  /// [styleManager]: The manager used to resolve shared styles.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional map of initial metadata for the node.
  KMLPlacemarkNode({
    required super.name,
    required super.styleManager,
    super.styleUrl,
    super.initialProperties,
  });

  /// Indicates whether this placemark contains multiple geographic geometries.
  ///
  /// Maps to the `<MultiGeometry>` concept in the KML specification.
  /// 
  /// Returns `true` if the node has more than one [KMLGeometryNode] child, 
  /// `false` otherwise.
  bool get isMultiGeometry {
    late bool result;
    // Adhering to the Single Return Principle.
    // We only count children that are specialized KMLGeometryNodes.
    final geometryCount = children.whereType<KMLGeometryNode>().length;
    result = geometryCount > 1;
    return result;
  }
}
