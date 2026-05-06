import 'package:flutter/material.dart';
import 'package:stager_platform/stager.dart';
import '../editors/site_controls.dart';
import '../site_state.dart';
import '../editors/stager_navigator_header.dart';
import '../editors/tree_view.dart';
import '../editors/basic_site_controls.dart';
import '../editors/stager_pin.dart';

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

  /// The Stager System to use for tracking selections, constants, file paths,
  /// etc.
  final StagerSystem stagerSystem;

  /// The handler for file import/export operations.
  final FileHandler fileHandler;

  /// The SiteControls for building the editor buttons.
  final SiteControls siteControls;

  /// An optional StagerPin widget to pin the navigator.
  final StagerPin? pin;

  /// Creates a site editor widget.
  ///
  /// [siteState]: The state manager for the site data.
  /// [selection]: The Selection handler for the currently selected node
  /// [fileHandler]: The handler for file import/export operations.
  /// [siteControls]: The SiteControls for building the editor buttons.
  /// [pin]: An optional StagerPin widget to pin the navigator.
  const StagerNavigator({
    super.key,
    required this.siteState,
    this.fileHandler = const BasicFileHandler(),
    this.siteControls = const BasicSiteControls(),
    this.pin,
    this.stagerSystem = const StagerSystem(),
  });

  @override
  State<StatefulWidget> createState() => _StagerNavigatorState();
}

/// The state for the [StagerNavigator] widget.
class _StagerNavigatorState extends State<StagerNavigator> {
  late SiteState _siteState;
  late SelectionService _selectionService;
  late FileHandler _fileHandler;
  StagerPin? _pin;
  late SiteControls _siteControls;
  final BasicSelectionVisitorHandler handler = BasicSelectionVisitorHandler();

  @override
  void initState() {
    super.initState();
    _siteState = widget.siteState;
    _selectionService = widget.stagerSystem.selectionService();
    _fileHandler = widget.fileHandler;
    _pin = widget.pin;
    _siteControls = widget.siteControls;
  }

  /// This is a temporary convenience method until I finish the full migration
  /// to the new selection service.
  LeafNode? _getSelection() {
    return (_selectionService.isSet()) ? _selectionService.selection.value : null;
  }

  @override
  Widget build(BuildContext context) {
    // Create the header so it can be passed to the TreeView and used as a
    // callback to process the selected node.
    StagerNavigatorHeader header = StagerNavigatorHeader(
      siteState: _siteState,
      fileHandler: _fileHandler,
      selectedNode: _getSelection(),
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
            selectedNode: _getSelection(),
            onNodeTap: (node) {
              setState(() {
                // Update the state to force a redraw and update the other
                // widgets.
                _siteState.selectedNode = node;
                // FIXME - This is a bit abusive of the API and this whole
                // class needs to fit the selection life cycle better.
                widget.stagerSystem.selectionService().selection = Selection<LeafNode>(node);
              });
            },
          ),
        ),
      ],
    );
  }

}
