import 'package:flutter/material.dart';

/// Defines the method for picking a location.
enum LocationPickerMethod {
  /// Automatically determine the location using device services.
  auto,

  /// Pick a location manually from a map.
  map,

  /// Enter a location by typing an address.
  address,
}

/// A widget that allows users to select how they want to determine a location
/// using a segmented button.
class LocationPicker extends StatefulWidget {
  /// Callback for when the user selects a new method.
  final ValueChanged<LocationPickerMethod> onSelectionChanged;

  /// The initially selected method.
  final LocationPickerMethod initialSelection;

  /// Creates a [LocationPicker].
  const LocationPicker({
    super.key,
    required this.onSelectionChanged,
    this.initialSelection = LocationPickerMethod.auto,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late Set<LocationPickerMethod> _selection;

  @override
  void initState() {
    super.initState();
    _selection = {widget.initialSelection};
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SegmentedButton<LocationPickerMethod>(
            segments: const <ButtonSegment<LocationPickerMethod>>[
              ButtonSegment<LocationPickerMethod>(
                value: LocationPickerMethod.auto,
                icon: Tooltip(message: 'Locate Me', child: Icon(Icons.my_location)),
              ),
              ButtonSegment<LocationPickerMethod>(
                value: LocationPickerMethod.map,
                icon: Tooltip(message: 'Pick from Map', child: Icon(Icons.pin_drop)),
              ),
              ButtonSegment<LocationPickerMethod>(
                value: LocationPickerMethod.address,
                icon: Tooltip(message: 'Enter Address', child: Icon(Icons.edit_location)),
              ),
            ],
            selected: _selection,
            onSelectionChanged: (Set<LocationPickerMethod> newSelection) {
              // A SegmentedButton can be configured to allow multiple or empty
              // selections. This implementation enforces a single selection.
              if (newSelection.isNotEmpty) {
                setState(() {
                  _selection = newSelection;
                });
                widget.onSelectionChanged(newSelection.first);
              }
            },
          ),
        ],
      ),
    );
  }
}
