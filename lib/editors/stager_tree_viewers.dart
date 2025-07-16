import 'package:flutter/material.dart';
import 'package:stager/tree/tree.dart';
import 'package:stager/tree/node_summary.dart';
import 'package:stager/editors/tree_icon_provider.dart';
import 'package:stager/editors/node_editor.dart';
import 'package:stager/editors/add_property_dialog.dart';

/// A stateful widget that displays the properties of a [NodeProperties] object
/// and automatically updates itself when the properties change.
class NodePropertiesView extends StatefulWidget {
  final NodeProperties properties;

  const NodePropertiesView({super.key, required this.properties});

  @override
  State<NodePropertiesView> createState() => _NodePropertiesViewState();
}

class _NodePropertiesViewState extends State<NodePropertiesView>
    implements NodePropertiesObserver {
  @override
  void initState() {
    super.initState();
    widget.properties.attach(this);
  }

  @override
  void didUpdateWidget(NodePropertiesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.properties != oldWidget.properties) {
      oldWidget.properties.detach(this);
      widget.properties.attach(this);
    }
  }

  @override
  void dispose() {
    widget.properties.detach(this);
    super.dispose();
  }

  @override
  void update(NodeProperties properties) {
    if (mounted) {
      setState(() {});
    }
  }

  /// This function will:
  /// 1.Replace underscores (_) or hyphens (-) with spaces.
  /// 2.Capitalize the first letter of each word.
  /// 3.Handle common camelCase or PascalCase by inserting spaces before uppercase letters (if they are preceded by a lowercase letter).
  ///
  /// [key]: The string to spruce up.
  String _spruceUpKey(String key) {
    if (key.isEmpty) {
      return '';
    }

    // 1. Replace common separators with spaces
    String spacedKey = key.replaceAll('_', ' ').replaceAll('-', ' ');

    // 2. Handle camelCase or PascalCase by inserting spaces before uppercase letters
    // (if preceded by a lowercase letter or a digit)
    // Example: "firstName" -> "first Name", "version2Update" -> "version2 Update"
    // Example: "APIKey" -> "API Key"
    spacedKey = spacedKey.replaceAllMapped(
      RegExp(r'(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])'),
          (Match m) => ' ${m[0]}',
    );

    // 3. Trim leading/trailing spaces that might have been introduced
    spacedKey = spacedKey.trim();

    // 4. Capitalize the first letter of each word
    if (spacedKey.isEmpty) { // Check again after trimming and potential regex changes
      return '';
    }

    List<String> words = spacedKey.split(' ');
    List<String> capitalizedWords = words.map((word) {
      if (word.isEmpty) {
        return '';
      }
      // Preserve case for acronyms or specific multi-uppercase words if needed,
      // otherwise, make rest of the word lowercase before capitalizing first letter.
      // For simplicity here, we just capitalize the first letter and keep the rest.
      // If you want "MYKey" to become "Mykey", you'd add: word = word.toLowerCase();
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).toList();

    return capitalizedWords.join(' ');
  }

  /// Creates a table widget with the properties of the node.
  ///
  /// [context]: The context in which the widget is being built.
  /// [properties]: The [NodeProperties] object containing the properties to display.
  Widget _createTableWidget(BuildContext context, NodeProperties properties) {

    final props = properties.map.entries.where((entry) =>
          entry.key != 'id' &&
          entry.key != 'name' &&
          entry.key != 'imagePaths').toList();

    Widget tableWidget =  Table(
        border: TableBorder.all( // Adds borders to cells for clarity
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        // Define column widths. You can customize these.
        // IntrinsicColumnWidth sizes the column to the widest content in that column.
        // FixedColumnWidth gives a specific width.
        // FractionColumnWidth gives a width as a fraction of the total table width.
        columnWidths: const <int, TableColumnWidth>{
          0: IntrinsicColumnWidth(), // Key column
          1: FlexColumnWidth(),       // Value column (takes remaining space)
        },
        children: props.map((entry) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _spruceUpKey(entry.key),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  entry.value?.toString() ?? 'N/A', // Handle potential null values
                ),
              ),
            ],
          );
        }).toList(),
    );

    return tableWidget;
  }

  /// Creates a button to edit the properties.
  ///
  /// [context]: The context in which the widget is being built.
  Widget _buildEditButton(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            final updatedProperties = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (BuildContext context) {
                return NodeEditor(properties: widget.properties);
              },
            );

            if (updatedProperties != null) {
              // Update the properties of the current node
              updatedProperties.forEach((key, value) {
                widget.properties.setProperty(key, value);
              });
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final newProperty = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (BuildContext context) {
                return const AddPropertyDialog();
              },
            );

            if (newProperty != null && newProperty.keys.isNotEmpty) {
              final key = newProperty.keys.first;
              final value = newProperty[key];
              widget.properties.setProperty(key, value);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.properties.getProperty('name') as String? ?? 'Unknown',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Show the table only if there are properties to display
        if (widget.properties.map.isNotEmpty)
        _createTableWidget(context, widget.properties)
        // Show an error message otherwise.
        else const Text("No properties to display."),
        _buildEditButton(context),
      ],
    );
  }

}

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
