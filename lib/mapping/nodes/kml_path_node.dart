// External packages
import 'package:latlong2/latlong.dart';

// Project files
import 'kml_geometry_node.dart';

/// A concrete [KMLGeometryNode] representing a KML LineString (Path).
///
/// This class behaves like a Record, encapsulating a fixed geographic path 
/// defined at instantiation. It provides a strongly-typed, non-nullable 
/// accessor for the 'outline' property.
/// 
/// Once created, the geographic coordinates cannot be modified.
class KMLPathNode extends KMLGeometryNode {
  /// Internal key for storing the path coordinates.
  static const String outlineKey = 'outline';

  /// Creates a [KMLPathNode] instance.
  ///
  /// [id]: The unique identifier for the node.
  /// [name]: The display name of the path.
  /// [styleManager]: The manager used to resolve shared styles.
  /// [outline]: The fixed list of coordinates defining the path.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional initial metadata.
  KMLPathNode({
    required super.id,
    required super.name,
    required super.styleManager,
    required List<LatLng> outline,
    super.styleUrl = 'default',
    super.initialProperties,
  }) {
    // Storing the provided outline directly in the property map.
    properties.setProperty(outlineKey, outline);
  }

  /// The list of geographic coordinates defining the path.
  /// 
  /// Returns a non-nullable [List<LatLng>].
  /// 
  /// Throws a [StateError] if [hasOutline] is false.
  List<LatLng> get outline {
    return List<LatLng>.from(properties.getProperty(outlineKey) as Iterable);
  }
}
