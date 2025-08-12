import 'package:stager_platform/editors/dialog_control_button.dart';

/// This is a test implementation of the DialogControlButton class.
class TestDialogControlButton extends DialogControlButton {

  bool _built = false;

  bool get built => _built;

  TestDialogControlButton({super.key, required super.controller});

  @override
  void processResults(dynamic results) {
    super.processResults(results);
    _built = true;
  }

  void reset() {
    _built = false;
  }
}