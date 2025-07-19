import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:stager/editors/single_point_map_editor.dart';
import 'package:flutter_map/flutter_map.dart';

/// Builds a function that can be used as a callback to post a notification.
///
/// [context] is the context for the notification.
Function(String) buildNotificationCallback(BuildContext context) {
  return (String message) {
    showNotification(context, message);
  };
}

/// Shows a notification to the user with the given [message] in the
/// snack bar.
///
/// [context] is the context for the notification.
/// [message] is the message to show.
void showNotification(BuildContext context, String message) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      //const SnackBar(content: Text('Export complete!')),
      SnackBar(content: Text(message)),
    );
  }
}

/// Builds a Stager-standard Message Dialog.
///
/// [context] is the context for the dialog.
/// [title] is the title of the dialog.
/// [content] is the content of the dialog.
Widget buildMessageDialog(BuildContext context, String title, String content) {
  return AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('OK'),
      ),
    ],
  );
}

/// Builds a function that can be used to build an error dialog as a callback.
///
/// [context] is the context for the dialog.
/// [title] is the title of the dialog.
/// [content] is the content of the dialog.
Function() buildErrorDialogCallback(BuildContext context, String title, String content) {
  return () async {
    //  final String msgTitle = "Error";
    //   final String errMsg = "Directory selection and exporting not available on "
    //       "this platform.";
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) {
          Widget dialog = buildMessageDialog(context, title, content);
          return dialog;
        },
      );
    }
  };
}

/// Builds a Stager-standard confirm dialog.
///
/// [context] is the context for the dialog.
/// [title] is the title of the dialog.
/// [content] is the content of the dialog.
Widget buildConfirmDialog(BuildContext context, String title, String content) {
  return AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(true),
        child: const Text('Confirm'),
      ),
    ],
  );
}

/// Builds a Stager-standard text field editor with all the bells and whistles.
///
/// Toot toot!
///
/// [context] is the context for the dialog.
/// [labelText] is the label for the text field.
/// [hintText] is the hint text for the text field.
Widget buildTextFieldEditor(BuildContext context, TextEditingController controller,
    final labelText, final hintText) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      controller: controller,
      autofocus: true,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        hintText: hintText,
      ),
    ),
  );
}

/// Builds the info label for the dialog.
///
/// [context] is the context for the dialog.
Widget buildInfoLabel(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: const Text('Please configure the site information.'),
  );
}

/// Builds the position method widget for the dialog. The selectedOption
/// parameter is updated in place.
///
/// [context] is the context for the dialog.
/// [initialSelection] is the initial selection.context
/// [onChanged] is the callback for when the selection changes.
Widget buildPositionMethodWidget(BuildContext context,
    bool initialSelection,
    void Function(bool) onChanged) {
  Widget selectorRow = Row(children: [
    const Text(
      'Position:',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    const SizedBox(width: 8),
    Flexible(
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(
            value: false,
            label: Text('Input Coordinates'),
            icon: Icon(Icons.list, size: 16),
          ),
          ButtonSegment(
            value: true,
            label: Text('Select on Map'),
            icon: Icon(Icons.map, size: 16),
          ),
        ],
        selected: {initialSelection},
        onSelectionChanged: (Set<bool> selection) {
          onChanged(selection.first);
        },
      ),
    )
  ]);

  return selectorRow;
}

/// Builds the map editor for the dialog to select a single point.
///
/// [context] is the context for the dialog.
/// [latitudeController] is the controller for the latitude field.
/// [longitudeController] is the controller for the longitude field.
Widget buildSinglePointMapEditor(BuildContext context,
  LatLng initialPoint,
  void Function(LatLng) onPointChanged,
  {List<TileLayer>? tileLayers}) {

  // Create the map editor widget
  Widget mapSelector = SinglePointMapEditor(
    initialPoint: initialPoint,
    centerPosition: initialPoint, // Initial map center
    onPointChanged: (LatLng? newPoint) {
       onPointChanged(newPoint!);
    },
    tileLayers: tileLayers,
  );

  return mapSelector;
}

/// Builds the coordinate editor for the dialog. Controller values are updated in
/// place.
///
/// [context] is the context for the dialog.
/// [latitudeController] is the controller for the latitude field.
/// [longitudeController] is the controller for the longitude field.
Widget buildGeoCoordEditor(BuildContext context,
    TextEditingController latitudeController, TextEditingController longitudeController) {
  // Pick the correct color for the border from the theme
  final ThemeData theme = Theme.of(context);
  final Color borderColorFromScheme = theme.colorScheme.outline;
  // Set the initial point values for the coordinate editor if they are empty
  if (latitudeController.text.isEmpty) latitudeController.text = "0.0";
  if (longitudeController.text.isEmpty) longitudeController.text = "0.0";
  // Create the widget
  Widget coordinateEditor = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: borderColorFromScheme),
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: Column(
                children: [
                  buildTextFieldEditor(context, latitudeController,
                      'Latitude:', 'e.g., 40.7128'),
                  const SizedBox(height: 8),
                  buildTextFieldEditor(context, longitudeController,
                      'Longitude:', 'e.g., -74.0060'),
                ]
            )
        )

      ]
  );

  return coordinateEditor;
}