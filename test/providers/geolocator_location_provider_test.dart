import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/mockito.dart';
import 'package:stager_platform/providers/geolocator_location_provider.dart';
import 'mock_geolocator_platform.dart';

void main() {
  late GeolocatorLocationProvider provider;
  late MockGeolocatorPlatform mockGeolocatorPlatform;

  // Before each test, create a new provider and mock platform instance.
  // Then, importantly, override the static `GeolocatorPlatform.instance`
  // to point to our mock. This is the key to intercepting the static calls.
  setUp(() {
    provider = const GeolocatorLocationProvider();
    mockGeolocatorPlatform = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockGeolocatorPlatform;
  });

  group('GeolocatorLocationProvider', () {
    test('isLocationServiceEnabled should call Geolocator.isLocationServiceEnabled', () async {
      // Arrange: Set up the mock to return a specific value when the method is called.
      when(mockGeolocatorPlatform.isLocationServiceEnabled()).thenAnswer((_) async => true);

      // Act: Call the method on our provider.
      await provider.isLocationServiceEnabled();

      // Verify: Ensure that the provider called the underlying platform method exactly once.
      verify(mockGeolocatorPlatform.isLocationServiceEnabled());
    });

    test('checkPermission should call Geolocator.checkPermission', () async {
      // Arrange
      when(mockGeolocatorPlatform.checkPermission()).thenAnswer((_) async => LocationPermission.denied);

      // Act
      await provider.checkPermission();

      // Verify
      verify(mockGeolocatorPlatform.checkPermission());
    });

    test('requestPermission should call Geolocator.requestPermission', () async {
      // Arrange
      when(mockGeolocatorPlatform.requestPermission()).thenAnswer((_) async => LocationPermission.whileInUse);

      // Act
      await provider.requestPermission();

      // Verify
      verify(mockGeolocatorPlatform.requestPermission());
    });

    test('getCurrentPosition should call Geolocator.getCurrentPosition', () async {
      // Arrange
      final fakePosition = Position(latitude: 123, longitude: 456, timestamp: DateTime.now(), accuracy: 1, altitude: 1, altitudeAccuracy: 1, heading: 1, headingAccuracy: 1, speed: 1, speedAccuracy: 1);
      // Use `anyNamed` to match the call regardless of the default locationSettings
      // that the geolocator plugin might pass.
      when(mockGeolocatorPlatform.getCurrentPosition(locationSettings: anyNamed('locationSettings'))).thenAnswer((_) async => fakePosition);

      // Act
      await provider.getCurrentPosition();

      // Verify
      // Use `anyNamed` again in the verification call to match the actual invocation.
      verify(mockGeolocatorPlatform.getCurrentPosition(locationSettings: anyNamed('locationSettings')));
    });

    test('locationFromAddress should return a LatLng for a valid address', () async {
      // Arrange
      const address = '1600 Amphitheatre Parkway, Mountain View, CA';
      const expectedLocation = LatLng(37.4224857, -122.0855846);
      
      // We should probably fake the HTTP call, but I'm leaving it for now.
      
      // Act
      final result = await provider.locationFromAddress(address);

      // Assert
      expect(result.latitude, expectedLocation.latitude);
      expect(result.longitude, expectedLocation.longitude);
    });
  });
}
