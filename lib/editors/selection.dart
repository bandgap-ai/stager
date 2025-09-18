/// This file contains the implementation of the [Selection] class, a generic
/// state holder that uses the observer pattern to notify listeners of changes.
library;

import 'package:stager_platform/editors/selection_observer.dart';

/// A generic class that wraps a selection and notifies observers when it changes.
///
/// This class implements the **Subject** part of the **Observer design pattern**.
/// It holds a value of type [T] and maintains a list of [SelectionObserver]s.
/// When the [value] is changed, it notifies all registered observers.
///
/// This is useful for managing UI state, such as the currently selected item in a
/// list, where multiple parts of the UI need to react to a change in selection.
///
/// Example:
/// ```dart
/// // Create a selection object for a string.
/// final selection = Selection<String>();
///
/// // Create an observer.
/// class MyObserver implements SelectionObserver<String> {
///   @override
///   void update(String? newSelection) {
///     print('Selection changed to: $newSelection');
///   }
/// }
///
/// final observer = MyObserver();
///
/// // Attach the observer.
/// selection.attach(observer);
///
/// // Change the value, which will trigger the observer's update method.
/// selection.value = 'Hello, World!'; // Prints: Selection changed to: Hello, World!
/// ```
class Selection<T> {
  T? _value;
  final List<SelectionObserver<T>> _observers = [];

  /// The currently selected value. Can be `null`.
  T? get value => _value;

  /// Sets the selected value and notifies observers if the new value is
  /// different from the current one.
  ///
  /// If [newValue] is the same as the current [value], no notification is sent.
  set value(T? newValue) {
    if (_value != newValue) {
      _value = newValue;
      notify();
    }
  }

  /// Attaches an [observer] to listen for selection changes.
  ///
  /// The observer will be notified immediately of the current selection value
  /// upon attachment, and subsequently whenever the selection changes.
  void attach(SelectionObserver<T> observer) {
    _observers.add(observer);
  }

  /// Detaches an [observer] to stop it from receiving updates.
  ///
  /// If the observer is not in the list, this method has no effect.
  void detach(SelectionObserver<T> observer) {
    _observers.remove(observer);
  }

  /// Notifies all attached observers of the current selection value.
  ///
  /// This method is called automatically when the [value] is set to a new
  /// value, but can also be called manually to force a notification.
  void notify() {
    for (final observer in _observers) {
      observer.update(_value);
    }
  }
}
