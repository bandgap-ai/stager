import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Mocks the underlying platform implementation of the `geolocator` plugin.
///
/// The `geolocator` plugin uses static methods, which makes it difficult to
/// mock with standard mock libraries like Mockito alone. The recommended approach
/// is to mock its platform interface, `GeolocatorPlatform`.
///
/// By setting `GeolocatorPlatform.instance` to an instance of this mock in our
/// tests, we can intercept any calls to `Geolocator.isLocationServiceEnabled()`,
/// `Geolocator.getCurrentPosition()`, etc., and verify that our provider is
/// forwarding the calls correctly without actually hitting the device hardware.
class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {

  /// Mocks the `isLocationServiceEnabled` method.
  ///
  /// This override intercepts the call and provides a default return value.
  /// Tests can use `when(...).thenAnswer(...)` to provide a specific
  /// response for a given scenario.
  @override
  Future<bool> isLocationServiceEnabled() {
    return super.noSuchMethod(
      Invocation.method(#isLocationServiceEnabled, []),
      returnValue: Future.value(true),
      returnValueForMissingStub: Future.value(true),
    );
  }

  /// Mocks the `checkPermission` method.
  ///
  /// This override intercepts the call and provides a default return value.
  /// Tests can use `when(...).thenAnswer(...)` to provide a specific
  /// response for a given scenario.
  @override
  Future<LocationPermission> checkPermission() {
    return super.noSuchMethod(
      Invocation.method(#checkPermission, []),
      returnValue: Future.value(LocationPermission.always),
      returnValueForMissingStub: Future.value(LocationPermission.always),
    );
  }

  /// Mocks the `requestPermission` method.
  ///
  /// This override intercepts the call and provides a default return value.
  /// Tests can use `when(...).thenAnswer(...)` to provide a specific
  /// response for a given scenario.
  @override
  Future<LocationPermission> requestPermission() {
    return super.noSuchMethod(
      Invocation.method(#requestPermission, []),
      returnValue: Future.value(LocationPermission.always),
      returnValueForMissingStub: Future.value(LocationPermission.always),
    );
  }

  /// Mocks the `getCurrentPosition` method.
  ///
  /// This override intercepts the call and provides a default return value.
  /// Tests can use `when(...).thenAnswer(...)` to provide a specific
  /// response for a given scenario, including the `locationSettings` parameter.
  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) {
    return super.noSuchMethod(
      Invocation.method(#getCurrentPosition, [], {#locationSettings: locationSettings}),
      returnValue: Future.value(Position(latitude: 1, longitude: 1, timestamp: DateTime.now(), accuracy: 1, altitude: 1, altitudeAccuracy: 1, heading: 1, headingAccuracy: 1, speed: 1, speedAccuracy: 1)),
      returnValueForMissingStub: Future.value(Position(latitude: 1, longitude: 1, timestamp: DateTime.now(), accuracy: 1, altitude: 1, altitudeAccuracy: 1, heading: 1, headingAccuracy: 1, speed: 1, speedAccuracy: 1)),
    );
  }
}
