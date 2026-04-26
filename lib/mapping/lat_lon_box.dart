import '../system/typed_value.dart';

/// Represents a geographic bounding box defined by north, south, east, 
/// and west boundaries.
///
/// This class is used to define the spatial extent of a [KMLGroundOverlayNode].
class LatLonBox {
  /// The northernmost latitude of the box.
  final double north;

  /// The southernmost latitude of the box.
  final double south;

  /// The easternmost longitude of the box.
  final double east;

  /// The westernmost longitude of the box.
  final double west;

  /// Creates a [LatLonBox] instance.
  ///
  /// [north]: Northern latitude.
  /// [south]: Southern latitude.
  /// [east]: Eastern longitude.
  /// [west]: Western longitude.
  const LatLonBox({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  @override
  String toString() {
    return 'LatLonBox(north: $north, south: $south, east: $east, west: $west)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LatLonBox &&
            other.north == north &&
            other.south == south &&
            other.east == east &&
            other.west == west);
  }

  @override
  int get hashCode => Object.hash(north, south, east, west);

  /// Exports the box state to a map structure for persistence.
  Map<String, Object> toMap() {
    return {
      'north': TypedValue<double>(north),
      'south': TypedValue<double>(south),
      'east': TypedValue<double>(east),
      'west': TypedValue<double>(west),
    };
  }

  /// Rehydrates a [LatLonBox] from a reified map.
  static LatLonBox fromMap(Map<String, Object> inputMap) {
    return LatLonBox(
      north: (inputMap['north']! as TypedValue<double>).value,
      south: (inputMap['south']! as TypedValue<double>).value,
      east: (inputMap['east']! as TypedValue<double>).value,
      west: (inputMap['west']! as TypedValue<double>).value,
    );
  }
}
