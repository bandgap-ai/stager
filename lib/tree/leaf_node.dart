import 'package:stager_platform/tree/node_properties.dart';
import 'package:stager_platform/tree/observable_subject.dart';
import 'package:stager_platform/tree/node_visitor.dart';

/// An abstract class representing a leaf node in a tree structure.
///
/// This class defines the fundamental properties and relationships for a node
/// that can exist within a tree, including its associated data properties
/// and pointers to its parent, next sibling, and previous sibling.
///
/// All nodes accept visitors per the visitor pattern with accept().
abstract class LeafNode implements ObservableSubject {
  /// Retrieves the [NodeProperties] associated with this leaf node.
  ///
  /// This getter provides access to the data payload of the node.
  NodeProperties get properties;

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

  /// Accepts a visitor to perform some operation on the node.
  ///
  /// [visitor]: The [NodeVisitor] to accept.
  void accept(NodeVisitor visitor);

  /// Loads the properties from a map. The map should contain key-value pairs
  /// representing the properties already set by the node.
  ///
  /// The implementation is responsible for accurately loading the properties
  /// from the provided map and casting to the appropriate types. If a key
  /// exists that is not already on the node, it should attempt to add it and
  /// preserve its type (i.e., don't cast it). The base class implementation
  /// should also notify observers by calling notify() once the properties are
  /// updated.
  ///
  /// Subclasses that override this method should call
  /// super.loadPropertiesFromMap() to ensure that super-type properties are
  /// accurately loaded. Likewise, overriding this method should only capture
  /// new properties not already handled by super classes unless there is some
  /// special processing required.
  ///
  /// [mapInput]: The map containing the properties to be loaded.
  void loadPropertiesFromMap(Map<String, dynamic> mapInput);

}
