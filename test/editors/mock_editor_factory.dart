import 'package:flutter/src/widgets/framework.dart';
import 'package:stager/editors/basic_widget_factory.dart';
import 'package:stager/editors/editor_factory.dart';
import 'package:stager/editors/site_editor.dart';
import 'package:stager/editors/stager_editor.dart';
import 'package:stager/editors/widget_factory.dart';
import 'package:stager/site_state.dart';
import 'package:stager/tree/composite_node.dart';
import 'package:stager/tree/concrete_composite_node.dart';

import 'mock_node_editor.dart';
import 'mock_site_editor.dart';

class MockEditorFactory extends EditorFactory {

  late MockSiteEditor mockSiteEditor;
  late MockCompositeNodeEditor mockCompositeNodeEditor;

  MockEditorFactory(SiteState state) {
    mockSiteEditor = MockSiteEditor(state: state);
    ConcreteCompositeNode node = ConcreteCompositeNode(id: '1', name: 'Test Node');
    mockCompositeNodeEditor = MockCompositeNodeEditor(state: node);
  }

  // Bools for tracking if the editor was called
  bool _addSiteCalled = false;
  bool _editSiteCalled = false;
  bool _deleteSiteCalled = false;
  bool _addNodeCalled = false;
  bool _editNodeCalled = false;
  bool _deleteNodeCalled = false;

  /// Tracks if the addSiteEditor method was called.
  bool get addSiteCalled => _addSiteCalled;
  /// Tracks if the editSiteEditor method was called.
  bool get editSiteCalled => _editSiteCalled;
  /// Tracks if the deleteSiteEditor method was called.
  bool get deleteSiteCalled => _deleteSiteCalled;
  /// Tracks if the addNodeEditor method was called.
  bool get addNodeCalled => _addNodeCalled;
  /// Tracks if the editNodeEditor method was called.
  bool get editNodeCalled => _editNodeCalled;
  /// Tracks if the deleteNodeEditor method was called.
  bool get deleteNodeCalled => _deleteNodeCalled;

  /// Resets all the monitor bools to false.
  void reset() {
    _addSiteCalled = false;
    _editSiteCalled = false;
    _deleteSiteCalled = false;
    _addNodeCalled = false;
    _editNodeCalled = false;
    _deleteNodeCalled = false;
  }

  @override
  SiteEditor addSiteEditor(
    BuildContext context,
    SiteState state, [
    WidgetFactory widgetFactory = const BasicWidgetFactory(),
  ]) {
    _addSiteCalled = true;
    return mockSiteEditor;
  }

  @override
  StagerEditor<CompositeNode> createNodeEditor(
    BuildContext context,
    CompositeNode parent, [
    WidgetFactory widgetFactory = const BasicWidgetFactory(),
  ]) {
    _addNodeCalled = true;
    return mockCompositeNodeEditor;
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
