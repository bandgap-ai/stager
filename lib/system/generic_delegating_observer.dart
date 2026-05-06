import 'selection_observer.dart';

/// A [SelectionObserver] implementation that delegates its [update] call 
/// to a provided callback function.
///
/// This class is useful for creating ad-hoc observers without needing to 
/// implement the [SelectionObserver] interface in a separate class or 
/// mixin.
///
/// [T]: The type of the object being observed.
class GenericDelegatingObserver<T extends Object> implements SelectionObserver<T> {
  /// The callback function to execute when the selection is updated.
  final void Function() onUpdate;

  /// Creates a [GenericDelegatingObserver] that calls [onUpdate] 
  /// when notified.
  GenericDelegatingObserver(this.onUpdate);

  @override
  void update() {
    onUpdate();
  }
}
