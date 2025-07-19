import 'package:flutter/material.dart';

abstract class WidgetFactory {

  /// Builds a Stager-standard text field editor with all the bells and whistles.
  ///
  /// Toot toot!
  ///
  /// See [standard_widgets.dart] for reference.
  ///
  /// [context] is the context for the dialog.
  /// [labelText] is the label for the text field.
  /// [hintText] is the hint text for the text field.
  Widget textFieldEditor(BuildContext context, TextEditingController controller,
      final labelText, final hintText);

  /// Builds the info label for the dialog.
  ///
  /// See [standard_widgets.dart] for reference.
  ///
  /// [context] is the context for the dialog.
  /// [info] is the information to be displayed.
  Widget infoLabel(BuildContext context, String info);

  /// Builds the position method widget for the dialog. The selectedOption
  /// parameter is updated in place.
  ///
  /// See [standard_widgets.dart] for reference.
  ///
  /// [context] is the context for the dialog.
  /// [initialSelection] is the initial selection.context
  /// [onChanged] is the callback for when the selection changes.
  /// FIXME - Change name to "dualSelector"
  Widget positionMethodWidget(BuildContext context,
      bool initialSelection,
      void Function(bool) onChanged);

  /// Builds a modal dialog that can be used to edit a single text field.
  ///
  /// See [standard_widgets.dart] for reference.
  ///
  /// [context] is the context for the dialog.
  /// [title] is the title of the dialog.
  /// [inputLabel] is the label for the text field.
  /// [inputController] is the controller for the text field.
  /// [save] is the callback for when the user clicks the save button.
  /// [cancel] is the callback for when the user clicks the cancel button.
  Widget editDialog(BuildContext context,
      String title,
      String inputLabel,
      TextEditingController inputController,
      void Function() save,
      void Function() cancel);

}