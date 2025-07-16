/// This file defines the EditNodeDialog widget, used for editing a TreeNode's name.
library;
import 'package:flutter/material.dart';
import 'package:stager/tree/tree.dart';

/// A dialog widget for editing the name of a [LeafNode].
///
/// This dialog displays a [TextField] pre-filled with the current node's name.
/// Users can modify the name and save the changes, which returns the updated name.
class EditNodeDialog extends StatefulWidget {
  /// The [NodeProperties] to be edited.
  final NodeProperties properties;

  /// Creates an [EditNodeDialog].
  ///
  /// Requires the [properties] to be edited.
  const EditNodeDialog({super.key, required this.properties});

  @override
  State<EditNodeDialog> createState() => _EditNodeDialogState();
}

/// The state for the [EditNodeDialog] widget.
class _EditNodeDialogState extends State<EditNodeDialog> {
  /// Controller for the text field, pre-filled with the node's current name.
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.properties.getProperty('name') as String);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Node'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: 'Name'),
      ),
      actions: [
        // Cancel button: dismisses the dialog without saving changes.
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        // Save button: returns the updated name through the dialog's pop method.
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_nameController.text);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}