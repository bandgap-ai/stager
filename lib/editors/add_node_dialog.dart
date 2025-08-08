/// This file defines the AddNodeDialog widget, used for adding a new TreeNode.
library;

import 'package:flutter/material.dart';
import 'package:stager/editors/site_editor.dart';
import 'package:stager/editors/message_dialog.dart';
import 'package:stager/editors/basic_widget_factory.dart';
import 'package:stager/site_state.dart';

/// A dialog widget for adding a new [TreeNode].
///
/// This dialog provides a [TextField] for the user to enter the name of the new node.
/// When the 'Add' button is pressed, the entered name is returned.
class AddNodeDialog extends SiteEditor {
  /// Creates an [AddNodeDialog].
  const AddNodeDialog({super.key,
    required super.state,
    super.widgetFactory = const BasicWidgetFactory()});

  @override
  State<AddNodeDialog> createState() => _AddNodeDialogState();
}

/// The state for the [AddNodeDialog] widget.
class _AddNodeDialogState extends State<AddNodeDialog> {
  /// Controller for the text field where the new node's name is entered.
  late TextEditingController _nameController;

  /// ValueNotifier for the checkbox state to easily update it and ensure the
  /// dialog UI reflects changes if it rebuilds.
  final ValueNotifier<bool> _isGroupNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  /// Creates the action buttons for the dialog.
  ///
  /// [context] is the context for the dialog.
  List<Widget> _createActionButtons(BuildContext context) {
    // Cancels the action
    Widget cancelButton = TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Cancel'),
    );
    // Returns the input all the way back up the stack to the editor.
    Widget addButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop<Map<String, dynamic>?>({
          'name': _nameController.text,
          'isGroup': _isGroupNotifier.value,
        });
      },
      child: const Text('Add'),
    );
    return [cancelButton, addButton];
  }

  /// Creates the input fields for the dialog.
  ///
  /// [context] is the context for the dialog.
  List<Widget> _createInputFields(BuildContext context) {
    // Build the text field for the name of the new node.
    Widget nameField = TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Name',
        hintText: 'Enter object name',
      ),
      // Ensure the name is not empty - if it is, show an error.
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a name';
        }
        return null;
      },
    );

    // Add a reasonable amount of spacing between the text field and the
    // checkbox.
    const Widget sizeBox = SizedBox(height: 5); // Spacing

    // Build the checkbox for "Is this object a group?"
    // Using CheckboxListTile for a checkbox with a label that's tappable
    Widget groupCheckBox = CheckboxListTile(
      title: const Text('Is this object a group?'),
      value: _isGroupNotifier.value,
      onChanged: (bool? newValue) {
        if (newValue != null) {
          // Update the state for the checkbox
          // This setState is from StatefulBuilder and will rebuild the dialog's content
          setState(() {
            _isGroupNotifier.value = newValue;
          });
        }
      },
      controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
      contentPadding: EdgeInsets.zero, // Remove default padding if desired
    );

    return [nameField, sizeBox, groupCheckBox];
  }

  /// Creates the content of the dialog, including the name field and grouping
  /// checkbox.
  ///
  /// [context] is the context for the dialog.
  Widget _createContent(BuildContext context) {
    Widget content = SingleChildScrollView(
      child: ListBody(children: _createInputFields(context)),
    );
    return content;
  }

  /// Creates the alert dialog.
  ///
  /// [context] is the context for the dialog.
  Widget _createAlertDialog(BuildContext context) {
    Widget dialog = AlertDialog(
      title: const Text('Create an Object'),
      content: _createContent(context),
      actions: _createActionButtons(context),
    );
    return dialog;
  }

  @override
  Widget build(BuildContext context) {

    // Figure out wha tto show and build it.
    Widget addWidget;
    SiteState state = widget.state;
    if (state.selectedNode == null) {
      // Tell the user to select a widget to edit and try again.g
      String title = "Error";
      String msg = "No node selected. "
          "Please select a site or node and try again.";
      addWidget = MessageDialog(title: title, content: msg,);
    } else if (state.selectedNode!.isComposite) {
      // Open the add node dialog
      addWidget = _createAlertDialog(context);
    } else {
      // Create a leaf node.
      String title = "Error";
      String msg = "Only groups can contain other objects. "
          "Please select a group and try again.";
      addWidget = MessageDialog(title: title, content: msg,);
    }

    return addWidget;
  }
}
