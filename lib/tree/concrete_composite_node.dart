/// Concrete implementation of [CompositeNode].
///
/// This class represents a node that can contain other [LeafNode]s (including
/// other [CompositeNode]s) as children. It extends [ConcreteLeafNode] and
/// manages a list of children.
library;
import 'package:stager/tree/tree.dart';
import 'package:stager/tree/concrete_leaf_node.dart';

class ConcreteCompositeNode extends ConcreteLeafNode implements CompositeNode {
  /// The list of child nodes.
  @override
  final List<LeafNode> children = [];

  /// Creates a [ConcreteCompositeNode] instance.
  ///
  /// [id]: The unique identifier for the composite node.
  /// [name]: The display name of the composite node.
  /// [initialProperties]: Optional initial properties for the node.
  ConcreteCompositeNode({
    required super.id,
    required super.name,
    super.initialProperties,
  });

  @override
  bool get isComposite => true;

  @override
  void addChild(LeafNode child) {
    children.add(child);
    child.setParent(this); // Set parent reference for the child
    notify(); // Notify composite observers of change in children
  }

  @override
  void removeChild(LeafNode child) {
    if (children.remove(child)) {
      child.setParent(null); // Clear parent reference for the removed child
      notify(); // Notify composite observers of change in children
    }
  }

  @override
  void attach(LeafNodeObserver observer) {
    super.attach(observer);
    for (final child in children) {
      child.attach(observer);
    }
  }

  @override
  void detach(LeafNodeObserver observer) {
    super.detach(observer);
    for (final child in children) {
      child.detach(observer);
    }
  }
}
