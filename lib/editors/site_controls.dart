import 'package:flutter/cupertino.dart';
import 'package:stager_platform/editors/dialog_control_button.dart';
import 'package:stager_platform/site_state.dart';
import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/leaf_node.dart';

/// This is a factory interface for managing controls used to create editors
/// in the Site Editor.
abstract class SiteControls {

  const SiteControls();

  /// Creates a [DialogControlButton] for adding a new node to the specified
  /// parent node.
  ///
  /// [context]: The build context.
  /// [parent]: The parent node for the node that will be added.
  DialogControlButton buildAddNodeControl(BuildContext context, CompositeNode node);

  /// Creates a [DialogControlButton] for editing an existing node.
  ///
  /// [context]: The build context.
  /// [state]: The node to edit.
  DialogControlButton buildEditNodeControl(BuildContext context, LeafNode state);

  /// Creates a [DialogControlButton] for deleting a node.
  ///
  /// [context]: The build context.
  /// [state]: The site state.
  DialogControlButton buildDeleteNodeControl(BuildContext context, SiteState state);

  /// Creates a [DialogControlButton] for adding a new site.
  ///
  /// [context]: The build context.
  /// [state]: The site state.
  DialogControlButton buildAddSiteControl(BuildContext context, SiteState state);

  /// Creates a [DialogControlButton] for editing an existing site.
  ///
  /// [context]: The build context.
  /// [state]: The site state.
  DialogControlButton buildEditSiteControl(BuildContext context, SiteState state);

  /// Creates a [DialogControlButton] for deleting a site.
  ///
  /// [context]: The build context.
  /// [state]: The site state.
  DialogControlButton buildDeleteSiteControl(BuildContext context, SiteState state);
}