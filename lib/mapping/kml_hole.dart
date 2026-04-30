import 'package:collection/collection.dart';
import '../system/registry.dart';
import '../system/point.dart';

/// Represents an inner boundary (a hole) of a KML Polygon.
///
/// This class encapsulates a list of [Point] coordinates that define a cutout 
/// region within a geographic polygon feature.
class KMLHole {
  /// The list of coordinates defining the boundary of the hole.
  final List<Point> points;

  /// Creates a [KMLHole] instance.
  ///
  /// [points]: A list of coordinates forming a closed ring.
  KMLHole({required this.points});

  @override
  String toString() => 'KMLHole(points: $points)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is KMLHole && const ListEquality().equals(other.points, points));
  }

  @override
  int get hashCode => const ListEquality().hash(points);

  /// Exports the hole state to a map structure for persistence.
  Map<String, Object> toMap() {
    return {
      'points': points.map((p) => p.toMap()).toList(),
    };
  }

  /// Rehydrates a [KMLHole] from a map representation.
  static KMLHole fromMap(Map<String, Object> inputMap) {
    // Get the map, which should have "points" in it
    List<Point> pointsList = [];
    if (inputMap.containsKey('points')) {
      final rawPointsList = inputMap['points']! as List<Object>;
      // This should be a list of points.
      for (final pointEntry in rawPointsList) {
        Point point = buildObject('Point', pointEntry as Map<String, Object>) as Point;
        pointsList.add(point);
      }
    }
    return KMLHole(points: pointsList);
  }
}
