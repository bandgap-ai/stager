import 'package:flutter/material.dart';
import 'site_controls.dart';
import 'stager_pin.dart';
import 'standard_widgets.dart';
import '../site_state.dart';
import '../tree/tree.dart';
import 'add_site_dialog.dart';
import 'file_handler.dart';
import 'import_export_menu.dart';
import 'basic_site_controls.dart';
import '../system/point.dart';

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
class StagerNavigatorHeader extends StatelessWidget {
  /// The state manager for the site data.
  final SiteState siteState;

  /// The handler for file import/export operations.
  final FileHandler fileHandler;

  /// The SiteControls for building the editor buttons.
  final SiteControls siteControls;

  /// The selected node in the tree.
  final LeafNode? selectedNode;

  /// An optional StagerPin widget to pin the navigator.
  final StagerPin? pin;

  /// Creates a site editor header.
  const StagerNavigatorHeader({
    super.key,
    required this.siteState,
    required this.fileHandler,
    required this.selectedNode,
    this.siteControls = const BasicSiteControls(),
    this.pin,
  });

  /// Adds a new node to the site.
  ///
  /// [nodeInfo] is a map of node information and equivalent to the NodeProperties.
  void _addSite(Map<String, Object> nodeInfo) {
    TreeNode site = siteState.addSite(nodeInfo['name'] as String);
    site.position = Point(coords:
      [double.parse(nodeInfo['longitude'] as String),
      double.parse(nodeInfo['latitude'] as String)]
    );
  }

  @override
  Widget build(BuildContext context) {
    bool pinnable = pin != null;

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
              // The label at the top of the header
              Text(
                siteState.label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                ),
              ),
              // If the navigator can be pinned open, add the pin button.
              if (pinnable) const Spacer(),
              if (pinnable) pin!,
            ],
          ),
          Row(
            children: [
              /// TODO Replace this with SiteControls - and figure out how to do this selection check better.
              /// This should be conditional: If a composite noe is selected, the control is enabled, otherwise not.
              if (_checkNode(selectedNode)) siteControls.buildAddNodeControl(context, selectedNode as CompositeNode),
              // Edit the properties of the selected node.
              if (selectedNode != null) siteControls.buildEditNodeControl(context, selectedNode!),
                // Note that this used to call buildEnhancedPropertiesEditor.
                // That functionality should be migrated to Tracee and it should
                // have a test to verify that the enhanced editor is being used
                // instead of the regular one.
               // nodePropertiesEditor.buildPropertiesEditor(selectedNode!),
              // Delete the selected node.
              if (selectedNode != null)
                IconButton(
                  icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.onPrimary),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => buildConfirmDialog(context,
                          'Delete Node',
                          'Are you sure you want to delete this node?'),
                    );
                    if (confirm == true) {
                      siteState.deleteNode(selectedNode!);
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
                      onAdd: (nodeInfo) => _addSite(nodeInfo),
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

  /// Checks if the selected node is a composite node.
  ///
  /// [selectedNode] is the node to check.
  bool _checkNode(LeafNode? selectedNode) {
    return (selectedNode != null && selectedNode.isComposite);
  }

}

