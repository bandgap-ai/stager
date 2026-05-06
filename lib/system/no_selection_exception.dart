/// Exception thrown when a selection is requested from [SelectionService]
/// but is not currently set for the specified view.
class NoSelectionException implements Exception {
  /// The ID of the view for which the selection was requested.
  final String viewId;

  /// Creates a [NoSelectionException] for the given [viewId].
  const NoSelectionException(this.viewId);

  @override
  String toString() => 'NoSelectionException: No selection found for view "$viewId"';
}