import 'package:stager/editors/dialog_control_button.dart';

class MockDialogControlButton extends DialogControlButton {

  bool _built = false;

  bool get built => _built;

  MockDialogControlButton({super.key, required super.state, required super.controller});

  @override
  void processResults(dynamic results) {
    super.processResults(results);
    _built = true;
  }

  void reset() {
    _built = false;
  }
}