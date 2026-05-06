// Project files
import 'kml_geometry_node.dart';

/// A concrete [KMLGeometryNode] representing a KML Point.
///
/// This class behaves like a Record, encapsulating a fixed geographic position 
/// defined at instantiation. It provides a strongly-typed, non-nullable 
/// accessor for the 'location' property.
///
/// The geographic position is stored on the [LeafNode] position member.
class KMLPointNode extends KMLGeometryNode {
  /// Creates a [KMLPointNode] instance.
  ///
  /// [id]: The unique identifier for the node.
  /// [name]: The display name of the point.
  /// [styleManager]: The manager used to resolve shared styles.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional initial metadata.
  KMLPointNode({
    required super.name,
    required super.styleManager,
    super.styleUrl = 'default',
    super.initialProperties,
  });
}
