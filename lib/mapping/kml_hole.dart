// External packages
import 'package:latlong2/latlong.dart';

/// Represents an inner boundary (a hole) of a KML Polygon.
///
/// This class encapsulates a list of coordinates that define a cutout region 
/// within a geographic polygon feature.
class KMLHole {
  /// The list of coordinates defining the boundary of the hole.
  final List<LatLng> points;

  /// Creates a [KMLHole] instance.
  ///
  /// [points]: A list of coordinates forming a closed ring.
  KMLHole({required this.points});

  @override
  String toString() => 'KMLHole(points: ${points.length})';
}
