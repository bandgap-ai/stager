import 'package:flutter/material.dart';
import 'package:stager/editors/editor_factory.dart';
import 'package:stager/editors/site_editor.dart';
import 'package:stager/editors/widget_factory.dart';
import 'package:stager/site_state.dart';
import 'package:stager/editors/basic_widget_factory.dart';
import 'package:stager/editors/message_dialog.dart';
import 'package:stager/editors/add_node_dialog.dart';

class BasicEditorFactory extends EditorFactory {

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
  SiteEditor createNodeEditor(
    BuildContext context,
    SiteState state, [
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
  SiteEditor editNodeEditor(
    BuildContext context,
    SiteState state, [
    WidgetFactory widgetFactory = const BasicWidgetFactory(),
  ]) {
    // TODO: implement editNodeEditor
    throw UnimplementedError();
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
