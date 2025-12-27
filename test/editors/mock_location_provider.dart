import 'package:geolocator/geolocator.dart';
import 'package:stager_platform/providers/location_provider.dart';

/// A mock implementation of the [LocationProvider] for testing purposes.
///
/// This class allows for simulating different location service scenarios,
/// such as returning a fixed position or simulating disabled services,
/// without depending on the actual device hardware.
class MockLocationProvider implements LocationProvider {
  /// A canned [Position] to be returned by [getCurrentPosition].
  ///
  /// Defaults to a position with latitude 42.0 and longitude -42.0.
  Position mockPosition = Position(
    latitude: 42.0,
    longitude: -42.0,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  /// The mock value to be returned by [isLocationServiceEnabled].
  ///
  /// Defaults to `true`.
  bool isServiceEnabled = true;

  /// The mock value to be returned by [checkPermission] and [requestPermission].
  ///
  /// Defaults to [LocationPermission.always].
  LocationPermission permissionStatus = LocationPermission.always;

  @override
  Future<Position> getCurrentPosition() async {
    // Return the canned position.
    return mockPosition;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    // Return the configured service status.
    return isServiceEnabled;
  }

  @override
  Future<LocationPermission> checkPermission() async {
    // Return the configured permission status.
    return permissionStatus;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    // Return the configured permission status.
    return permissionStatus;
  }
}
