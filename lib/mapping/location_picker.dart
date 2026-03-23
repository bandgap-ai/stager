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

  /// This function builds the 3-piece segmented button that is displayed to the
  /// user to allow them to automatically measure their position, pick one from
  /// a map, or enter an address. Note this doesn't have to be limited to
  /// real-world locations.
  SegmentedButton<LocationPickerMethod> _buildSegmentedButton(BuildContext context) {

    // Define the three button segments. The first is the hardware location
    // option.
    const locateMeButtonSegment = ButtonSegment<LocationPickerMethod>(
      value: LocationPickerMethod.auto,
      icon: Tooltip(message: 'Locate Me', child: Icon(Icons.my_location)),
    );
    // The second allows the user to pick from a map.
    const pickFromMapButtonSegment = ButtonSegment<LocationPickerMethod>(
      value: LocationPickerMethod.map,
      icon: Tooltip(message: 'Pick from Map', child: Icon(Icons.pin_drop)),
    );
    // The third allows the user to manually specify an address. Note this isn't
    // restricted here to a physical address.
    const enterAddressButtonSegment = ButtonSegment<LocationPickerMethod>(
      value: LocationPickerMethod.address,
      icon: Tooltip(message: 'Enter Address', child: Icon(Icons.edit_location)),
    );

    // Assemble the segments into the parent button and configure the callback.
    final segmentedButton = SegmentedButton<LocationPickerMethod>(
      segments: const <ButtonSegment<LocationPickerMethod>>[
        locateMeButtonSegment,
        pickFromMapButtonSegment,
        enterAddressButtonSegment,
      ],
      selected: _selection,
      onSelectionChanged: (Set<LocationPickerMethod> newSelection) {
        // Only process the selection if it is not empty
        if (newSelection.isNotEmpty) {
          setState(() {
            _selection = newSelection;
          });
          // SegementedButtons support multiple selections, but we only
          // want the first.
          widget.onSelectionChanged(newSelection.first);
        }
      },
    );

    return segmentedButton;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSegmentedButton(context),
        ],
      ),
    );
  }

}
