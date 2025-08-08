/// This file defines the EditNodeDialog widget, used for editing a TreeNode's name.
library;
import 'package:flutter/material.dart';
import 'package:stager/tree/tree.dart';
import 'package:stager/editors/node_editor.dart';

/// A dialog widget for editing the name of a [LeafNode].
///
/// This dialog displays a [TextField] pre-filled with the current node's name.
/// Users can modify the name and save the changes, which returns the updated name.
class EditNodeDialog extends NodeEditor {

  /// Creates an [EditNodeDialog].
  ///
  /// Requires the [properties] to be edited.
  const EditNodeDialog({super.key, required super.state});

  @override
  State<EditNodeDialog> createState() => _EditNodeDialogState();

}

/// The state for the [EditNodeDialog] widget.
class _EditNodeDialogState extends State<EditNodeDialog> {

  /// The [NodeProperties] to be edited.
  late NodeProperties properties;

  /// Controller for the text field, pre-filled with the node's current name.
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    properties = widget.state.properties;
    _nameController = TextEditingController(text: properties.getProperty('name') as String);
  }

  void _cancelEdit() {
    Navigator.of(context).pop();
  }

  void _saveEdit() {
    Navigator.of(context).pop(_nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    return widget.widgetFactory.editDialog(context, 'Edit Node',
        'Name',_nameController, _cancelEdit, _saveEdit);
  }

}