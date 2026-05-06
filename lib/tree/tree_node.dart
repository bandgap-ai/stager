import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/leaf_node.dart';
import 'package:stager_platform/tree/node_summary.dart';

/// An abstract class representing a tree node with advanced traversal and search capabilities.
///
/// This class extends [CompositeNode], providing methods to iterate through the tree
/// structure and to find specific nodes based on a given predicate.
abstract class TreeNode extends CompositeNode {

  const TreeNode();

  /// Creates and returns an [Iterator] for traversing the tree.
  ///
  /// The default implementation of this method should provide a depth-first traversal.
  /// The specific traversal order (e.g., depth-first, breadth-first) will depend
  /// on the concrete implementation of this method.
  /// Type safety: The iterator will yield [LeafNode] instances. Consumers should
  /// be prepared to handle both concrete [LeafNode]s and [CompositeNode]s.
  Iterator<LeafNode> createIterator();

  /// Creates and returns an [Iterator] for traversing the tree in a breadth-first manner.
  ///
  /// Type safety: The iterator will yield [LeafNode] instances. Consumers should
  /// be prepared to handle both concrete [LeafNode]s and [CompositeNode]s.
  Iterator<LeafNode> get breadthFirstIterator;

  /// Creates and returns an [Iterator] for traversing the tree in a depth-first manner.
  ///
  /// Type safety: The iterator will yield [LeafNode] instances. Consumers should
  /// be prepared to handle both concrete [LeafNode]s and [CompositeNode]s.
  Iterator<LeafNode> get depthFirstIterator;

  /// Finds all [LeafNode]s in the tree that satisfy the given [predicate].
  ///
  /// [predicate]: A function that takes a [LeafNode] as input and returns `true`
  /// if the node should be included in the results, and `false` otherwise.
  /// Type safety: The [predicate] function must correctly handle [LeafNode] types.
  /// Returns a [List] of [LeafNode]s that match the predicate.
  List<LeafNode> find(bool Function(LeafNode) predicate);

  /// Summarizes the node and its subtree by counting child nodes and computing geographic bounds.
  ///
  /// This method traverses all child nodes, counts them by hierarchical level,
  /// extracts coordinate positions, and computes a bounding polygon that outlines
  /// all children positions. It also calculates total area from Level 1 outline
  /// polygons when available.
  ///
  /// Returns a [NodeSummary] containing:
  /// - Total node count and counts by level
  /// - Convex hull polygon of all node positions
  /// - Geographic center point (centroid)
  /// - Total area of Level 1 outline polygons
  /// - Additional forestry-specific statistics
  NodeSummary summarize();
}
