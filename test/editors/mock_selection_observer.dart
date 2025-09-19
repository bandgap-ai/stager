import 'package:stager_platform/editors/selection_observer.dart';

class MockSelectionObserver<T> implements SelectionObserver<T> {
  bool _updated = false;
  T? lastSelection;

  bool get updated => _updated;

  void reset() {
    _updated = false;
    lastSelection = null;
  }

  @override
  void update(T? selection) {
    _updated = true;
    lastSelection = selection;
  }
}