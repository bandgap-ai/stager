import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:stager_platform/editors/standard_widgets.dart';

/// A dialog for adding a new site.
///
/// This dialog prompts the user to enter a name for a new site. When the "Add"
/// button is pressed, it invokes the [onAdd] callback with the entered name.
class AddSiteDialog extends StatefulWidget {
  /// The callback to be invoked when a site is added.
  final Function(Map<String, Object>) onAdd;

  /// Creates an "Add Site" dialog.
  const AddSiteDialog({super.key, required this.onAdd});

  @override
  State<AddSiteDialog> createState() => _AddSiteDialogState();
}

/// The state for the [AddSiteDialog].
class _AddSiteDialogState extends State<AddSiteDialog> {
  /// The controller for the text field.
  final _nameFieldController = TextEditingController();
  /// The controller for the latitude field.
  final _latitudeController = TextEditingController();
  /// The controller for the longitude field.
  final _longitudeController = TextEditingController();
  /// The initial value for the coordinate configuration button.
  final LatLng _initialPoint = LatLng(38.989693,-77.968797);
  /// Sets the initial value for the coordinate configuration button.
  bool _pickFromMap = false;

  @override
  void initState() {
    super.initState();
    // Set the initial point values for the coordinate editor
    _latitudeController.text = _initialPoint.latitude.toString();
    _longitudeController.text = _initialPoint.longitude.toString();
  }

  @override
  void dispose() {
    // Don't forget to dispose of controllers
    _nameFieldController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  // Call back for point picking on the map
  void _onPointChanged(LatLng newPoint) {
    setState(() {
      // Update the point in the text controllers
      _latitudeController.text = newPoint.latitude.toString();
      _longitudeController.text = newPoint.longitude.toString();
    });
  }

  /// Builds the add site dialog content
  ///
  /// [context] is the context for the dialog.
  Widget _buildAddSiteDialog(BuildContext context) {
    String info = 'Please configure the site information.';
    // Be a content creator!
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildInfoLabel(context,info),
        buildTextFieldEditor(context, _nameFieldController,
            'Site Name:', 'Enter site name...'),
        const SizedBox(height: 8),
        buildPositionMethodWidget(context,_pickFromMap,(value){
          setState(() {
            _pickFromMap = value;
          });}),
        const SizedBox(height: 8),
        SizedBox(
          width: _pickFromMap ? MediaQuery.of(context).size.width*0.8 : null,
          height: _pickFromMap ? MediaQuery.of(context).size.height*0.5 : null,
          child: _pickFromMap ? buildSinglePointMapEditor(context,_initialPoint,_onPointChanged) :
            buildGeoCoordEditor(context,
                _latitudeController,
                _longitudeController),
        )
      ],
    );

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Site'),
      content: _buildAddSiteDialog(context),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        // Add button
        TextButton(
          onPressed: () {
            Map<String, Object> nodeInfo = {};
            // Must at least have the name
            if (_nameFieldController.text.isNotEmpty) {
                nodeInfo['name'] = _nameFieldController.text;
                nodeInfo['latitude'] = _latitudeController.text;
                nodeInfo['longitude'] = _longitudeController.text;
            }
            widget.onAdd(nodeInfo);
            Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

}
