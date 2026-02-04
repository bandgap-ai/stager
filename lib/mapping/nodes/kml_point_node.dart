// External packages
import 'package:latlong2/latlong.dart';

// Project files
import 'kml_geometry_node.dart';

/// A concrete [KMLGeometryNode] representing a KML Point.
///
/// This class behaves like a Record, encapsulating a fixed geographic position 
/// defined at instantiation. It provides a strongly-typed, non-nullable 
/// accessor for the 'location' property.
///
/// Unlike standard concrete nodes, this class stores the [LatLng] object 
/// directly in the property map under the 'position' key. Once created, 
/// the position cannot be modified.
class KMLPointNode extends KMLGeometryNode {
  /// Internal key for storing the [LatLng] position property.
  static const String positionKey = 'position';

  /// Creates a [KMLPointNode] instance.
  ///
  /// [id]: The unique identifier for the node.
  /// [name]: The display name of the point.
  /// [styleManager]: The manager used to resolve shared styles.
  /// [location]: The fixed geographic position. Defaults to (0, 0).
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional initial metadata.
  KMLPointNode({
    required super.id,
    required super.name,
    required super.styleManager,
    LatLng location = const LatLng(0, 0),
    super.styleUrl = 'default',
    super.initialProperties,
  }) {
    // Storing the position directly in the property map.
    properties.setProperty(positionKey, location);
  }

  /// The geographic location of the point.
  ///
  /// Returns a non-nullable [LatLng].
  /// 
  /// Throws a [StateError] if [hasLocation] is false.
  LatLng get location {
    return properties.getProperty(positionKey) as LatLng;
  }
}
