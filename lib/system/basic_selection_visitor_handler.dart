import 'package:logger/logger.dart';

import 'selection.dart';
import 'selection_visitor.dart';
import 'selection_visitor_handler.dart';

/// This is a basic implementation of [SelectionVisitorHandler] that is used by
/// default in Stager. It uses a simple map for type mapping and visitor
/// selection.
///
/// This handler splits off the default case into a separate function so
/// subclasses can override the default behavior for unregistered types. This may
/// be useful in scenarios where throwing exceptions is not appropriate, such as
/// when rendering a message or on alternative makes more sense.
class BasicSelectionVisitorHandler extends SelectionVisitorHandler {

  // Logger for capturing visitation failures.
  final Logger _logger = Logger();

  // Map for type registration
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
      visitUnregisteredType(selection);
    }
  }

  /// This function handles unregistered types and allows the default visitation
  /// behavior to be overridden by subclasses. It logs an error and throws an
  /// exception.
  ///
  /// [selection]: The selection with the unhandled type.
  void visitUnregisteredType(Selection<dynamic> selection) {
    final message = 'No SelectionVisitor registered for type: ${selection.value.runtimeType}';
    _logger.e(message);
    throw Exception(message);
  }
}