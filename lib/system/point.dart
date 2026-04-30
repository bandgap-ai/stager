import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';
import '../builders/basic_builder.dart';
import 'stager_context.dart';
import 'typed_value.dart';

/// Supported coordinate reference systems within the Stager Platform.
enum CoordinateSystem {
  /// Standard geographic coordinates (Longitude, Latitude, Altitude).
  wgs84,
  /// Projected Cartesian coordinates (e.g., State Plane, UTM).
  projected,
  /// Localized grid coordinates [x, y] relative to a site origin.
  grid,
}

/// Exception thrown when a point cannot be converted.
class PointConversionException implements Exception {
  final String message;

  PointConversionException(this.message);

  @override
  String toString() => 'PointConversionException: $message';
}

/// A builder function for rehydrating [Point] instances.
///
/// Note that this build only builds Points with the default converter.
///
/// This builder fulfills the requirement to register complex types with the
/// platform's dynamic factory system.
@BasicBuilder(name: 'Point')
Point buildPoint(StagerContext context) {
  final coords = context.get<List<double>>('coords');
  final system = CoordinateSystem.values.byName(
      context.getOrDefault<String>('system','wgs84'));
  return Point(coords: coords, system: system);
}

/// Default implementation for resolving geographic coordinates.
///
/// Throws [PointConversionException] if the system cannot be converted.
///
/// [coords]: The coordinate values.
/// [system]: The CRS used.
LatLng _basicWGS84ToLatLng(List<double> coords, CoordinateSystem system) {
  if (system == CoordinateSystem.wgs84 &&
      coords.length >= 2) {
    // Convention: [0] is Longitude (X), [1] is Latitude (Y).
    return LatLng(coords[1], coords[0]);
  } else {
    throw PointConversionException(
        'Cannot convert to LatLng for system ${system.name} and coordinates '
            '$coords.');
  }
}

/// An n-dimensional position container.
///
/// By convention, x is the first dimension, y is the second, and so on. If you
/// are using Points to store latitudes and longitudes, keep in mind that this
/// means point.x = longitude and point.y = latitude, which is backwards from
/// the constructor of, for example, LatLng from the latlng2 package, but
/// consistent with, again just for example, Google Maps.
///
/// [toString] prints the coordinates and reference frame to a comma-separated
/// string.
class Point {
  /// The raw coordinate values.
  final List<double> coords;

  /// The coordinate reference system used by these coordinates.
  final CoordinateSystem system;

  /// The function used to convert coordinates to [LatLng].
  final LatLng Function(List<double> coords, CoordinateSystem system) converter;

  /// Constructor.
  ///
  /// [coords]: The coordinate values. Defaults to [0.0, 0.0, 0.0].
  /// [system]: The CRS used. Defaults to [CoordinateSystem.wgs84].
  /// [converter]: Function to resolve [LatLng]. Defaults to [defaultConverter].
  const Point({
    this.coords = const [0.0, 0.0, 0.0],
    this.system = CoordinateSystem.wgs84,
    this.converter = _basicWGS84ToLatLng,
  });

  /// Returns the 'x' coordinate, abscissa, or position along the first
  /// orthogonal axis. In WGS84, this is longitude.
  double get x => coords.isNotEmpty ? coords[0] : 0.0;

  /// Returns the 'y' coordinate, ordinate, or position along the second
  /// orthogonal axis. In WGS84, this is latitude.
  double get y => coords.length > 1 ? coords[1] : 0.0;

  /// Returns the 'z' coordinate, applicate, or position along the third
  /// orthogonal axis. In WGS84, this is altitude.
  double get z => coords.length > 2 ? coords[2] : 0.0;

  /// Returns the reified geographic coordinate.
  LatLng toLatLng() => converter(coords, system);

  @override
  bool operator ==(Object other) {
    bool equals = false;

    equals = (other is Point)
        && (ListEquality().equals(other.coords,coords))
        && (other.system == system)
        && (other.converter == converter);

    return equals;
  }

  @override
  int get hashCode => Object.hash(ListEquality().hash(coords),
      system, converter);

  /// Exports the point state to a map structure for persistence or similar
  /// manipulation.
  ///
  /// Includes a [TypedValue] for coordinates and a raw string for the system if
  /// the system is not [CoordinateSystem.wgs84], which is the default value.
  ///
  /// Returns a map.
  Map<String, Object> toMap() {
    return {
      'coords': coords,
      if (system != CoordinateSystem.wgs84) 'system': system.name,
    };
  }

  @override
  String toString() {
    return "${coords.join(',')},${system.name}";
  }

}