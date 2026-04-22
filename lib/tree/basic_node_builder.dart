import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/leaf_node.dart';
import 'package:stager_platform/tree/node_builder.dart';
import 'package:stager_platform/tree/concrete_composite_node.dart';
import 'package:stager_platform/tree/concrete_leaf_node.dart';
import 'package:uuid/uuid_value.dart';

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
  CompositeNode buildCompositeNode(UuidValue id, String name, [CompositeNode? parent]) {
    ConcreteCompositeNode node = ConcreteCompositeNode(name: name);
    node.id = id;
    linkParent(node, parent);
    return node;
  }

  @override
  LeafNode buildLeafNode(UuidValue id, String name, [CompositeNode? parent]) {
    ConcreteLeafNode node = ConcreteLeafNode(name: name);
    node.id = id;
    linkParent(node, parent);
    return node;
  }

}