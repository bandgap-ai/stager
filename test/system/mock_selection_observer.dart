import 'package:stager_platform/system/selection_observer.dart';

class MockSelectionObserver<T extends Object> implements SelectionObserver<T> {

  bool _updated = false;

  bool get updated => _updated;

  void reset() {
    _updated = false;
  }

  @override
  void update() {
    _updated = true;
  }
}