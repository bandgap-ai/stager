import 'package:stager_platform/tree/leaf_node.dart';

/// An abstract class representing a composite node in a tree structure.
///
/// This class extends [LeafNode] and adds the capability to manage child nodes,
/// thereby implementing the Composite design pattern. A composite node can
/// contain both leaf nodes and other composite nodes.
///
/// CompositeNodes follow the same no-null policy as LeafNodes. This means that
/// removing a child will result in the child pointing to itself for its parents
/// and siblings (i.e., it is orphaned).
abstract class CompositeNode extends LeafNode {

  CompositeNode({required super.name});

  /// Retrieves the list of child [LeafNode]s directly associated with this composite node.
  ///
  /// This getter provides access to the immediate children of this node.
  List<LeafNode> get children;

  /// Adds a [child] node to this composite node.
  ///
  /// [child]: The [LeafNode] to be added as a child. This can be a concrete [LeafNode]
  /// or another [CompositeNode].
  /// Type safety: Ensure that the provided [child] is a valid [LeafNode] instance.
  void addChild(LeafNode child);

  /// Removes a [child] node from this composite node.
  ///
  /// [child]: The [LeafNode] to be removed from the children list.
  /// Type safety: Ensure that the provided [child] is a valid [LeafNode] instance
  /// and is indeed a child of this node.
  void removeChild(LeafNode child);
}
