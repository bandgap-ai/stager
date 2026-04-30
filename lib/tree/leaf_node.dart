
import 'package:uuid/uuid.dart';
import 'node_properties.dart';
import 'observable_subject.dart';
import 'node_visitor.dart';
import '../system/point.dart';
import '../system/typed_value.dart';


/// This is a custom exception that is thrown when someone tries to retrieve a
/// node parent or sibling that doesn't exist.
class NodeStructureException implements Exception {

  /// The type of the node that the client attempted to access.
  final String nodeType;

  NodeStructureException(this.nodeType);

  @override
  String toString() => 'NodeStructureException: $nodeType node is'
      ' not available.';
}

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
/// Client classes looking to access the parent or siblings (next and previous)
/// of this class should first check if parents or siblings are assigned. If
/// they are not assigned the getters will throw an exception. Setting the
/// parent or siblings will notify observers.
///
/// Nodes in Stager still follow the no-null policy of the platform, even though
/// nearly all tree data structures and algorithms rely on null values to know
/// when the structure stops. Use explicit checks for the member (i.e.,
/// `while(node.hasParent())`) instead of checks against null values
/// (`if(node.parent != null)`). Internally, nodes use an "orphan" scheme where
/// the null value is represented by `this` since nodes cannot be their own
/// parents or siblings. Instead of returning `this`, nodes will throw a
/// [NodeStructureException] when attempting to access the parent or sibling if
/// they don't exist.
///
/// All nodes accept visitors (per the visitor pattern) with accept().
abstract class LeafNode implements ObservableSubject {

  /// A default position for nodes.
  static const Point defaultPosition = Point(
      coords: const [-77.96876463574121, 38.98951052421746]);

  const LeafNode();

  /// Returns the name of the node
  String get name;

  /// Sets the name of the node if the name is not empty and does nothing
  /// otherwise. Visitors are notified when the name changes.
  ///
  /// [newName]: The new name for the node.
  set name(String newName);

  /// Returns the unique identifier for the node.
  UuidValue get id;

  /// Sets the unique identifier for the node. Visitors are notified when the
  /// name changes.
  set id(UuidValue newId);

  /// Retrieves the position of the node.
  Point get position;

  /// Sets the position of the node. Setting the position notifies listeners.
  ///
  /// [newPoint]: The new position for the node.
  set position(Point newPoint);

  /// Indicates whether this node has a parent.
  ///
  /// Returns `true` if this node has a parent, `false` otherwise.
  bool hasParent();

  /// Indicates whether this node has a next sibling.
  ///
  /// Returns `true` if this node has a next sibling, `false` otherwise.
  bool hasNext();

  /// Indicates whether this node has a previous sibling.
  ///
  /// Returns `true` if this node has a previous sibling, `false` otherwise.
  bool hasPrevious();

  /// Retrieves the parent [LeafNode] of this node.
  ///
  /// Returns `null` if this node is a root node (has no parent).
  LeafNode get parent;

  /// Retrieves the next sibling [LeafNode] in the same level of the tree.
  ///
  /// Returns `null` if this node is the last sibling.
  LeafNode get next;

  /// Retrieves the previous sibling [LeafNode] in the same level of the tree.
  ///
  /// Returns `null` if this node is the first sibling.
  LeafNode get previous;

  /// Indicates whether this node is a composite node (i.e., can have children).
  ///
  /// Concrete [LeafNode] implementations should return `false`.
  /// Concrete [CompositeNode] implementations should return `true`.
  bool get isComposite;

  /// Sets the parent [LeafNode] for this node.
  ///
  /// [parent]: The [LeafNode] to set as the parent.
  void setParent(LeafNode parent);

  /// Sets the next sibling [LeafNode] for this node.
  ///
  /// [next]: The [LeafNode] to set as the next sibling.
  void setNext(LeafNode next);

  /// Sets the previous sibling [LeafNode] for this node.
  ///
  /// [previous]: The [LeafNode] to set as the previous sibling.
  void setPrevious(LeafNode previous);

  /// This method resets the parent, next, and previous pointers to the initial,
  /// orphaned state.
  void resetRelatives();

  /// Returns true if generic properties beyond name and id are available for
  /// this node, and returns false otherwise.
  bool get hasProperties;

  /// True if the node has a property for [key].
  ///
  /// [key]: The key of the property to check.
  /// Returns `true` if the node has a property for [key], `false` otherwise.
  bool hasProperty(String name);

  /// Returns the properties for this node.
  NodeProperties get properties;

  /// Returns the full set of intrinsic and generic properties as a map.
  Map<String, Object> toMap();

  /// Converts the node to an encodable object for JSON serialization.
  ///
  /// Returns the node as a map downcast to an Object.
  Object toJson();

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
  void fromMap(Map<String, Object> inputMap);

  /// Accepts a visitor to perform some operation on the node.
  ///
  /// [visitor]: The [NodeVisitor] to accept.
  void accept(NodeVisitor visitor);
}