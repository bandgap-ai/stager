
/// This file defines abstract classes for editing different types of nodes
/// within the Stager tree structure.
library;

import 'package:flutter/material.dart';
import 'package:stager/tree/tree.dart';

/// Abstract class for editing [NodeProperties].
///
/// Implementations will provide UI for modifying a node's properties.
abstract class AbstractNodePropertiesEditor {
  /// Builds a widget that allows editing the properties of a [NodeProperties] instance.
  ///
  /// [properties]: The [NodeProperties] instance to edit.
  /// Type safety: Implementations should handle various property types gracefully.
  Widget buildPropertiesEditor(NodeProperties properties);
}

/// Abstract class for editing a [LeafNode].
///
/// Implementations will provide UI for modifying a leaf node's basic attributes.
abstract class AbstractLeafNodeEditor {
  /// Builds a widget that allows editing a [LeafNode].
  ///
  /// [node]: The [LeafNode] instance to edit.
  /// Type safety: Ensure the [node] is a valid [LeafNode].
  Widget buildLeafNodeEditor(LeafNode node);
}

/// Abstract class for editing a [CompositeNode].
///
/// Implementations will provide UI for managing a composite node's children
/// (add, remove, reorder) in addition to its own attributes.
abstract class AbstractCompositeNodeEditor {
  /// Builds a widget that allows editing a [CompositeNode].
  ///
  /// [node]: The [CompositeNode] instance to edit.
  /// Type safety: Ensure the [node] is a valid [CompositeNode].
  Widget buildCompositeNodeEditor(CompositeNode node);
}

/// Abstract class for editing an entire [TreeNode] structure.
///
/// Implementations will provide UI for managing the overall tree structure,
/// including adding/removing top-level nodes.
abstract class AbstractTreeEditor {
  /// Builds a widget that allows editing the entire tree structure.
  ///
  /// [rootNodes]: A list of top-level [TreeNode]s to edit.
  /// Type safety: Ensure the [rootNodes] are valid [TreeNode] instances.
  Widget buildTreeEditor(List<TreeNode> rootNodes);
}
