// External packages
import 'package:latlong2/latlong.dart';

// Project files
import '../kml_hole.dart';
import 'kml_geometry_node.dart';

/// A concrete [KMLGeometryNode] representing a KML Polygon.
///
/// This class behaves like a Record, encapsulating a geographic polygon 
/// feature consisting of a fixed outer boundary (outline) and zero or more 
/// inner boundaries (holes) defined at instantiation.
/// 
/// Once created, the geographic coordinates cannot be modified.
class KMLPolygonNode extends KMLGeometryNode {
  /// Internal key for storing the outer boundary coordinates.
  static const String outlineKey = 'outline';

  /// Internal key for storing the list of inner holes.
  static const String holesKey = 'kml_holes';

  /// Creates a [KMLPolygonNode] instance.
  ///
  /// [id]: The unique identifier for the node.
  /// [name]: The display name of the polygon.
  /// [styleManager]: The manager used to resolve shared styles.
  /// [outline]: The fixed list of coordinates defining the outer boundary.
  /// [holes]: An optional list of [KMLHole] objects defining inner cutouts. 
  /// Defaults to an empty list.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional initial metadata.
  KMLPolygonNode({
    required super.name,
    required super.styleManager,
    required List<LatLng> outline,
    List<KMLHole> holes = const [],
    super.styleUrl = 'default',
    super.initialProperties,
  }) {
    // Storing the provided geometry data directly in the property map.
    properties.set<List<LatLng>>(outlineKey, outline);
    properties.set<List<KMLHole>>(holesKey, holes);
  }

  /// The list of geographic coordinates defining the outer boundary.
  /// 
  /// Returns a non-nullable [List<LatLng>].
  /// 
  /// Throws a [StateError] if [hasOutline] is false.
  List<LatLng> get outline {
    return List<LatLng>.from(properties.get<List<LatLng>>(outlineKey));
  }

  /// The list of [KMLHole] objects defining inner cutout regions.
  /// 
  /// Returns a non-nullable [List<KMLHole>].
  /// 
  /// Throws a [StateError] if [hasHoles] is false.
  List<KMLHole> get holes {
    return List<KMLHole>.from(properties.get<List<KMLHole>>(holesKey));
  }
}
