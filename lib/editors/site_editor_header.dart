import 'package:flutter/material.dart';
import 'package:stager/editors/node_editor_factory.dart';
import 'package:stager/site_state.dart';
import 'package:stager/tree/tree.dart';
import 'package:stager/editors/add_site_dialog.dart';
import 'package:stager/editors/confirm_dialog.dart';
import 'package:stager/editors/concrete_node_properties_editor.dart';
import 'package:stager/editors/file_handler.dart';
import 'package:stager/editors/import_export_menu.dart';

/// The header for the [SiteEditor].
///
/// This widget displays the site title and a row of action buttons for
/// editing the tree structure. The actions available depend on the currently
/// selected node in the [siteState].
///
/// Actions include:
/// - Adding a child leaf node to a composite node.
/// - Adding a child composite node to a composite node.
/// - Editing the properties of any selected node.
/// - Deleting any selected node (with confirmation).
/// - Adding a new top-level site.
/// - Importing and exporting data.
class SiteEditorHeader extends StatelessWidget {
  /// The state manager for the site data.
  final SiteState siteState;

  /// The handler for file import/export operations.
  final FileHandler fileHandler;

  /// Creates a site editor header.
  const SiteEditorHeader({
    super.key,
    required this.siteState,
    required this.fileHandler,
  });

  /// Adds a new node to the site.
  ///
  /// [nodeInfo] is a map of node information and equivalent to the NodeProperties.
  void _addNode(Map<String, Object> nodeInfo) {
    TreeNode site = siteState.addSite(nodeInfo['name'] as String);
    NodeProperties properties = site.properties;
    properties.setProperty('latitude', double.parse(nodeInfo['latitude'] as String));
    properties.setProperty('longitude', double.parse(nodeInfo['longitude'] as String));
  }

  @override
  Widget build(BuildContext context) {
    final selectedNode = siteState.selectedNode;

    final NodeEditorFactory nodeEditorFactory = NodeEditorFactory();

    final nodePropertiesEditor = ConcreteNodePropertiesEditor(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.public, color: Theme.of(context).colorScheme.onPrimary),
              const SizedBox(width: 8.0),
              Text(
                siteState.label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Add the node creation button.
              nodeEditorFactory.create(context, siteState),
              // Edit the properties of the selected node.
              if (selectedNode != null)
                nodePropertiesEditor.buildEnhancedPropertiesEditor(selectedNode),
              // Delete the selected node.
              if (selectedNode != null)
                IconButton(
                  icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.onPrimary),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => const ConfirmDialog(
                        title: 'Delete Node',
                        content: 'Are you sure you want to delete this node?',
                      ),
                    );
                    if (confirm == true) {
                      siteState.deleteNode(selectedNode);
                    }
                  },
                ),
              const Spacer(),
              // Add a new top-level site.
              IconButton(
                icon: Icon(Icons.add_home_work, color: Theme.of(context).colorScheme.onPrimary),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddSiteDialog(
                      onAdd: (nodeInfo) => _addNode(nodeInfo),
                    ),
                  );
                },
              ),
              // Import/Export menu.
              ImportExportMenu(siteState: siteState, fileHandler: fileHandler),
            ],
          ),
        ],
      ),
    );
  }

}

