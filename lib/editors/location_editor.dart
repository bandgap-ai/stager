import 'package:flutter/material.dart';
import 'package:stager_platform/editors/standard_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stager_platform/providers/geolocator_location_provider.dart';
import 'package:stager_platform/providers/location_provider.dart';

/// An editor widget for selecting a location.
///
/// This widget provides UI for:
/// - Displaying latitude and longitude coordinates.
/// - Fetching the device's current location.
/// - Manually entering an address.
class LocationEditor extends StatefulWidget {
  /// The provider used to fetch location data.
  final LocationProvider locationProvider;

  /// Creates a [LocationEditor] widget.
  ///
  /// An optional [locationProvider] can be supplied for testing or to customize
  /// location data fetching. If not provided, it defaults to an instance of
  /// [GeolocatorLocationProvider].
  const LocationEditor({
    super.key,
    this.locationProvider = const GeolocatorLocationProvider(),
  });

  @override
  State<LocationEditor> createState() => _LocationEditorState();
}

class _LocationEditorState extends State<LocationEditor> {
  /// Controls the text field for latitude.
  final TextEditingController latitudeController = TextEditingController(text: '38.926241');

  /// Controls the text field for longitude.
  final TextEditingController longitudeController = TextEditingController(text: '-77.932909');

  /// Controls the text field for the address.
  final TextEditingController addressController = TextEditingController();

  /// Fetches the current location and updates the UI.
  ///
  /// On failure, it displays an error message in a [SnackBar].
  Future<void> _handleGetLocation() async {
    try {
      // Get the current position from the location provider.
      final position = await _determinePosition();

      // Update the state to refresh the UI with the new coordinates.
      setState(() {
        latitudeController.text = position.latitude.toString();
        longitudeController.text = position.longitude.toString();
      });
    } catch (e) {
      // If an error occurs (e.g., permissions denied), show a snackbar.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  /// Determine the current position of the device.
  ///
  /// This method follows the complete process recommended by the `geolocator`
  /// package documentation to ensure a robust location-fetching experience.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await widget.locationProvider.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled; return an error.
      return Future.error('Location services are disabled.');
    }

    // Check the current permission status.
    permission = await widget.locationProvider.checkPermission();
    if (permission == LocationPermission.denied) {
      // If permission is denied, request it from the user.
      permission = await widget.locationProvider.requestPermission();
      if (permission == LocationPermission.denied) {
        // If the user denies the request, return an error.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // If permissions are permanently denied, we cannot ask again.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // If we reach here, permissions are granted. Return the current position.
    return await widget.locationProvider.getCurrentPosition();
  }

  /// Builds the panel with the 'Get my location' button and address editor.
  Widget _buildActionPanel() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _handleGetLocation,
          child: const Text('Get my location'),
        ),
        buildTextFieldEditor(context, addressController, 'Address', ''),
      ],
    );
  }

  /// Builds the UI for the location editor, including text fields for latitude
  /// and longitude, a button to fetch the current location, and a text field
  /// for a manual address.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildGeoCoordEditor(context, latitudeController, longitudeController),
        Expanded(
          child: _buildActionPanel(),
        ),
      ],
    );
  }
}
