import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
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
  late Map<String,Object> properties;

  /// A map to store [TextEditingController]s for string-based properties.
  final Map<String, TextEditingController> _textControllers = {};

  /// The current selection for the position input method (map or coordinates).
  late bool _pickFromMap;

  @override
  void initState() {
    super.initState();
    properties = widget.state.toMap();
    // Initialize controllers for each property based on their type.
    properties.forEach((key, value) {
      // For all properties, create a TextEditingController.
      if (value is TypedValue) {
        _textControllers[key] =
            TextEditingController(text: value.value.toString());
      } else {
        _textControllers[key] = TextEditingController(text: value.toString());
      }
    });

    // Initialize _pickFromMap based on whether latitude/longitude exist
    final position = widget.state.position;
    _pickFromMap = !(position.coords != Point.defaultPosition);
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
            // except 'id' (because it is private), and lat/long because
            // they are edited with a different widget.
            ...properties.entries.where((entry) => entry.key != 'id' && entry.key != 'latitude' && entry.key != 'longitude').map((entry) {
              return buildTextFieldEditor(
                context,
                _textControllers[entry.key]!, // Use the pre-initialized controller
                '${_spruceUpKey(entry.key)}:', // Spruce up the key for display
                'Enter ${entry.key}', // Hint text
              );
            }),
            // Build a geographic coordinate editor.
            buildPositionMethodWidget(context, _pickFromMap, (value) {
                setState(() {
                  _pickFromMap = value;
                });
              }),
            SizedBox(height: 8),
            SizedBox(
                width: _pickFromMap ? MediaQuery.of(context).size.width * 0.8 : null,
                height: _pickFromMap ? MediaQuery.of(context).size.height * 0.5 : null,
                child: _pickFromMap
                    ? buildSinglePointMapEditor(
                        context,
                        LatLng(
                          double.tryParse(_textControllers['latitude']!.text) ?? 0.0,
                          double.tryParse(_textControllers['longitude']!.text) ?? 0.0,
                        ),
                        _onPointChanged,
                      )
                    : buildGeoCoordEditor(
                        context,
                        _textControllers['latitude']!,
                        _textControllers['longitude']!,
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
            // FIXME - WILL NEED TO ADJUST THIS!
            final updatedProperties = Map<String, TypedValue<Object>>.from(properties);
            _textControllers.forEach((key, controller) {
              if (key == 'latitude' || key == 'longitude') {
                updatedProperties[key] = TypedValue<double>(double.tryParse(controller.text)!);
              } else {
                updatedProperties[key] = TypedValue<String>(controller.text);
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
