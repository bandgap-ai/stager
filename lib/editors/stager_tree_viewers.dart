import 'package:flutter/material.dart';
import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/tree/node_summary.dart';
import 'package:stager_platform/editors/tree_icon_provider.dart';



/// A stateful widget that displays a [LeafNode] as a [ListTile] and
/// automatically updates itself when the node's data changes.
class LeafNodeView extends StatefulWidget {
  final LeafNode node;
  final int level;
  final LeafNode? selectedNode;
  final void Function(LeafNode) onNodeTap;
  final TreeIconProvider iconProvider;

  const LeafNodeView({
    super.key,
    required this.node,
    required this.level,
    this.selectedNode,
    required this.onNodeTap,
    required this.iconProvider,
  });

  @override
  State<LeafNodeView> createState() => _LeafNodeViewState();
}

class _LeafNodeViewState extends State<LeafNodeView> implements LeafNodeObserver {
  @override
  void initState() {
    super.initState();
    widget.node.attach(this);
  }

  @override
  void didUpdateWidget(LeafNodeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.node != oldWidget.node) {
      oldWidget.node.detach(this);
      widget.node.attach(this);
    }
  }

  @override
  void dispose() {
    widget.node.detach(this);
    super.dispose();
  }

  @override
  void update(LeafNode node) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData = widget.iconProvider.getIconForLevel(widget.level);
    final bool isSelected = widget.selectedNode?.properties.getProperty('id') ==
        widget.node.properties.getProperty('id');

    return ListTile(
      contentPadding: EdgeInsets.only(left: 16.0 + widget.level * 20.0),
      title: Text(widget.node.properties.getProperty('name') as String),
      leading: Icon(iconData),
      selected: isSelected,
      onTap: () => widget.onNodeTap(widget.node),
    );
  }
}

/// A stateful widget that displays a [CompositeNode] as an [ExpansionTile]
/// and automatically updates itself and its children when the node's data changes.
class CompositeNodeView extends StatefulWidget {
  /// The node to be displayed.
  final CompositeNode node;
  /// The depth of the node in the tree, used for indentation.
  final int level;
  /// The currently selected node, used for highlighting.
  final LeafNode? selectedNode;
  /// The callback to be invoked when the node is tapped.
  final void Function(LeafNode) onNodeTap;
  /// The provider for the icon to be displayed.
  final TreeIconProvider iconProvider;

  const CompositeNodeView({
    super.key,
    required this.node,
    required this.level,
    this.selectedNode,
    required this.onNodeTap,
    required this.iconProvider,
  });

  @override
  State<CompositeNodeView> createState() => _CompositeNodeViewState();
}

class _CompositeNodeViewState extends State<CompositeNodeView>
    implements LeafNodeObserver {
  @override
  void initState() {
    super.initState();
    widget.node.attach(this);
  }

  @override
  void didUpdateWidget(CompositeNodeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.node != oldWidget.node) {
      oldWidget.node.detach(this);
      widget.node.attach(this);
    }
  }

  @override
  void dispose() {
    widget.node.detach(this);
    super.dispose();
  }

  @override
  void update(LeafNode node) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData = widget.iconProvider.getIconForLevel(widget.level);
    final bool isSelected = widget.selectedNode?.properties.getProperty('id') ==
        widget.node.properties.getProperty('id');

    return ExpansionTile(
      tilePadding: EdgeInsets.only(left: 16.0 + widget.level * 20.0),
      title: Text(widget.node.properties.getProperty('name') as String),
      leading: Icon(iconData),
      initiallyExpanded: isSelected,
      backgroundColor:
          isSelected ? Theme.of(context).colorScheme.secondaryContainer : null,
      collapsedBackgroundColor:
          isSelected ? Theme.of(context).colorScheme.secondaryContainer : null,
      children: widget.node.children
          .map((child) => child.isComposite
              ? CompositeNodeView(
                  node: child as CompositeNode,
                  level: widget.level + 1,
                  selectedNode: widget.selectedNode,
                  onNodeTap: widget.onNodeTap,
                  iconProvider: widget.iconProvider,
                )
              : LeafNodeView(
                  node: child,
                  level: widget.level + 1,
                  selectedNode: widget.selectedNode,
                  onNodeTap: widget.onNodeTap,
                  iconProvider: widget.iconProvider,
                ))
          .toList(),
      onExpansionChanged: (expanded) {
        if (expanded) {
          widget.onNodeTap(widget.node);
        }
      },
    );
  }
}



/// A widget that displays a [NodeSummary] with statistics about a node and its subtree.
class NodeSummaryView extends StatelessWidget {
  final NodeSummary summary;

  const NodeSummaryView({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Node Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTable(BuildContext context) {
    final rows = <TableRow>[];

    // Total nodes
    rows.add(_buildTableRow(context, 'Total Nodes', '${summary.totalNodes}'));

    // Nodes by level
    if (summary.nodeCountsByLevel.isNotEmpty) {
      final levelText = summary.nodeCountsByLevel.entries
          .map((e) => 'L${e.key}: ${e.value}')
          .join(', ');
      rows.add(_buildTableRow(context, 'By Level', levelText));
    }

    // Geographic center
    if (summary.centerPoint != null) {
      rows.add(_buildTableRow(
        context,
        'Center',
        '${summary.centerPoint!.latitude.toStringAsFixed(4)}, ${summary.centerPoint!.longitude.toStringAsFixed(4)}',
      ));
    }

    // Bounding polygon
    if (summary.boundingPolygon.isNotEmpty) {
      rows.add(_buildTableRow(
        context,
        'Boundary Points',
        '${summary.boundingPolygon.length}',
      ));
    }

    // Total outline area
    if (summary.totalOutlineArea != null) {
      rows.add(_buildTableRow(
        context,
        'Total Area',
        '${summary.totalOutlineArea!.toStringAsFixed(2)} m²',
      ));
    }

    // Additional stats
    if (summary.additionalStats.isNotEmpty) {
      for (final entry in summary.additionalStats.entries) {
        rows.add(_buildTableRow(context, entry.key, entry.value.toString()));
      }
    }

    return Table(
      border: TableBorder.all(
        color: Theme.of(context).dividerColor,
        width: 1,
      ),
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: rows,
    );
  }

  TableRow _buildTableRow(BuildContext context, String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value),
        ),
      ],
    );
  }
}
