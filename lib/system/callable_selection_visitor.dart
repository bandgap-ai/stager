
import 'selection_visitor.dart';

/// This is a specialization of the Generic Selection Visitor that can call a
/// callback function to further process an element during visitation.
class CallableSelectionVisitor<T> extends GenericSelectionVisitor<T> {

  /// Callback function to map the value to a LatLng location.
  final void Function(T) mapper;

  CallableSelectionVisitor(super.value, this.mapper);

  @override
  void visit(T element) {
    // Do the normal visitation first
    super.visit(element);
    // Now map the value
    mapper(element);
  }
}