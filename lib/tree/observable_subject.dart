import "package:stager_platform/tree/node_observer.dart";

/// An abstract class representing a subject in the Observer pattern.
///
/// Classes that extend this will allow node observers to attach,
/// detach, and be notified of changes.
abstract interface class ObservableSubject {
  /// Attaches an [observer] to the subject.
  ///
  /// [observer]: The observer to attach.
  /// Type safety: Ensure that the attached observer correctly implements the expected observer interface.
  void attach(NodeObserver observer);

  /// Detaches an [observer] from the subject.
  ///
  /// [observer]: The observer to detach.
  /// Type safety: Ensure that the detached observer correctly implements the expected observer interface.
  void detach(NodeObserver observer);

  /// Notifies all attached observers of a change.
  ///
  /// Implementations should iterate through attached observers and call their update methods.
  void notify();
}
