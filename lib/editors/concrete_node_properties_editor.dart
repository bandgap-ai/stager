import 'package:flutter/material.dart';
import 'package:stager/tree/tree.dart';
import 'package:stager/editors/tree_editor.dart';
import 'package:stager/editors/edit_node_dialog.dart';
import 'package:stager/editors/enhanced_edit_node_dialog.dart';

/// A concrete implementation of [AbstractNodePropertiesEditor].
///
/// This class provides the UI for editing the properties of a [NodeProperties] object.
/// It renders an "Edit" button that, when pressed, opens an [EditNodeDialog]
/// to modify the node's name.
class ConcreteNodePropertiesEditor extends AbstractNodePropertiesEditor {
  /// The build context to show dialogs.
  final BuildContext context;

  /// Creates a properties editor.
  const ConcreteNodePropertiesEditor(this.context, {super.key});

  @override
  State<ConcreteNodePropertiesEditor> createState() => _ConcreteNodePropertiesEditorState();

}

class _ConcreteNodePropertiesEditorState extends State<ConcreteNodePropertiesEditor> {
  @override
  Widget buildPropertiesEditor(NodeProperties properties) {
    // This widget builds the UI element that triggers the edit action.
    return IconButton(
      icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary),
      onPressed: () async {
        // This logic is moved directly from _editNode in HomePage
        final newName = await showDialog<String>(
          context: context,
          // Assuming EditNodeDialog takes properties now
          builder: (context) => EditNodeDialog(properties: properties),
        );

        if (newName != null) {
          // This now triggers the notify() call within the properties object
          properties.setProperty('name', newName);
        }
      },
    );
  }

  /// Builds an enhanced properties editor for [LeafNode] objects.
  /// Uses the enhanced dialog for Level 1 nodes (with outline area editing).
  Widget buildEnhancedPropertiesEditor(LeafNode node) {
    final level = _getNodeLevel(node);

    return IconButton(
      icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary),
      onPressed: () async {
        if (level == 1) {
          // Use enhanced dialog for Level 1 nodes
          await showDialog(
            context: context,
            builder: (context) => EnhancedEditNodeDialog(
              properties: node.properties,
              node: node,
            ),
          );
        } else {
          // Use regular dialog for other levels
          final newName = await showDialog<String>(
            context: context,
            builder: (context) => EditNodeDialog(properties: node.properties),
          );

          if (newName != null) {
            node.properties.setProperty('name', newName);
          }
        }
      },
    );
  }

  /// Determines the level of a node in the tree (1 = top level under site, etc.)
  int _getNodeLevel(LeafNode node) {
    int level = 0;
    LeafNode? current = node;
    while (current?.parent != null) {
      level++;
      current = current!.parent;
    }
    return level;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}
