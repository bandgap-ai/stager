import 'package:collection/collection.dart';
import '../builders/stager_context.dart';
import '../system/point.dart';
import '../system/typed_value.dart';

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
      'points': TypedValue<List<Object>>(points.map((p) => p.toMap()).toList())
          .toTuple(),
    };
  }

  /// Rehydrates a [KMLHole] from a map representation.
  static KMLHole fromMap(Map<String, Object> inputMap) {
    final context = StagerContext(inputMap);
    final rawList = context.get<TypedValue<List<Object>>>('points').value;
    final points = rawList
        .map((e) => buildPoint(StagerContext({'value': e as List<Object>})))
        .toList();
    return KMLHole(points: points);
  }
}
