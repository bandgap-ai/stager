/// Concrete implementation of [LeafNode].
///
/// This class represents a basic node in the tree that does not have children.
library;
import 'package:stager/tree/node_visitor.dart';
import 'package:stager/tree/tree.dart';
import 'package:stager/tree/concrete_node_properties.dart';
import 'package:stager/tree/node_observer.dart';

class ConcreteLeafNode implements LeafNode {
  /// The properties of this node.
  @override
  final ConcreteNodeProperties properties;

  /// The parent of this node, or `null` if it is a root.
  @override
  LeafNode? parent;
  /// The next sibling of this node, or `null` if it is the last child.
  @override
  LeafNode? next;
  /// The previous sibling of this node, or `null` if it is the first child.
  @override
  LeafNode? previous;

  /// Internal list of observers attached to this leaf node.
  final List<NodeObserver> _leafNodeObservers = [];

  /// Creates a [ConcreteLeafNode] instance.
  ///
  /// [id]: The unique identifier for the node. Stored in properties.
  /// [name]: The display name of the node. Stored in properties.
  /// [initialProperties]: Optional initial properties for the node.
  ConcreteLeafNode({
    required String id,
    required String name,
    Map<String, Object?>? initialProperties,
  }) : properties = ConcreteNodeProperties(initialProperties) {
    properties.setProperty('id', id);
    properties.setProperty('name', name);
  }

  @override
  bool get isComposite => false;

  @override
  void setParent(LeafNode? parent) {
    this.parent = parent;
    notify(); // Notify observers about the change in parent
  }

  @override
  void setNext(LeafNode? next) {
    this.next = next;
    notify(); // Notify observers about the change in next sibling
  }

  @override
  void setPrevious(LeafNode? previous) {
    this.previous = previous;
    notify(); // Notify observers about the change in previous sibling
  }

  /// Attaches a [NodeObserver] to this leaf node.
  @override
  void attach(NodeObserver observer) {
    _leafNodeObservers.add(observer);
  }

  /// Detaches a [LeafNodeObserver] from this leaf node.
  @override
  void detach(NodeObserver observer) {
    _leafNodeObservers.remove(observer);
  }

  /// Notifies all attached [LeafNodeObserver]s of a change.
  @override
  void notify() {
    for (final observer in _leafNodeObservers) {
      observer.update(this);
    }
  }

  @override
  void accept(NodeVisitor visitor) {
    visitor.visit(this);
  }
}