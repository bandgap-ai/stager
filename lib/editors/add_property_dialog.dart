import 'package:flutter/material.dart';
import 'package:stager_platform/editors/standard_widgets.dart';

/// A dialog for adding a new property to a node.
///
/// This dialog allows the user to input a new property name and its corresponding
/// value. It returns a `Map<String, dynamic>` containing the new property
/// if the user taps 'Add', or `null` if the user taps 'Cancel'.
class AddPropertyDialog extends StatefulWidget {
  /// Creates an [AddPropertyDialog] widget.
  const AddPropertyDialog({super.key});

  @override
  State<AddPropertyDialog> createState() => _AddPropertyDialogState();
}

/// The state for the [AddPropertyDialog].
class _AddPropertyDialogState extends State<AddPropertyDialog> {
  /// Controller for the property name text field.
  final _propertyNameController = TextEditingController();

  /// Controller for the property value text field.
  final _propertyValueController = TextEditingController();

  @override
  void dispose() {
    _propertyNameController.dispose();
    _propertyValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Property'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildTextFieldEditor(
              context,
              _propertyNameController,
              'Property Name:',
              'e.g., color',
            ),
            buildTextFieldEditor(
              context,
              _propertyValueController,
              'Property Value:',
              'e.g., red',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null), // Return null on cancel
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final newProperty = {
              _propertyNameController.text: _propertyValueController.text,
            };
            Navigator.of(context).pop(newProperty);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
