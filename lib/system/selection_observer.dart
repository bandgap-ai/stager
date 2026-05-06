/// This file defines the observer interface for the [Selection] class.
library;

import 'package:stager_platform/system/selection.dart';

/// An interface for observers that are interested in changes to a [Selection].
///
/// This is part of the observer design pattern. Classes that implement
/// [SelectionObserver] can register themselves with a [Selection] instance
/// or the [SelectionService] to be notified whenever the selection changes.
abstract class SelectionObserver<T extends Object> {
  /// Called by the [Selection] subject when its value has been updated.
  ///
  /// Implementations of this method should define how the observer reacts to
  /// a change in the selection.
  ///
  /// The new value of the selection is not passed to the implementer to
  /// enforce proper null safety. Implementers should perform the appropriate
  /// checks when an update is received, then retrieve the value from the
  /// selection (or through the selection service) directly.
  void update();
}
