import 'package:uuid/uuid.dart';

import '../tree/node_properties.dart';
import '../tree/observable_subject.dart';
import '../tree/node_visitor.dart';
import '../system/typed_value.dart';

/// An abstract class representing a leaf node in a tree structure.
///
/// This class defines the fundamental properties and relationships for a node
/// that can exist within a tree, including its associated data properties
/// and pointers to its parent, next sibling, and previous sibling. Stager's
/// nodes follow a convention for what node properties are class members and
/// what node properties are stored generically (i.e., with the property(key)
/// and setProperty(key, value) methods). By that convention, intrinsic
/// properties that hold for all nodes for all covered data types are members
/// and all properties that are specific to the modeled data are stored
/// generically. Intrinsic properties may vary by node type, and for LeafNode
/// they are name and id.
///
/// Generic properties can be any other values or quantities of interest. For
/// example, a collection of properties about a Tree's age, height, health, and
/// cull status would be generic properties. Generic properties can be retrieved
/// as strings, which is useful for labels or lists, or fully typed as a
/// [TypedValue]. A property can only be set as a full [TypedValue] to preserve
/// its type information for future use, particularly I/O. Generic properties
/// can only be managed in bulk with the toMap() and fromMap() methods, and
/// these methods only work for maps of `<String, TypedValue<Object>>`. The
/// toMap() and fromMap() write and read both the intrinsic and generic
/// properties.
///
/// The intrinsic properties of basic leaf nodes are:
/// - `name`: The common name of the node as a String.
/// - `id`: The unique identifier for the node, which is a UUID.
///
/// LeafNodes use UUIDs for uniquely identifying the node. A new leaf node is
/// created on construction and can be overwritten with fromMap() and id().
///
/// All nodes accept visitors (per the visitor pattern) with accept().
abstract class LeafNode implements ObservableSubject {

  /// The common name of the node
  late String _name;

  /// The unique identifier for the node.
  late UuidValue _id;

  LeafNode({required String name}) : _name = name, _id = Uuid().v7obj();

  /// Returns the name of the node
  String get name => _name;

  /// Sets the name of the node if the name is not empty and does nothing
  /// otherwise. Visitors are notified when the name changes.
  ///
  /// [newName]: The new name for the node.
  set name(String newName) {
    if (newName.isNotEmpty) {
      _name = newName;
      notify();
    }
  }

  /// Returns the unique identifier for the node.
  UuidValue get id => _id;

  /// Sets the unique identifier for the node. Visitors are notified when the
  /// name changes.
  set id(UuidValue newId) {
    _id = newId;
    notify();
  }

  /// Retrieves the parent [LeafNode] of this node.
  ///
  /// Returns `null` if this node is a root node (has no parent).
  LeafNode? get parent;

  /// Retrieves the next sibling [LeafNode] in the same level of the tree.
  ///
  /// Returns `null` if this node is the last sibling.
  LeafNode? get next;

  /// Retrieves the previous sibling [LeafNode] in the same level of the tree.
  ///
  /// Returns `null` if this node is the first sibling.
  LeafNode? get previous;

  /// Indicates whether this node is a composite node (i.e., can have children).
  ///
  /// Concrete [LeafNode] implementations should return `false`.
  /// Concrete [CompositeNode] implementations should return `true`.
  bool get isComposite;

  /// Sets the parent [LeafNode] for this node.
  ///
  /// [parent]: The [LeafNode] to set as the parent. Can be `null` to indicate
  /// that this node is a root.
  /// Type safety: Ensure that the provided [parent] is indeed a valid [LeafNode]
  /// instance or `null`.
  void setParent(LeafNode? parent);

  /// Sets the next sibling [LeafNode] for this node.
  ///
  /// [next]: The [LeafNode] to set as the next sibling. Can be `null` to indicate
  /// that this node is the last sibling.
  /// Type safety: Ensure that the provided [next] is indeed a valid [LeafNode]
  /// instance or `null`.
  void setNext(LeafNode? next);

  /// Sets the previous sibling [LeafNode] for this node.
  ///
  /// [previous]: The [LeafNode] to set as the previous sibling. Can be `null` to indicate
  /// that this node is the first sibling.
  /// Type safety: Ensure that the provided [previous] is indeed a valid [LeafNode]
  /// instance or `null`.
  void setPrevious(LeafNode? previous);

  /// Sets the property value associated with [key].
  ///
  /// [key]: The key of the property to set.
  /// [value]: The value to set for the property.
  /// Returns the key that was set.
  void setProperty(String key, TypedValue<Object> value);

  /// Returns the property value associated with [key] as a String.
  ///
  /// [key]: The key of the property to retrieve.
  /// Returns the property value as a String or throws an exception if the key
  /// is not found.
  String property(String key);

  /// Returns the property value associated with [key] as a [TypedValue].
  ///
  /// [key]: The key of the property to retrieve.
  /// Returns the property value as a [TypedValue] or throws an exception if the
  /// key is not found.
  TypedValue<Object> typedProperty(String key);

  /// True if the node has a property for [key].
  ///
  /// [key]: The key of the property to check.
  /// Returns `true` if the node has a property for [key], `false` otherwise.
  bool containsProperty(String key);

  /// Returns the full set of intrinsic and generic properties as a map.
  Map<String, TypedValue<Object>> toMap();

  /// Loads the full set of intrinsic and generic properties from a map. The map
  /// should contain key-value pairs representing the properties already set by
  /// the node.
  ///
  /// The implementation attempts to merge any new properties with the existing
  /// properties. In the event of a duplicate entry, it will accept the value of
  /// from [inputMap]. The implementation may also be expensive based based on
  /// the requirement use TypedValues internally ensure type safety. If you
  /// know the type of a value, it is better to call setProperty() directly.
  /// 
  /// Implementations create shallow copies of the inputMap to avoid side
  /// effects on the original map due to sorting and filtering for intrinsic vs
  /// generic properties.
  ///
  /// [inputMap]: The map containing the properties to be loaded.
  void fromMap(Map<String, TypedValue<Object>> inputMap);

  /// Accepts a visitor to perform some operation on the node.
  ///
  /// [visitor]: The [NodeVisitor] to accept.
  void accept(NodeVisitor visitor);

}
