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
}
