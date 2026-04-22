/// Concrete implementation of [LeafNode].
///
/// This class represents a basic node in the tree that does not have children.
library;

import 'package:uuid/uuid.dart';

import '../builders/stager_context.dart';
import '../tree/node_visitor.dart';
import '../tree/tree.dart';
import '../tree/node_observer.dart';
import '../system/typed_value.dart';

/// A concrete implementation of a [LeafNode] that provides basic functionality.
///
/// With respect to loading properties from a map, this class will attempt to
/// load all properties it receives and preserve their type (i.e., it doesn't
/// cast the data). It notifies observers after it updates the properties.
/// Subclasses can override this behavior as needed, or allow ConcreteLeafNode
/// to load the properties and overwrite them after the initial values are
/// loaded.
class ConcreteLeafNode extends LeafNode {

  /// The [NodeProperties] associated with this leaf node.
  ///
  /// This getter provides access to the data payload of the node.
  final NodeProperties _properties;

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
    required super.name,
    Map<String, TypedValue<Object>> initialProperties = const {},
  }) : _properties = ConcreteNodeProperties(initialProperties);

  @override
  bool get isComposite => false;

  @override
  bool containsProperty(String key) {
    return _properties.contains(key);
  }

  @override
  String property(String key) {
    return _properties.get<Object>(key).toString();
  }

  @override
  void setProperty(String key, TypedValue<Object> value) {
    _properties.set<Object>(key, value);
    // Notify observers about the change in properties
    notify();
  }

  @override
  TypedValue<Object> typedProperty(String key) {
    return _properties.map[key]!;
  }

  @override
  Map<String, TypedValue<Object>> toMap() {

    // Add the name and id to the map as well as the node properties
    return <String,TypedValue<Object>>{
      'name' : TypedValue<String>(name),
      'id' : TypedValue<UuidValue>(id),
      ..._properties.map
    };

  }

  @override
  void fromMap(Map<String, TypedValue<Object>> inputMap) {

    // Make a copy so we can do what we want
    var map = Map.of(inputMap);

    // Pull the name and id from the map, if it has it.
    if (map.containsKey('name')) {
      name = map['name']!.value.toString();
      map.remove('name');
    }
    if (map.containsKey('id')) {
      id = map['id']!.value as UuidValue;
      map.remove('id');
    }

    // Load all the properties
    final tempProps = ConcreteNodeProperties(map);
    // Merge everything
    _properties.merge(tempProps);

    // Notify observers about the change in properties
    notify();

    return;
  }
  
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