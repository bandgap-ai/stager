/// This file defines the observer interface for the [Selection] class.
library;

import 'package:stager_platform/system/selection.dart';

/// An interface for observers that are interested in changes to a [Selection].
///
/// This is part of the **Observer design pattern**, where this interface acts
/// as the `Observer`. Classes that implement [SelectionObserver] can register
/// themselves with a [Selection] instance (the `Subject`) to be notified
/// whenever the selection changes.
abstract class SelectionObserver<T> {
  /// Called by the [Selection] subject when its value has been updated.
  ///
  /// Implementations of this method should define how the observer reacts to
  /// a change in the selection.
  ///
  /// [selection]: The new value of the selection. This can be `null` if the
  ///            selection is cleared.
  void update(T? selection);
}
