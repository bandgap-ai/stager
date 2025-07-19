import 'package:flutter/material.dart';
import 'package:stager/editors/widget_factory.dart';
import 'package:stager/editors/standard_widgets.dart';

/// A simple implementation of [WidgetFactory] that uses the
/// [standard_widgets.dart] utility functions to create basic widgets, mostly,
/// for use by editors.
///
/// Clients are recommended to create subclass of this class and override
/// methods as needed instead of creating a completely separate implementation.
/// This is the easiest way to ensure compatibility with other parts of
/// Stager and reduce the amount of unintended consequences.
class BasicWidgetFactory implements WidgetFactory {
  const BasicWidgetFactory();

  @override
  Widget infoLabel(BuildContext context, String info) {
    return buildInfoLabel(context,info);
  }

  @override
  Widget positionMethodWidget(BuildContext context, bool initialSelection, void Function(bool p1) onChanged) {
      return buildPositionMethodWidget(context, initialSelection, onChanged);
  }

  @override
  Widget textFieldEditor(BuildContext context, TextEditingController controller, labelText, hintText) {
      return buildTextFieldEditor(context, controller, labelText, hintText);
  }

  @override
  Widget editDialog(BuildContext context, String title, String inputLabel, TextEditingController inputController, void Function() save, void Function() cancel) {
    return buildEditAndSubmitDialog(context, title, inputLabel, inputController, save, cancel);
  }
}