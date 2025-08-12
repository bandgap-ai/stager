import 'package:flutter/material.dart';
import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/editors/stager_tree_viewers.dart';
import 'package:stager_platform/editors/tree_icon_provider.dart';

/// A widget that
/// displays a hierarchical list of [LeafNode]s.
class TreeView extends StatelessWidget {
  /// The list of top-level [TreeNode]s (sites) to be displayed.
  final List<TreeNode> sites;

  /// The currently selected [LeafNode]. Used for highlighting.
  final LeafNode? selectedNode;

  /// Callback function invoked when a node in the tree is tapped.
  final void Function(LeafNode) onNodeTap;

  /// Creates a [TreeView] widget.
  ///
  /// Requires a list of [sites] [TreeNode]s, an optional [selectedNode],
  /// and an [onNodeTap] callback.
  const TreeView({
    super.key,
    required this.sites,
    this.selectedNode,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconProvider = TreeIconProvider();

    return ListView.builder(
      itemCount: sites.length,
      itemBuilder: (context, index) {
        final node = sites[index];
        return node.isComposite
            ? CompositeNodeView(
                node: node as CompositeNode,
                level: 0,
                selectedNode: selectedNode,
                onNodeTap: onNodeTap,
                iconProvider: iconProvider,
              )
            : LeafNodeView(
                node: node,
                level: 0,
                selectedNode: selectedNode,
                onNodeTap: onNodeTap,
                iconProvider: iconProvider,
              );
      },
    );
  }
}
