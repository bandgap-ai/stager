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
  Widget infoLabel(BuildContext context);

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

}