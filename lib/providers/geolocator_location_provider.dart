import 'package:geolocator/geolocator.dart';
import 'package:stager_platform/providers/location_provider.dart';

/// A concrete implementation of [LocationProvider] that uses the `geolocator`
/// package to provide real location data.
class GeolocatorLocationProvider implements LocationProvider {
  /// Creates a [GeolocatorLocationProvider].
  const GeolocatorLocationProvider();

  @override
  Future<bool> isLocationServiceEnabled() {
    // Forward the call directly to the geolocator package.
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermission> checkPermission() {
    // Forward the call directly to the geolocator package.
    return Geolocator.checkPermission();
  }

  @override
  Future<LocationPermission> requestPermission() {
    // Forward the call directly to the geolocator package.
    return Geolocator.requestPermission();
  }

  @override
  Future<Position> getCurrentPosition() {
    // Forward the call directly to the geolocator package.
    return Geolocator.getCurrentPosition();
  }
}
