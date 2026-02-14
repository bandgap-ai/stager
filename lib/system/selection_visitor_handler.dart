import 'selection_visitor.dart';
import 'selection.dart';

abstract class SelectionVisitorHandler {
  void register(Type type, SelectionVisitor visitor);

  void visit(Selection selection);
}
