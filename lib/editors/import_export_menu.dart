import 'package:flutter/material.dart';
import 'package:stager_platform/site_state.dart';
import 'package:stager_platform/editors/file_handler.dart';
import 'package:stager_platform/editors/standard_widgets.dart';

/// A popup menu button that provides "Import" and "Export" options.
///
/// This widget handles the logic for initiating file import and export
/// operations using the provided [FileHandler].
class ImportExportMenu extends StatelessWidget {
  /// The state manager for the site data.
  final SiteState siteState;

  /// The handler for file import/export operations.
  final FileHandler fileHandler;

  /// Creates an import/export menu widget.
  const ImportExportMenu({
    super.key,
    required this.siteState,
    required this.fileHandler,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.onPrimary),
      onSelected: (value) async {
        Function() errorDialogCallback = buildErrorDialogCallback(context,
            "Error", "Directory selection and exporting not available on this platform.");
        Function(String) notificationCallback = buildNotificationCallback(context);
        final selectedNode = siteState.selectedNode;
        if (value == 'export') {
          final nodesToExport = selectedNode != null ? [selectedNode] : siteState.treeData;
          final fileName = selectedNode != null
              ? '${selectedNode.properties.getProperty('name')}.json'
              : 'tracee_export.json';
          await fileHandler.export(
            nodes: nodesToExport,
            suggestedFileName: fileName,
            errorDialogCallback: errorDialogCallback,
              notificationCallback: notificationCallback,
          );
        } else if (value == 'import') {
          final importedNodes = await fileHandler.import(notificationCallback: notificationCallback);
          if (importedNodes != null) {
            siteState.addNodes(importedNodes);
          }
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'export',
          child: Text('Export to File...'),
        ),
        const PopupMenuItem<String>(
          value: 'import',
          child: Text('Import from File...'),
        ),
      ],
    );
  }
}
