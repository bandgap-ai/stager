/// This file defines abstract classes for editing different types of nodes
/// within the Stager tree structure.
library;

import 'package:flutter/material.dart';
import 'package:stager_platform/editors/site_editor.dart';
import 'package:stager_platform/editors/stager_editor.dart';
import 'package:stager_platform/editors/widget_factory.dart';
import 'package:stager_platform/site_state.dart';
import 'package:stager_platform/editors/basic_widget_factory.dart';
import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/leaf_node.dart';

/// This is an abstract factory class definition for creating editors.
abstract class EditorFactory {

  const EditorFactory();

  /// Creates a new StagerEditor that can create new nodes in the site state.
  ///
  /// Note that this editor can create either a [LeafNode] or a [CompositeNode].
  /// The return type indicates that it is an editor on the CompositeNode
  /// [parent] received as input, not the type of the child, (which is,
  /// admittedly, a bit confusing...).
  ///
  /// [context]: The build context for the widget.
  /// [parent]: The parent node for the new node.
  StagerEditor<CompositeNode> createNodeBuilder(BuildContext context, CompositeNode parent);

  /// Creates a new StagerEditor that can edit an existing leaf node.
  ///
  /// [context]: The build context for the widget.
  /// [node]: The leaf node to edit.
  StagerEditor<LeafNode> createLeafNodeEditor(BuildContext context, LeafNode node);

  /// Creates a new StagerEditor that can edit an existing composite node.
  ///
  /// [context]: The build context for the widget.
  /// [node]: The composite node to edit.
  StagerEditor<CompositeNode> createCompositeNodeEditor(BuildContext context, CompositeNode node);

  /// Creates a new StagerEditor that can safely delete an existing node in the
  /// site state.
  ///
  /// [context]: The build context for the widget.
  /// [state]: The Stager SiteState that defines the data to be edited.
  /// [widgetFactory]: An optional widget factory for the editor to use. The
  /// default is a [BasicWidgetFactory].
  SiteEditor deleteNodeEditor(BuildContext context, SiteState state,
      [WidgetFactory widgetFactory = const BasicWidgetFactory()]);

  /// Creates a new StagerEditor that can create a new site in the site state.
  ///
  /// [context]: The build context for the widget.
  /// [state]: The state manager for the Stager entity.
  /// [widgetFactory]: An optional widget factory for the editor to use. The
  /// default is a [BasicWidgetFactory].
  SiteEditor addSiteEditor(BuildContext context, SiteState state,
      [WidgetFactory widgetFactory = const BasicWidgetFactory()]);

  /// Creates a new StagerEditor that can edit an existing site in the site
  /// state.
  ///
  /// [context]: The build context for the widget.
  /// [state]: The state manager for the Stager entity.
  /// [widgetFactory]: An optional widget factory for the editor to use. The
  /// default is a [BasicWidgetFactory].
  SiteEditor editSiteEditor(BuildContext context, SiteState state,
      [WidgetFactory widgetFactory = const BasicWidgetFactory()]);

  /// Creates a new StagerEditor that can safely delete an existing site in the
  /// site state.
  ///
  /// [context]: The build context for the widget.
  /// [state]: The state manager for the Stager entity.
  /// [widgetFactory]: An optional widget factory for the editor to use. The
  /// default is a [BasicWidgetFactory].
  SiteEditor deleteSiteEditor(BuildContext context, SiteState state,
      [WidgetFactory widgetFactory = const BasicWidgetFactory()]);

}