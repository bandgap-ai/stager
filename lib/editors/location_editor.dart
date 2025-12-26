import 'package:flutter/material.dart';
import 'package:stager_platform/editors/location_picker.dart';
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
  /// The currently selected method for picking a location.
  LocationPickerMethod _selectedMethod = LocationPickerMethod.auto;

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
      final position = await _determinePosition();
      setState(() {
        latitudeController.text = position.latitude.toString();
        longitudeController.text = position.longitude.toString();
      });
    } catch (e) {
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

    serviceEnabled = await widget.locationProvider.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await widget.locationProvider.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await widget.locationProvider.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await widget.locationProvider.getCurrentPosition();
  }

  /// Builds the panel with the action widgets based on the selected method.
  Widget _buildActionPanel() {
    switch (_selectedMethod) {
      case LocationPickerMethod.auto:
        return ElevatedButton(
          onPressed: _handleGetLocation,
          child: const Text('Get my location'),
        );
      case LocationPickerMethod.map:
        // Placeholder for map picker functionality
        return const Center(child: Text('Map picker not implemented.'));
      case LocationPickerMethod.address:
        return buildTextFieldEditor(context, addressController, 'Address', '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildGeoCoordEditor(context, latitudeController, longitudeController),
        LocationPicker(
          onSelectionChanged: (LocationPickerMethod method) {
            setState(() {
              _selectedMethod = method;
            });
          },
        ),
        Expanded(
          child: _buildActionPanel(),
        ),
      ],
    );
  }
}
