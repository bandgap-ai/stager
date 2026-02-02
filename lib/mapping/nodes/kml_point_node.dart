// Project files
import 'kml_geometry_node.dart';

/// A concrete [KMLGeometryNode] representing a KML Point.
///
/// This class encapsulates a single geographic coordinate (latitude and 
/// longitude). It provides strongly-typed accessors that map these values to 
/// the underlying [NodeProperties], ensuring compatibility with Stager's 
/// generic property system while providing a type-safe API.
class KMLPointNode extends KMLGeometryNode {
  /// Internal key for storing the latitude property.
  static const String latitudeKey = 'latitude';

  /// Internal key for storing the longitude property.
  static const String longitudeKey = 'longitude';

  /// Creates a [KMLPointNode] instance.
  ///
  /// [id]: The unique identifier for the node.
  /// [name]: The display name of the point.
  /// [styleManager]: The manager used to resolve shared styles.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional initial metadata.
  KMLPointNode({
    required super.id,
    required super.name,
    required super.styleManager,
    super.styleUrl = 'default',
    super.initialProperties,
  });

  /// The geographic latitude of the point.
  double? get latitude {
    return properties.getProperty(latitudeKey) as double?;
  }

  set latitude(double? value) {
    properties.setProperty(latitudeKey, value);
  }

  /// The geographic longitude of the point.
  double? get longitude {
    return properties.getProperty(longitudeKey) as double?;
  }

  set longitude(double? value) {
    properties.setProperty(longitudeKey, value);
  }
}
