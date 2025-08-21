import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/leaf_node.dart';
import 'package:stager_platform/tree/node_builder.dart';
import 'package:stager_platform/tree/concrete_composite_node.dart';
import 'package:stager_platform/tree/concrete_leaf_node.dart';

/// This is an implementation of [NodeBuilder] that provides a default
/// implementation using [ConcreteLeafNode] and [ConcreteCompositeNode].
///
/// Subclasses and alternatives should be especially mindful of the linkage
/// logic for parents and children.
class BasicNodeBuilder extends NodeBuilder {

  /// Const constructor for the BasicNodeBuilder class.
  const BasicNodeBuilder();

  /// This is a utility method to link child and parent nodes so long as the
  /// parent is not null.
  ///
  /// [node]: The node to be linked.
  /// [parent]: The parent of the node.
  void linkParent(LeafNode node, CompositeNode? parent) {
    if (parent != null) {
      // Link the new node to the parent as a child
      parent.addChild(node);
      // Let the watchers know
      parent.notify();
    }
  }

  @override
  CompositeNode buildCompositeNode(String id, String name, [CompositeNode? parent]) {
    ConcreteCompositeNode node = ConcreteCompositeNode(id: id, name: name);
    linkParent(node, parent);
    return node;
  }

  @override
  LeafNode buildLeafNode(String id, String name, [CompositeNode? parent]) {
    ConcreteLeafNode node = ConcreteLeafNode(id: id, name: name);
    linkParent(node, parent);
    return node;
  }

}