import 'package:flutter/material.dart';
import 'package:stager/site_state.dart';
import 'package:stager/editors/controller.dart';

/// The StagerControlWidget is a simple button to control when to open an
/// editor or launch an independent function on behalf of a user.
///
/// It delegates work to subclasses of Controller.
class DialogControlButton extends StatelessWidget {

  /// The controller for this control button.
  final Controller controller;

  const DialogControlButton({super.key,
    required this.controller});

  /// Handles the results from the editor and must be implemented by subclasses.
  ///
  /// [results] is the results from the editor.
  void processResults(dynamic results) {
    controller.process(results);
  }

  /// Utility function to keep build() clean.
  ///
  /// [context] is the build context.
  void _handleButtonPressed(BuildContext context) async {

    final results = await showDialog(
      context: context,
      builder: (context) => controller.editor(context),
    );
    processResults(results);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(controller.iconData(), color: Theme.of(context).colorScheme.onPrimary),
      onPressed: () => _handleButtonPressed(context),
    );
  }

}