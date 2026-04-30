/// Concrete implementation of [CompositeNode].
///
/// This class represents a node that can contain other [LeafNode]s (including
/// other [CompositeNode]s) as children. It extends [ConcreteLeafNode] and
/// manages a list of children.
library;

import '../system/registry.dart';
import '../system/stager_context.dart';
import 'tree.dart';
import 'node_observer.dart';
import '../builders/basic_builder.dart';

/// This is a builder for concrete composite nodes.
///
/// [context]: The context for building the composite node.
/// Returns a [ConcreteCompositeNode] instance.
@BasicBuilder(name: 'ConcreteCompositeNode')
ConcreteCompositeNode buildConcreteCompositeNode(StagerContext context) {
  ConcreteCompositeNode node = ConcreteCompositeNode(name: 'Leaf');
  node.fromMap(context.toMap());
  return node;
}

/// This class is concrete implementation of a [CompositeNode] that provides all
/// the required capabilities to manage a set of child [LeafNode]s.
///
/// Note that most of the methods on this class propagate to its children, such
/// as toMap() and fromMap().
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
      // Clear the relatives since there is no longer a valid relationship.
      child.resetRelatives();
      notify(); // Notify composite observers of change in children
    }
  }

  @override
  void attach(NodeObserver observer) {
    super.attach(observer);
    for (final child in children) {
      child.attach(observer);
    }
  }

  @override
  void detach(NodeObserver observer) {
    super.detach(observer);
    for (final child in children) {
      child.detach(observer);
    }
  }

  @override
  void fromMap(Map<String, Object> inputMap) {

    final map = Map<String, Object>.from(inputMap);

    // Pull the children from the input map
    if (map.containsKey('children')) {
      final children = List<Map<String,Object>>.from(map['children']! as List);
      for (final child in children) {
        final childMap = child;
        final childType = childMap['type'] as String;
        //childMap.remove('type');
        final node = buildObject(childType,childMap) as LeafNode;
        addChild(node);
      }
      // Remove the children before passing the map up
      map.remove('children');
    }

    // Delegate the remaining data to the base class.
    super.fromMap(map);
  }

  @override
  Map<String, Object> toMap() {

    final map = super.toMap();

    // The list of children needs to be converted to a list of maps of the
    // children and each map in the list needs a new entry with its type added.
    final List<Map<String,Object>> childrenMapList = [];
    for (final child in children) {
      final childAsMap = child.toMap();
      childAsMap['type'] = child.runtimeType.toString();
      childrenMapList.add(childAsMap);
    }

    // Add the list and return the map
    map['children'] = childrenMapList;

    return map;
  }
}
