import 'selection_visitor.dart';
import 'selection.dart';

/// This is a dynamic visitor interface for registering types and visitors
/// without explicitly extending the interface. Types are registered against
/// visitors and implementations use the registered types to correctly dispatch
/// to the correct visitor when visit() is called.
///
/// See [BasicSelectionVisitorHandler] for an example implementation and
/// and consider it a starting point for customization since its default
/// behavior can be overridden.
abstract class SelectionVisitorHandler {

  /// Registers a type and its corresponding visitor.
  ///
  /// [type]: The type to be registered.
  /// [visitor]: The visitor to be associated with the type.
  void register(Type type, SelectionVisitor visitor);

  /// Visits a selection and dispatches to the appropriate visitor.
  ///
  /// [selection]: The selection to be visited.
  void visit(Selection selection);
}
