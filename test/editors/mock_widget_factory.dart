import 'package:flutter/src/widgets/editable_text.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:stager_platform/editors/widget_factory.dart';

class MockWidgetFactory extends WidgetFactory {
  @override
  Widget editDialog(BuildContext context, String title, String inputLabel, TextEditingController inputController, void Function() save, void Function() cancel) {
    // TODO: implement editDialog
    throw UnimplementedError();
  }

  @override
  Widget infoLabel(BuildContext context, String info) {
    // TODO: implement infoLabel
    throw UnimplementedError();
  }

  @override
  Widget positionMethodWidget(BuildContext context, bool initialSelection, void Function(bool p1) onChanged) {
    // TODO: implement positionMethodWidget
    throw UnimplementedError();
  }

  @override
  Widget textFieldEditor(BuildContext context, TextEditingController controller, labelText, hintText) {
    // TODO: implement textFieldEditor
    throw UnimplementedError();
  }
  
}