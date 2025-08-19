import 'package:flutter/material.dart';
import 'package:stager_platform/editors/editor_factory.dart';
import 'package:stager_platform/editors/site_editor.dart';
import 'package:stager_platform/editors/stager_editor.dart';
import 'package:stager_platform/editors/widget_factory.dart';
import 'package:stager_platform/site_state.dart';
import 'package:stager_platform/editors/basic_widget_factory.dart';
import 'package:stager_platform/editors/add_node_dialog.dart';
import 'package:stager_platform/tree/leaf_node.dart';
import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/editors/leaf_node_editor.dart';
import 'package:stager_platform/editors/composite_node_editor.dart';

/// The BasicEditorFactory is an extension of the EditorFactory abstract base
/// class that provides a default implementation using widgets that are
/// defined in and implemented in Stager. It is a simple utility that provides
/// basic functionality to developers.
class BasicEditorFactory extends EditorFactory {

  /// The widget factory used by the editor, which can be overridden as needed
  /// to customize its behavior.
  final WidgetFactory widgetFactory;

  /// Constructor for the BasicEditorFactory class.
  ///
  /// [widgetFactory]: An optional widget factory for the editor to use. The
  /// default is a [BasicWidgetFactory].
  const BasicEditorFactory([this.widgetFactory = const BasicWidgetFactory()]);

  @override
  SiteEditor addSiteEditor(
    BuildContext context,
    SiteState state, [
    WidgetFactory widgetFactory = const BasicWidgetFactory(),
  ]) {
   throw UnimplementedError();
  }

  @override
  StagerEditor<CompositeNode> createNodeBuilder(
    BuildContext context,
    CompositeNode state, [
    WidgetFactory widgetFactory = const BasicWidgetFactory(),
  ]) {
     return AddNodeDialog(state: state);
  }

  @override
  SiteEditor deleteNodeEditor(
    BuildContext context,
    SiteState state, [
    WidgetFactory widgetFactory = const BasicWidgetFactory(),
  ]) {
    // TODO: implement deleteNodeEditor
    throw UnimplementedError();
  }

  @override
  SiteEditor deleteSiteEditor(
    BuildContext context,
    SiteState state, [
    WidgetFactory widgetFactory = const BasicWidgetFactory(),
  ]) {
    // TODO: implement deleteSiteEditor
    throw UnimplementedError();
  }

  @override
  StagerEditor<LeafNode> createLeafNodeEditor(
    BuildContext context,
    LeafNode node, [
    WidgetFactory widgetFactory = const BasicWidgetFactory(),
  ]) {
    return LeafNodeEditor(state: node);
  }

  @override
  StagerEditor<CompositeNode> createCompositeNodeEditor(
      BuildContext context,
      CompositeNode node, [
        WidgetFactory widgetFactory = const BasicWidgetFactory(),
      ]) {
    return CompositeNodeEditor(state: node);
  }

  @override
  SiteEditor editSiteEditor(
    BuildContext context,
    SiteState state, [
    WidgetFactory widgetFactory = const BasicWidgetFactory(),
  ]) {
    // TODO: implement editSiteEditor
    throw UnimplementedError();
  }
}
