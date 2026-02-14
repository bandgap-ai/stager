import 'selection.dart';
import 'selection_visitor.dart';
import 'selection_visitor_handler.dart';

// This is a basic implementation of [SelectionVisitorHandler] that is used by
// default in Stager. It uses a simple map for type mapping and visitor
// selection.
class BasicSelectionVisitorHandler extends SelectionVisitorHandler {

  final Map<Type, SelectionVisitor<dynamic>> _visitors = {};

  @override
  void register(Type type, SelectionVisitor<dynamic> visitor) {
    _visitors[type] = visitor;
  }

  @override
  void visit(Selection<dynamic> selection) {
    if (_visitors.containsKey(selection.value.runtimeType)) {
      // Add the ! to prevent a null check error even though the visitor is
      // guaranteed to be non-null by the register method and the surrounding
      // logic.
      SelectionVisitor visitor = _visitors[selection.value.runtimeType]!;
      // Pop in to say 'Hey!'
      visitor.visit(selection.value);
    } else {
      throw Exception('No visitor registered for type ${selection.value.runtimeType}');
    }
  }

}