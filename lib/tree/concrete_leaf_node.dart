/// Concrete implementation of [LeafNode].
///
/// This class represents a basic node in the tree that does not have children.
library;

import 'package:stager_platform/tree/data_properties.dart';
import 'package:stager_platform/tree/data_node.dart';
import 'package:uuid/uuid.dart';

import '../system/stager_context.dart';
import 'node_visitor.dart';
import 'tree.dart';
import 'node_observer.dart';
import '../system/point.dart';
import '../system/typed_value.dart';
import '../builders/basic_builder.dart';

/// This is a builder for concrete leaf nodes.
///
/// [context]: The context for building the leaf node.
/// Returns a [ConcreteLeafNode] instance.
@BasicBuilder(name: 'ConcreteLeafNode')
ConcreteLeafNode buildConcreteLeafNode(StagerContext context) {
  ConcreteLeafNode node = ConcreteLeafNode(name: 'Leaf');
  node.fromMap(context.toMap());
  return node;
}

/// A concrete implementation of a [LeafNode] that provides basic functionality.
///
/// With respect to loading properties from a map, this class will attempt to
/// load all properties it receives and preserve their type (i.e., it doesn't
/// cast the data). It notifies observers after it updates the properties.
/// Subclasses can override this behavior as needed, or allow ConcreteLeafNode
/// to load the properties and overwrite them after the initial values are
/// loaded.
class ConcreteLeafNode implements LeafNode {
  /// The common name of the node
  String _name;

  /// The unique identifier for the node.
  UuidValue _id;

  /// The position of the node
  Point _point;

  /// The [NodeProperties] associated with this leaf node.
  ///
  /// This getter provides access to the data payload of the node.
  final NodeProperties _properties;

  /// The [DataProperties] associated with this leaf node.
  ///
  /// This getter provides access to the data nodes of the node.
  final DataProperties _dataNodes;

  /// The parent of this node, or 'this' if no parent has been set.
  late LeafNode _parent = this;
  /// The next sibling of this node, or 'this' if it has no next sibling.
  late LeafNode _next = this;
  /// The previous sibling of this node, or 'this' if it has no previous sibling.
  late LeafNode _previous = this;

  /// Internal list of observers attached to this leaf node.
  final List<NodeObserver> _leafNodeObservers = [];

  /// Creates a [ConcreteLeafNode] instance.
  ///
  /// [id]: The unique identifier for the node. Stored in properties.
  /// [name]: The display name of the node. Stored in properties.
  /// [initialProperties]: Optional initial properties for the node.
  ConcreteLeafNode({
    required name,
    Map<String, TypedValue<Object>> initialProperties = const {},
  }) : _name = name,
        _id = Uuid().v7obj(),
        _point = LeafNode.defaultPosition,
        _properties = ConcreteNodeProperties(initialProperties),
        _dataNodes = DataProperties();

  @override
  String get name => _name;

  @override
  set name(String newName) {
    if (newName.isNotEmpty) {
      _name = newName;
      notify();
    }
  }

  /// Returns the unique identifier for the node.
  @override
  UuidValue get id => _id;

  /// Sets the unique identifier for the node. Visitors are notified when the
  /// name changes.
  @override
  set id(UuidValue newId) {
    _id = newId;
    notify();
  }

  /// Retrieves the position of the node.
  @override
  Point get position => _point;

  /// Sets the position of the node. Setting the position notifies listeners.
  ///
  /// [newPoint]: The new position for the node.
  @override
  set position(Point newPoint) {
    _point = newPoint;
    notify();
  }

  @override
  bool get isComposite => false;

  @override
  bool get hasProperties => !_properties.isEmpty();

  @override
  bool hasProperty(String name) => _properties.contains(name);

  @override
  NodeProperties get properties => _properties;

  @override
  DataProperties get dataNodes => _dataNodes;

  @override
  bool get hasData => _dataNodes.isNotEmpty;

  @override
  Map<String, Object> toMap() {

    // Add the name and id to the map as well as the node properties
    return <String,Object>{
      'name' : name,
      'id' : id.toString(),
      'position' : position.toMap(),
      // Add a type marker so clients know the type of the node
      'type' : runtimeType.toString(),
      'dataNodes' : _dataNodes.toMap(),
      ..._properties.map
    };

  }

  @override
  Object toJson() => toMap();

  @override
  void fromMap(Map<String, Object> inputMap) {

    // Make a copy so we can do what we want
    var map = Map.of(inputMap);

    // Pull the name and id from the map, if it has it.
    if (map.containsKey('name')) {
      name = map['name'].toString();
      map.remove('name');
    }
    if (map.containsKey('id')) {
      id = UuidValue.fromString(map['id'].toString());
      map.remove('id');
    }
    // Grab the position
    if (map.containsKey('position')) {
      position = buildPoint(StagerContext(
          map['position']! as Map<String,Object>));
      map.remove('position');
    }

    // Remove the type marker
    if (map.containsKey('type')) {
      map.remove('type');
    }

    // Load the data nodes directly to avoid generic rehydration issues.
    if (map.containsKey('dataNodes')) {
      final dataMap = map['dataNodes'] as Map<String, Object>;
      for (final entry in dataMap.entries) {
        if (entry.value is Map<String, Object>) {
          _dataNodes.set(entry.key, DataNode.fromMap(entry.value as Map<String, Object>));
        }
      }
      map.remove('dataNodes');
    }

    // Load all the generic properties from what remains in the map.
    // We map every entry to a rehydrated TypedValue by passing the raw map 
    // data to the centralized buildTypedValue factory.
    final Map<String, TypedValue<Object>> rehydratedMap = map.map((key, value) {
      if (value is List<Object>) {
        return MapEntry(key, buildTypedValue(
            StagerContext({'value': value})));
      } else {
        throw NodePropertyException('Property "$key" with type '
            '${value.runtimeType} is not a TypedValue tuple (List<Object>) but '
            'must be since it is a generic node property. If this property was '
            'created programmatically, ensure that TypedValue.toTuple() was '
            'called.');
      }
    });

    final tempProps = ConcreteNodeProperties(rehydratedMap);
    
    // Merge the rehydrated properties into the node's bag.
    _properties.merge(tempProps);

    // Notify observers about the change in properties
    notify();

    return;
  }

  @override
  bool hasParent() => !identical(_parent, this);

  @override
  bool hasNext() => !identical(_next, this);

  @override
  bool hasPrevious() => !identical(_previous, this);

  @override
  LeafNode get next {
    if (hasNext()) {
      return _next;
    } else {
      throw NodeStructureException('next');
    }
  }

  @override
  LeafNode get parent {
    if (hasParent()) {
      return _parent;
    } else {
      throw NodeStructureException('parent');
    }
  }

  @override
  LeafNode get previous {
    if (hasPrevious()) {
      return _previous;
    } else {
      throw NodeStructureException('previous');
    }
  }

  @override
  void setParent(LeafNode parent) {
    _parent = parent;
    notify(); // Notify observers about the change in parent
  }

  @override
  void setNext(LeafNode next) {
    _next = next;
    notify(); // Notify observers about the change in next sibling
  }

  @override
  void setPrevious(LeafNode previous) {
    _previous = previous;
    notify(); // Notify observers about the change in previous sibling
  }

  @override
  void resetRelatives() {
    _parent = this;
    _next = this;
    _previous = this;
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
