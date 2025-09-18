import 'package:flutter/material.dart';
import 'package:stager_platform/editors/site_controls.dart';
import 'package:stager_platform/site_state.dart';
import 'package:stager_platform/editors/file_handler.dart';
import 'package:stager_platform/editors/stager_navigator_header.dart';
import 'package:stager_platform/editors/tree_view.dart';
import 'package:stager_platform/editors/properties_widget.dart';
import 'package:stager_platform/tree/leaf_node.dart';
import 'package:stager_platform/editors/basic_site_controls.dart';
import 'package:stager_platform/editors/stager_pin.dart';

/// A widget that provides a comprehensive editing interface for the entire site hierarchy.
///
/// This widget serves as the main view for interacting with the site data. It is
/// composed of two main parts:
/// 1. A [NavigatorHeader] that displays the site label and provides editing controls.
/// 2. A [TreeView] that shows the entire site hierarchy.
///
/// It uses a [SiteState] object to manage and react to state changes.
class StagerNavigator extends StatefulWidget {
  /// The state manager for the site data.
  final SiteState siteState;

  /// The handler for file import/export operations.
  final FileHandler fileHandler;

  /// The SiteControls for building the editor buttons.
  final SiteControls siteControls;

  /// An optional StagerPin widget to pin the navigator.
  final StagerPin? pin;

  /// Creates a site editor widget.
  const StagerNavigator({
    super.key,
    required this.siteState,
    this.fileHandler = const BasicFileHandler(),
    this.siteControls = const BasicSiteControls(),
    this.pin,
  });

  @override
  State<StatefulWidget> createState() => _StagerNavigatorState();
}

/// The state for the [StagerNavigator] widget.
class _StagerNavigatorState extends State<StagerNavigator> {
  late SiteState _siteState;
  late FileHandler _fileHandler;
  LeafNode? _selectedNode;
  StagerPin? _pin;
  late SiteControls _siteControls;

  @override
  void initState() {
    super.initState();
    _siteState = widget.siteState;
    _fileHandler = widget.fileHandler;
    _pin = widget.pin;
    _siteControls = widget.siteControls;
  }

  @override
  Widget build(BuildContext context) {
    // Create the header so it can be passed to the TreeView and used as a
    // callback to process the selected node.
    StagerNavigatorHeader header = StagerNavigatorHeader(
      siteState: _siteState,
      fileHandler: _fileHandler,
      selectedNode: _selectedNode,
      siteControls: _siteControls,
      pin: _pin,
    );

    // Add an optional pin button handler to the constructor.
    // If the pin button handler exists, make the header pinnable.

    return Column(
      children: [
        header,
        Expanded(
          child: TreeView(
            sites: _siteState.treeData,
            selectedNode: _selectedNode,
            onNodeTap: (node) {
              setState(() {
                // Update the state to force a redraw and update the other
                // widgets.
                // Pass the selection to the header for further processing.
                _selectedNode = node;
                _siteState.selectedNode = node;
              });
              // FIXME! This should take the node, not the siteState, but leaving for now.
              // This is bad, mkay?
              Scaffold.of(context).showBottomSheet((context) => PropertiesWidget(siteState: _siteState));
            },
          ),
        ),
      ],
    );
  }
}
