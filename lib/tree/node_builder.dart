import 'package:stager_platform/tree/leaf_node.dart';
import 'package:stager_platform/tree/composite_node.dart';
import 'package:uuid/uuid_value.dart';

/// This is a builder interface for creating nodes. See [BasicNodeBuilder] for
/// an example.
abstract class NodeBuilder {

  /// Const constructor for the NodeBuilder class.
  const NodeBuilder();

  /// Builds a new leaf node with the given ID and name.
  ///
  /// [id]: The ID of the new node.
  /// [name]: The name of the new node.
  /// [parent]: Optionally, the parent of the new node.
  LeafNode buildLeafNode(UuidValue id, String name, [CompositeNode? parent]);

  /// Builds a new composite node with the given ID and name.
  ///
  /// [id]: The ID of the new node.
  /// [name]: The name of the new node.
  /// [parent]: Optionally, the parent of the new node.
  CompositeNode buildCompositeNode(UuidValue id, String name, [CompositeNode? parent]);

}