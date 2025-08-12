
/// This file defines abstract classes for viewing different types of nodes
/// within the Stager tree structure, leveraging the Observer pattern.
library;

import 'package:flutter/material.dart';
import 'package:stager_platform/tree/tree.dart';

/// Abstract class for viewing [NodeProperties].
///
/// Implementations of this class will provide a visual representation
/// of a node's properties and should ideally observe changes to them.
abstract class AbstractNodePropertiesViewer implements NodePropertiesObserver {
  /// Builds a widget that displays the properties of a [NodeProperties] instance.
  ///
  /// [properties]: The [NodeProperties] instance to display.
  /// Type safety: Implementations should handle various property types gracefully.
  Widget buildPropertiesView(NodeProperties properties);
}

/// Abstract class for viewing a [LeafNode].
///
/// Implementations will provide a visual representation of a leaf node,
/// including its properties and basic structural information (parent, siblings).
/// It should also observe changes to the leaf node.
abstract class AbstractLeafNodeViewer implements LeafNodeObserver {
  /// Builds a widget that displays a [LeafNode].
  ///
  /// [node]: The [LeafNode] instance to display.
  /// [level]: The depth of the node in the tree, used for visual indentation.
  /// Type safety: Ensure the [node] is a valid [LeafNode].
  Widget buildLeafNodeView(LeafNode node, int level);
}

/// Abstract class for viewing a [CompositeNode].
///
/// Implementations will provide a visual representation of a composite node,
/// including its properties and its children. It should also observe changes
/// to the composite node.
abstract class AbstractCompositeNodeViewer {
  /// Builds a widget that displays a [CompositeNode].
  ///
  /// [node]: The [CompositeNode] instance to display.
  /// [level]: The depth of the node in the tree, used for visual indentation.
  /// [childViewer]: A viewer capable of building widgets for child [LeafNode]s.
  /// Type safety: Ensure the [node] is a valid [CompositeNode].
  Widget buildCompositeNodeView(CompositeNode node, int level, AbstractLeafNodeViewer childViewer);
}

/// Abstract class for viewing an entire [TreeNode] structure.
///
/// Implementations will provide a visual representation of the entire tree,
/// typically starting from the root nodes.
abstract class AbstractTreeViewer {
  /// Builds a widget that displays the entire tree structure.
  ///
  /// [rootNodes]: A list of top-level [TreeNode]s to display.
  /// [leafNodeViewer]: A viewer capable of building widgets for individual [LeafNode]s.
  /// [compositeNodeViewer]: A viewer capable of building widgets for individual [CompositeNode]s.
  /// Type safety: Ensure the [rootNodes] are valid [TreeNode] instances.
  Widget buildTreeView(List<TreeNode> rootNodes, AbstractLeafNodeViewer leafNodeViewer, AbstractCompositeNodeViewer compositeNodeViewer);
}
