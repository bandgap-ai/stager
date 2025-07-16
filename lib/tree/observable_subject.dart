/// An abstract class representing a subject in the Observer pattern.
///
/// Classes that extend this will allow observers of type [T] to attach,
/// detach, and be notified of changes.
abstract interface class ObservableSubject<T> {
  /// Attaches an [observer] to the subject.
  ///
  /// [observer]: The observer to attach. Must be of type [T].
  /// Type safety: Ensure that the attached observer correctly implements the expected observer interface.
  void attach(T observer);

  /// Detaches an [observer] from the subject.
  ///
  /// [observer]: The observer to detach. Must be of type [T].
  /// Type safety: Ensure that the detached observer correctly implements the expected observer interface.
  void detach(T observer);

  /// Notifies all attached observers of a change.
  ///
  /// Implementations should iterate through attached observers and call their update methods.
  void notify();
}
