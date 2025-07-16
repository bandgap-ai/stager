/// This is a visitor interface for visiting nodes in a Stager tree following
/// the visitor pattern.
///
/// Dart does not allow for methods to be overridden, which is the traditional
/// way of defining and managing a visitor interface in other Object-Oriented
/// languages. Instead of adding methods like "visitLeafNode",
/// "visitCompositeNode", etc., we find it more desirable to have a simple
/// abstract interface and allow concrete implementations to use a mechanism of
/// their choosing. This avoids the need to update this interface whenever a new
/// node type is added (either in Stager or by a client library).
abstract class NodeVisitor {

  /// Visits a node and performs some operation on it.
  ///
  /// [client]: The client object to visit.
  void visit(Object node);

}