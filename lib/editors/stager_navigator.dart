import 'package:flutter/material.dart';
import 'package:stager/site_state.dart';
import 'package:stager/editors/file_handler.dart';
import 'package:stager/editors/stager_navigator_header.dart';
import 'package:stager/editors/tree_view.dart';
import 'package:stager/editors/properties_widget.dart';

/// A widget that provides a comprehensive editing interface for the entire site hierarchy.
///
/// This widget serves as the main view for interacting with the site data. It is
/// composed of two main parts:
/// 1. A [NavigatorHeader] that displays the site label and provides editing controls.
/// 2. A [TreeView] that shows the entire site hierarchy.
///
/// It uses a [SiteState] object to manage and react to state changes.
class StagerNavigator extends StatelessWidget {
  /// The state manager for the site data.
  final SiteState siteState;
  /// The handler for file import/export operations.
  final FileHandler fileHandler;

  /// Creates a site editor widget.
  StagerNavigator({super.key, required this.siteState, FileHandler? fileHandler})
      : fileHandler = fileHandler ?? BasicFileHandler();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StagerNavigatorHeader(
          siteState: siteState,
          fileHandler: fileHandler,
        ),
        Expanded(
          child: TreeView(
            sites: siteState.treeData,
            selectedNode: siteState.selectedNode,
            onNodeTap: (node) {
              siteState.selectedNode = node;
              Scaffold.of(context).showBottomSheet((context) => PropertiesWidget(siteState: siteState));
            },
          ),
        ),
      ],
    );
  }
}

