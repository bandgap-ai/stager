import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../mapping/location_editor.dart';
import 'stager_editor.dart';
import '../tree/tree.dart';
import 'standard_widgets.dart';
import 'basic_widget_factory.dart';
import '../system/point.dart';

import '../system/typed_value.dart';

/// A dialog for editing node properties.
///
/// This widget provides a basic structure for an alert dialog that can be used
/// to edit the properties of a tree node. It dynamically generates input fields
/// for each property, allowing for editing of string, latitude, and longitude
/// values.
class LeafNodeEditor extends StagerEditor<LeafNode> {

  /// Creates a [LeafNodeEditor] widget.
  const LeafNodeEditor({super.key, required super.state, super.widgetFactory = const BasicWidgetFactory()});

  @override
  State<LeafNodeEditor> createState() => _NodeEditorState();
}

/// The state for the [LeafNodeEditor] widget.
///
/// Manages the [TextEditingController]s for each property and handles the
/// logic for saving and canceling edits.
class _NodeEditorState extends State<LeafNodeEditor> {

  /// The properties of the node to be edited.
  late NodeProperties properties;

  /// A map to store [TextEditingController]s for string-based properties.
  final Map<String, TextEditingController> _textControllers = {};

  /// The current selection for the position input method (map or coordinates).
  late bool _pickFromMap;

  @override
  void initState() {
    super.initState();
    properties = widget.state.properties;
    // Initialize controllers for each property based on their type.

    // FIXME! This is where the name, id, latitude and longitude would normally
    // be created if they were still part of the the properties map.

    // Create text controllers for the name, id, and position
    _textControllers['name'] = TextEditingController(text: widget.state.name);
    _textControllers['id'] = TextEditingController(text: widget.state.id.toString());
    final longitude = widget.state.position.coords[0];
    final latitude = widget.state.position.coords[1];
    _textControllers['latitude'] = TextEditingController(text: latitude.toString());
    _textControllers['longitude'] = TextEditingController(text: longitude.toString());

    // Create text controllers for each generic property in the node properties.
    properties.map.forEach((key, typedValue) {
      // For all properties, create a TextEditingController.
      _textControllers[key] = TextEditingController(text: typedValue.value.toString() ?? '');
    });

    // Initialize _pickFromMap based on whether latitude/longitude exist
    _pickFromMap = !(widget.state.position != Point() ||
    widget.state.position != LeafNode.defaultPosition);
  }

  // Call back for point picking on the map
  void _onPointChanged(LatLng newPoint) {
    setState(() {
      // Update the point in the text controllers
      _textControllers['latitude']!.text = newPoint.latitude.toString();
      _textControllers['longitude']!.text = newPoint.longitude.toString();
    });
  }

  @override
  void dispose() {
    // Dispose all created TextEditingController to prevent memory leaks.
    _textControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String info = 'Please configure the node.';

    return AlertDialog(
      title: const Text('Edit Node Properties'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display an informational label at the top of the dialog.
            buildInfoLabel(context,info),
            // Dynamically build text field editors for all properties
            // except 'id' (because it is private)
            ...properties.map.entries.where((entry) => entry.key != 'id' ).map((entry) {
              return buildTextFieldEditor(
                context,
                _textControllers[entry.key]!, // Use the pre-initialized controller
                '${_spruceUpKey(entry.key)}:', // Spruce up the key for display
                'Enter ${entry.key}', // Hint text
              );
            }),
            SizedBox(height: 8),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                child: LocationEditor(
                    initialLocation: widget.state.position.toLatLng(),
                    onLocationChanged: (LatLng location) {
                      _onPointChanged(location);
                    }),
              ),
          ],
        ),
      ),
      actions: [
        // Cancel button: Pops the dialog and returns an empty map.
        TextButton(
          onPressed: () => Navigator.of(context).pop<Map<String, Object>>({}),
          child: const Text('Cancel'),
        ),
        // Save button: Collects updated values and pops the dialog with the result.
        TextButton(
          onPressed: () {
            // Map the text controller properties straight to Map<String,Object>
            // and pop it like its hoooooooottt.
            final updatedProperties = Map<String,Object>.from(_textControllers.map((key,value) {
              return MapEntry(key,value.text);
            }));
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
