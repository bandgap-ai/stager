// External packages
import 'package:logger/logger.dart';

// Project files
import 'selection.dart';
import 'selection_visitor.dart';
import 'selection_visitor_handler.dart';

/// A robust implementation of [SelectionVisitorHandler] that provides 
/// detailed logging and hardened error handling.
///
/// This class manages a registry of [SelectionVisitor]s keyed by the [Type] 
/// they are designed to handle. It is used to process polymorphic selection 
/// objects without introducing tight coupling between the selection source 
/// and the visitor logic.
class OtherSelectionVisitorHandler extends SelectionVisitorHandler {
  /// Logger for capturing visitation failures.
  final Logger _logger = Logger();

  /// Internal registry mapping element types to their respective visitors.
  final Map<Type, SelectionVisitor<dynamic>> _visitors = {};

  /// Registers a [visitor] to handle elements of the specified [type].
  ///
  /// [type]: The [Type] of element the visitor processes.
  /// [visitor]: The [SelectionVisitor] implementation.
  @override
  void register(Type type, SelectionVisitor<dynamic> visitor) {
    _visitors[type] = visitor;
  }

  /// Dispatches the [selection] to the appropriate visitor based on the 
  /// runtime type of its value.
  ///
  /// [selection]: The generic selection container to process.
  ///
  /// Throws an [Exception] if no visitor is registered for the selection's 
  /// value type.
  @override
  void visit(Selection<dynamic> selection) {
    // Adhering to the Single Return Principle and optimized branch order.
    final valueType = selection.value.runtimeType;
    
    if (_visitors.containsKey(valueType)) {
      final SelectionVisitor<dynamic> visitor = _visitors[valueType]!;
      visitor.visit(selection.value);
    } else {
      // Hardened error reporting.
      final message = 'No SelectionVisitor registered for type: $valueType';
      _logger.e(message);
      throw Exception(message);
    }
  }
}
