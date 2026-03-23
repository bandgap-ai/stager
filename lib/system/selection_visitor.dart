import 'package:logger/logger.dart';

/// This is a simple generic visitor interface for visiting clients of type T.
///
/// While this is meant for working with [Selection]s, it could technically be
/// used with anything.
abstract class SelectionVisitor<T> {
  void visit(T element);
}

/// This is a generic implementation of [SelectionVisitor] for those instances
/// where a simple value assignment from a visited element is needed.
///
/// The type safety of the assignment is guaranteed by Dart's reified generics,
/// ensuring that `visit` can only be called with an element of type `T`.
class GenericSelectionVisitor<T> implements SelectionVisitor<T> {
  /// The value of the visited selection.
  T value;

  /// You know this is going to be needed...
  final Logger logger = Logger();

  /// Creates a [GenericSelectionVisitor] instance.
  ///
  /// [value]: A sensible default value for the visitor.
  GenericSelectionVisitor(this.value);

  @override
  void visit(T element) {
    value = element;
  }
}
