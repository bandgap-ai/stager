import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/leaf_node.dart';
import 'package:stager_platform/tree/node_builder.dart';
import 'package:stager_platform/tree/concrete_composite_node.dart';
import 'package:stager_platform/tree/concrete_leaf_node.dart';

/// This is an implementation of [NodeBuilder] that provides a default
/// implementation using [ConcreteLeafNode] and [ConcreteCompositeNode].
class BasicNodeBuilder extends NodeBuilder {

  /// Const constructor for the BasicNodeBuilder class.
  const BasicNodeBuilder();

  @override
  CompositeNode buildCompositeNode(String id, String name) {
    return ConcreteCompositeNode(id: id, name: name);
  }

  @override
  LeafNode buildLeafNode(String id, String name) {
    return ConcreteLeafNode(id: id, name: name);
  }

}