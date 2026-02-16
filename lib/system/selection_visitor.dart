
import 'package:stager_platform/system/selection.dart';

/// This is a simple generic visitor interface for visiting clients of type T.
///
/// While this is meant for working with [Selection]s, it could technically be
/// used with anything.
abstract class SelectionVisitor<T> {
     void visit(T element);
}