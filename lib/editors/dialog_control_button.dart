import 'package:flutter/material.dart';
import 'package:stager/editors/stager_editor.dart';

/// The StagerControlWidget is a simple button to control when to open an
/// editor or launch an independent function on behalf of a user.
///
/// Subclasses must override _processResults to handle the results from the
/// editor.
abstract class DialogControlButton extends StatelessWidget {

  /// The icon to display for this control.
  final IconData icon;

  /// The editor launched by this control to edit the data.
  final StagerEditor editor;

  const DialogControlButton({super.key, required this.icon, required this.editor});

  /// Handles the results from the editor and must be implemented by subclasses.
  ///
  /// [results] is the results from the editor.
  void _processResults(dynamic results);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
      onPressed: () async {
        final results = await showDialog(
          context: context,
          builder: (context) {
            return editor;
          }
        );
        _processResults(results);
      },
    );
  }

}