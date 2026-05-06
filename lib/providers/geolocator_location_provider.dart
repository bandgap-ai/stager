import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:stager_platform/providers/location_provider.dart';
import 'geolocation_exception.dart';

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

  @override
  Future<LatLng> locationFromAddress(String address) async {
    late LatLng result;

    // Construct the Nominatim query URL. We request JSON format and limit
    // the results to the single most relevant match.
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1',
    );

    // Perform the GET request. Nominatim requires a descriptive User-Agent
    // header to identify the application and prevent blocking.
    final response = await http.get(
      uri,
      headers: {'User-Agent': 'StagerPlatform/0.0.1 (ai.bandgap.stager)'},
    );

    // Process the response based on the status code. We handle the
    // success case (200 OK) first to optimize for branch prediction.
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // If the list is not empty, parse the first result.
      if (data.isNotEmpty) {
        final first = data.first;

        // Nominatim returns latitude and longitude as strings in the JSON
        // response, so we must parse them into doubles.
        result = LatLng(double.parse(first['lat']), double.parse(first['lon']));
      } else {
        // Throw an exception if no results were found for the specific address.
        throw GeolocationException('No location found for address: $address');
      }
    } else {
      // Throw an exception for non-200 status codes, capturing the status
      // for debugging.
      throw GeolocationException(
        'Failed to resolve address. Status: ${response.statusCode}',
      );
    }

    return result;
  }
}
