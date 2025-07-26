import 'package:flutter/material.dart';
import 'package:stager/editors/editor_factory.dart';
import 'package:stager/editors/stager_editor.dart';
import 'package:stager/editors/widget_factory.dart';
import 'package:stager/site_state.dart';
import 'package:stager/editors/basic_widget_factory.dart';

class BasicEditorFactory extends EditorFactory {

  final WidgetFactory widgetFactory;

  /// Constructor for the BasicEditorFactory class.
  ///
  /// [widgetFactory]: An optional widget factory for the editor to use. The
  /// default is a [BasicWidgetFactory].
  const BasicEditorFactory([this.widgetFactory = const BasicWidgetFactory()]);

  @override
  StagerEditor addSiteEditor(
    BuildContext context,
    SiteState state, [
    WidgetFactory widgetFactory = const BasicWidgetFactory(),
  ]) {
    // TODO: implement addSiteEditor
    throw UnimplementedError();
  }

  @override
  StagerEditor createNodeEditor(
    BuildContext context,
    SiteState state, [
    WidgetFactory widgetFactory = const BasicWidgetFactory(),
  ]) {
    // TODO: implement createNodeEditor
    throw UnimplementedError();
  }

  @override
  StagerEditor deleteNodeEditor(
    BuildContext context,
    SiteState state, [
    WidgetFactory widgetFactory = const BasicWidgetFactory(),
  ]) {
    // TODO: implement deleteNodeEditor
    throw UnimplementedError();
  }

  @override
  StagerEditor deleteSiteEditor(
    BuildContext context,
    SiteState state, [
    WidgetFactory widgetFactory = const BasicWidgetFactory(),
  ]) {
    // TODO: implement deleteSiteEditor
    throw UnimplementedError();
  }

  @override
  StagerEditor editNodeEditor(
    BuildContext context,
    SiteState state, [
    WidgetFactory widgetFactory = const BasicWidgetFactory(),
  ]) {
    // TODO: implement editNodeEditor
    throw UnimplementedError();
  }

  @override
  StagerEditor editSiteEditor(
    BuildContext context,
    SiteState state, [
    WidgetFactory widgetFactory = const BasicWidgetFactory(),
  ]) {
    // TODO: implement editSiteEditor
    throw UnimplementedError();
  }
}
