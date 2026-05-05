import 'package:flutter/material.dart';
import 'package:stager_platform/mapping/location_picker.dart';
import 'package:stager_platform/editors/standard_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:stager_platform/providers/geolocator_location_provider.dart';
import 'package:stager_platform/providers/location_provider.dart';
import 'package:logger/logger.dart';

/// An editor widget for selecting a location.
///
/// This widget provides UI for:
/// - Displaying latitude and longitude coordinates.
/// - Fetching the device's current location.
/// - Manually entering an address.
class LocationEditor extends StatefulWidget {

  /// Default initial location shown by the editor
  static const LatLng _defaultLocation = LatLng(40.8624, -73.8774);

  /// Initial location shown by the editor
  final LatLng initialLocation;

  /// The provider used to fetch location data.
  final LocationProvider locationProvider;

  /// The logger for capturing events and errors.
  final Logger? logger;

  /// Callback triggered whenever the coordinates are updated via location
  /// services or manual entry.
  final void Function(LatLng) onLocationChanged;

  /// Creates a [LocationEditor] widget.
  ///
  /// An optional [locationProvider] can be supplied for testing or to customize
  /// location data fetching. If not provided, it defaults to an instance of
  /// [GeolocatorLocationProvider].
  ///
  /// An optional [logger] can be supplied for testing.
  const LocationEditor({
    super.key,
    this.locationProvider = const GeolocatorLocationProvider(),
    this.logger,
    this.onLocationChanged = _defaultOnLocationChanged,
    this.initialLocation = _defaultLocation,
  });

  /// Default callback that logs the location update.
  static void _defaultOnLocationChanged(LatLng location) {
    Logger().i('Location updated: $location');
  }

  @override
  State<LocationEditor> createState() => _LocationEditorState();
}

class _LocationEditorState extends State<LocationEditor> {
  late final Logger log;

  /// The currently selected method for picking a location.
  LocationPickerMethod _selectedMethod = LocationPickerMethod.auto;

  /// Controls the text field for latitude.
  late TextEditingController latitudeController;

  /// Controls the text field for longitude.
  late TextEditingController longitudeController;

  /// Controls the text field for the address.
  late TextEditingController addressController;

  /// Tracks the last location sent to the parent to avoid redundant updates
  /// caused by focus or selection changes in the text controllers.
  late LatLng _lastNotifiedLocation;

  @override
  void initState() {
    super.initState();
    log = widget.logger ?? Logger();
    _lastNotifiedLocation = widget.initialLocation;

    /// Controls the text field for latitude.
    latitudeController = TextEditingController(
        text: widget.initialLocation.latitude.toString());
    latitudeController.addListener(_onControllerChanged);

    /// Controls the text field for longitude.
    longitudeController = TextEditingController(
        text: widget.initialLocation.longitude.toString());
    longitudeController.addListener(_onControllerChanged);

    /// Controls the text field for the address.
    addressController = TextEditingController(
        text: 'New York Botanical Garden');
  }

  @override
  void dispose() {
    // Remove listeners to avoid calling setState or widget callbacks
    // after disposal.
    latitudeController.removeListener(_onControllerChanged);
    longitudeController.removeListener(_onControllerChanged);

    latitudeController.dispose();
    longitudeController.dispose();
    addressController.dispose();
    super.dispose();
  }

  /// Listens for changes in the coordinate controllers and notifies the parent.
  void _onControllerChanged() {
    final lat = double.tryParse(latitudeController.text);
    final lng = double.tryParse(longitudeController.text);
    if (lat != null && lng != null) {
      final newLocation = LatLng(lat, lng);
      // Only notify if the coordinates have actually changed. This prevents
      // redundant notifications (e.g., on focus or selection changes).
      if (newLocation != _lastNotifiedLocation) {
        _lastNotifiedLocation = newLocation;
        widget.onLocationChanged(newLocation);
      }
    }
  }

  /// Fetches the current location and updates the UI.
  ///
  /// On success, the UI is updated, which triggers the listeners and
  /// subsequently the [widget.onLocationChanged] callback.
  /// On failure, it logs the error.
  Future<void> _handleGetLocation() async {
    try {
      final position = await _samplePosition();
      
      setState(() {
        latitudeController.text = position.latitude.toString();
        longitudeController.text = position.longitude.toString();
      });
    } catch (e) {
      log.log(Level.error, e.toString());
    }
  }

  /// Fetches coordinates for the entered address and updates the UI.
  ///
  /// On success, the UI is updated, which triggers the listeners and
  /// subsequently the [widget.onLocationChanged] callback.
  /// On failure, it logs the error.
  Future<void> _handleAddressLookup() async {
    final String address = addressController.text;

    // Happy path first: only proceed if the address is not empty.
    if (address.isNotEmpty) {
      try {
        final LatLng location =
            await widget.locationProvider.locationFromAddress(address);

        setState(() {
          latitudeController.text = location.latitude.toString();
          longitudeController.text = location.longitude.toString();
        });
      } catch (e) {
        log.e('Failed to lookup address "$address": $e');
      }
    } else {
      log.w('Address lookup attempted with an empty address string.');
    }
  }

  /// Determine the current position of the device.
  ///
  /// This method follows the complete process recommended by the `geolocator`
  /// package documentation to ensure a robust location-fetching experience.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _samplePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    late Future<Position> position;

    serviceEnabled = await widget.locationProvider.isLocationServiceEnabled();
    if (serviceEnabled) {
      // Check permissions.
      permission = await widget.locationProvider.checkPermission();
      // This strikes me as a less than optimal way to handle a request for
      // permissions, but it is in the official example from BaseFlow. So, I'm
      // going with it.
      if (permission != LocationPermission.denied) {
        position = widget.locationProvider.getCurrentPosition();
      } else if (permission == LocationPermission.denied) {
        permission = await widget.locationProvider.requestPermission();
        if (permission != LocationPermission.denied) {
          position = widget.locationProvider.getCurrentPosition();
        } else {
          position = Future.error('The user declined to grant permission to use '
              'location services.');
        }
      } else if (permission == LocationPermission.deniedForever) {
        // Complain if the user has blocked the services forever.
        position = Future.error(
            'The user has permanently denied access to location services for '
            'this application, and we cannot request access to or use the '
            'services.');
      }
    } else {
      position = Future.error('Location services are disabled.');
    }

    // At the "expense" of a second future, this will automatically return the
    // disabled error message without branching.
    return position;
  }

  /// This function builds the panel of widgets used for auto-detecting the
  /// user's location.
  Widget _buildAutoLocatorPanel(BuildContext context) {
    return Column(children: [
      const Text('We respect your privacy. Please press the button '
          'below to determine your location automatically with location '
          'services. You may be asked by your device to grant permission.'),
      ElevatedButton(
        onPressed: _handleGetLocation,
        child: const Text('Get my location'),
      )
    ]);
  }

  /// This function builds the panel of widgets used for looking up an address.
  Widget _buildAddressPanel(BuildContext context) {
    late final Widget result;

    result = Column(
      children: [
        buildTextFieldEditor(context, addressController, 'Address', ''),
        const SizedBox(height: 16.0),
        ElevatedButton.icon(
          onPressed: _handleAddressLookup,
          icon: const Icon(Icons.search),
          label: const Text('Lookup Address'),
        ),
      ],
    );

    return result;
  }

  /// Builds the panel with the action widgets based on the selected method.
  Widget _buildActionPanel() {
    late final Widget result;

    switch (_selectedMethod) {
      case LocationPickerMethod.auto:
        result = _buildAutoLocatorPanel(context);
      case LocationPickerMethod.map:
        // Placeholder for map picker functionality
        result = const Center(child: Text('Map picker not implemented.'));
      case LocationPickerMethod.address:
        result = _buildAddressPanel(context);
    }

    return SingleChildScrollView(child: result);
  }

  @override
  Widget build(BuildContext context) {
    // This creates a column widget with the base coordinates at the top,
    // followed by a selector widget, and an action panel where picker widgets
    // can be drawn for the selected method.
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
