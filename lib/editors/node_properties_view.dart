import 'package:flutter/material.dart';
import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/editors/leaf_node_editor.dart';
import 'package:stager_platform/editors/add_property_dialog.dart';
import 'package:stager_platform/editors/stager_editor.dart';

/// A stateful widget that displays the properties of a [NodeProperties] object
/// and automatically updates itself when the properties change.
class NodePropertiesView extends StagerEditor<LeafNode> {

  const NodePropertiesView({super.key, required super.state});

  @override
  State<NodePropertiesView> createState() {
    return _NodePropertiesViewState();
  }
}

class _NodePropertiesViewState extends State<NodePropertiesView>
    implements NodePropertiesObserver {

  /// The properties of the node
  late NodeProperties properties;

  @override
  void initState() {
    super.initState();
    properties = widget.state.properties;
    properties.attach(this);
  }

  @override
  void didUpdateWidget(NodePropertiesView oldWidget) {
    super.didUpdateWidget(oldWidget);

    properties = widget.state.properties;
    NodeProperties oldProps = oldWidget.state.properties;
    if (properties != oldProps) {
      oldProps.detach(this);
      properties.attach(this);
    }
  }

  @override
  void dispose() {
    properties.detach(this);
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

    final Iterable<MapEntry<String, Object?>> props = properties.map.entries.where((entry) =>
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
                return LeafNodeEditor(state: widget.state);
              },
            );

            if (updatedProperties != null) {
              // Update the properties of the current node
              updatedProperties.forEach((key, value) {
                properties.setProperty(key, value);
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
              properties.setProperty(key, value);
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
          properties.getProperty('name') as String? ?? 'Unknown',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Show the table only if there are properties to display
        if (properties.map.isNotEmpty)
          _createTableWidget(context, properties)
        // Show an error message otherwise.
        else const Text("No properties to display."),
        _buildEditButton(context),
      ],
    );
  }

}