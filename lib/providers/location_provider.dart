import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// An interface for providing location services.
///
/// This abstraction allows for swapping out the underlying location provider,
/// which is essential for creating testable widgets that depend on location
/// data or enabling different location services.
abstract class LocationProvider {
  /// Returns a [Future] containing a [bool] indicating whether location
  /// services are enabled on the device.
  Future<bool> isLocationServiceEnabled();

  /// Returns a [Future] containing a [LocationPermission] enum that indicates
  /// the current location permission status for the application.
  Future<LocationPermission> checkPermission();

  /// Requests permission from the user to access the device's location.
  ///
  /// Returns a [Future] containing the new [LocationPermission] status.
  Future<LocationPermission> requestPermission();

  /// Returns a [Future] containing the current [Position] of the device.
  ///
  /// Throws an exception if permissions are not granted.
  Future<Position> getCurrentPosition();

  /// Converts a physical [address] string into geographic coordinates.
  ///
  /// This method performs an asynchronous geocoding lookup and returns the
  /// most relevant [LatLng] for the provided address.
  ///
  /// [address] is the physical address string to resolve.
  ///
  /// Returns a [Future] containing the resulting [LatLng].
  ///
  /// Throws an exception if the address cannot be resolved or if the
  /// underlying service fails.
  Future<LatLng> locationFromAddress(String address);
}
