import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:stager/tree/tree.dart';
import 'package:stager/editors/standard_widgets.dart';

/// A dialog for editing node properties.
///
/// This widget provides a basic structure for an alert dialog that can be used
/// to edit the properties of a tree node. It dynamically generates input fields
/// for each property, allowing for editing of string, latitude, and longitude
/// values.
class NodeEditor extends StatefulWidget {
  /// The properties of the node to be edited.
  final NodeProperties properties;

  /// Creates a [NodeEditor] widget.
  const NodeEditor({super.key, required this.properties});

  @override
  State<NodeEditor> createState() => _NodeEditorState();
}

/// The state for the [NodeEditor] widget.
///
/// Manages the [TextEditingController]s for each property and handles the
/// logic for saving and canceling edits.
class _NodeEditorState extends State<NodeEditor> {
  /// A map to store [TextEditingController]s for string-based properties.
  final Map<String, TextEditingController> _controllers = {};

  

  /// The current selection for the position input method (map or coordinates).
  late bool _pickFromMap;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each property based on their type.
    widget.properties.map.forEach((key, value) {
      // For all properties, create a TextEditingController.
      _controllers[key] = TextEditingController(text: value?.toString() ?? '');
    });

    // Initialize _pickFromMap based on whether latitude/longitude exist
    _pickFromMap = !(widget.properties.map.containsKey('latitude') ||
        widget.properties.map.containsKey('longitude'));
  }

  // Call back for point picking on the map
  void _onPointChanged(LatLng newPoint) {
    setState(() {
      // Update the point in the text controllers
      _controllers['latitude']!.text = newPoint.latitude.toString();
      _controllers['longitude']!.text = newPoint.longitude.toString();
    });
  }

  @override
  void dispose() {
    // Dispose all created TextEditingController to prevent memory leaks.
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Node Properties'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display an informational label at the top of the dialog.
            buildInfoLabel(context),
            // Dynamically build text field editors for all properties
            // except 'id', 'name', 'latitude', and 'longitude'.
            ...widget.properties.map.entries.where((entry) => entry.key != 'id' && entry.key != 'name' && entry.key != 'latitude' && entry.key != 'longitude').map((entry) {
              return buildTextFieldEditor(
                context,
                _controllers[entry.key]!, // Use the pre-initialized controller
                '${_spruceUpKey(entry.key)}:', // Spruce up the key for display
                'Enter ${entry.key}', // Hint text
              );
            }).toList(),
            // If latitude or longitude properties exist, build a geographic coordinate editor.
            if (widget.properties.map.containsKey('latitude') || widget.properties.map.containsKey('longitude'))
              buildPositionMethodWidget(context, _pickFromMap, (value) {
                setState(() {
                  _pickFromMap = value;
                });
              }),
            if (widget.properties.map.containsKey('latitude') || widget.properties.map.containsKey('longitude'))
              SizedBox(
                width: _pickFromMap ? MediaQuery.of(context).size.width * 0.8 : null,
                height: _pickFromMap ? MediaQuery.of(context).size.height * 0.5 : null,
                child: _pickFromMap
                    ? buildSinglePointMapEditor(
                        context,
                        LatLng(
                          double.tryParse(_controllers['latitude']!.text) ?? 0.0,
                          double.tryParse(_controllers['longitude']!.text) ?? 0.0,
                        ),
                        _onPointChanged,
                      )
                    : buildGeoCoordEditor(
                        context,
                        _controllers['latitude']!,
                        _controllers['longitude']!,
                      ),
              ),
          ],
        ),
      ),
      actions: [
        // Cancel button: Pops the dialog and returns null.
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        // Save button: Collects updated values and pops the dialog with the result.
        TextButton(
          onPressed: () {
            // Create a mutable copy of the properties map.
            final updatedProperties = Map<String, dynamic>.from(widget.properties.map);
            _controllers.forEach((key, controller) {
              if (key == 'latitude' || key == 'longitude') {
                updatedProperties[key] = double.tryParse(controller.text);
              } else {
                updatedProperties[key] = controller.text;
              }
            });
            Navigator.of(context).pop(updatedProperties);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  /// Formats a given string key into a more readable, human-friendly format.
  ///
  /// This function performs the following transformations:
  /// 1. Replaces underscores (`_`) or hyphens (`-`) with spaces.
  /// 2. Handles camelCase or PascalCase by inserting spaces before uppercase
  ///    letters (if they are preceded by a lowercase letter or a digit).
  /// 3. Trims any leading/trailing spaces introduced during the process.
  /// 4. Capitalizes the first letter of each word.
  ///
  /// [key]: The string key to be formatted.
  /// Returns: A "spruced up" version of the key.
  String _spruceUpKey(String key) {
    if (key.isEmpty) {
      return '';
    }

    // 1. Replace common separators with spaces
    String spacedKey = key.replaceAll('_', ' ').replaceAll('-', ' ');

    // 2. Handle camelCase or PascalCase by inserting spaces before uppercase letters
    // (if preceded by a lowercase letter or a digit)
    // Example: "firstName" -> "first Name", "version2Update" -> "version2 Update"
    // Example: "APIKey" -> "API Key"
    spacedKey = spacedKey.replaceAllMapped(
      RegExp(r'(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])'),
          (Match m) => ' ${m[0]}',
    );

    // 3. Trim leading/trailing spaces that might have been introduced
    spacedKey = spacedKey.trim();

    // 4. Capitalize the first letter of each word
    if (spacedKey.isEmpty) { // Check again after trimming and potential regex changes
      return '';
    }

    List<String> words = spacedKey.split(' ');
    List<String> capitalizedWords = words.map((word) {
      if (word.isEmpty) {
        return '';
      }
      // Capitalize the first letter and keep the rest of the word as is.
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).toList();

    return capitalizedWords.join(' ');
  }
}
