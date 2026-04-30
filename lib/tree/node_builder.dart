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
  /// [name]: The name of the new node.
  /// [parent]: Optionally, the parent of the new node.
  LeafNode buildLeafNode(String name, [CompositeNode parent]);

  /// Builds a new composite node with the given ID and name.
  ///
  /// [name]: The name of the new node.
  /// [parent]: Optionally, the parent of the new node.
  CompositeNode buildCompositeNode(String name, [CompositeNode parent]);

}