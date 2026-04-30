import 'composite_node.dart';
import 'leaf_node.dart';
import 'node_builder.dart';
import 'concrete_composite_node.dart';
import 'concrete_leaf_node.dart';
import 'package:uuid/uuid_value.dart';
import 'null_nodes.dart';

/// This is an implementation of [NodeBuilder] that provides a default
/// implementation using [ConcreteLeafNode] and [ConcreteCompositeNode].
///
/// Subclasses and alternatives should be especially mindful of the linkage
/// logic for parents and children.
class BasicNodeBuilder extends NodeBuilder {

  static const NullComposite _nullParent = NullComposite();

  /// Const constructor for the BasicNodeBuilder class.
  const BasicNodeBuilder();

  /// This is a utility method to link child and parent nodes so long as the
  /// parent is not null.
  ///
  /// [node]: The node to be linked.
  /// [parent]: The parent of the node.
  void _linkParent(LeafNode node, CompositeNode parent) {
    if (parent != _nullParent) {
      // Link the new node to the parent as a child
      parent.addChild(node);
      // Let the watchers know
      parent.notify();
    }
  }

  @override
  CompositeNode buildCompositeNode(String name, [CompositeNode parent = _nullParent]) {
    ConcreteCompositeNode node = ConcreteCompositeNode(name: name);
    _linkParent(node, parent);
    return node;
  }

  @override
  LeafNode buildLeafNode(String name, [CompositeNode parent = _nullParent]) {
    ConcreteLeafNode node = ConcreteLeafNode(name: name);
    _linkParent(node, parent);
    return node;
  }

}