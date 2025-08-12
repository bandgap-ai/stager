import 'package:stager_platform/editors/site_controls.dart';
import 'package:stager_platform/editors/dialog_control_button.dart';
import 'package:stager_platform/site_state.dart';
import 'package:flutter/material.dart';
import 'package:stager_platform/editors/add_node_controller.dart';
import 'package:stager_platform/editors/controller.dart';
import 'package:stager_platform/editors/basic_editor_factory.dart';
import 'package:stager_platform/editors/editor_factory.dart';
import 'package:stager_platform/tree/composite_node.dart';

/// This is a basic implementation of the Site Controls interface to create
/// simple button icons to control what editors are launched.
class BasicSiteControls extends SiteControls {

  final EditorFactory editorFactory;

  /// Constructor for the SiteControls class.
  ///
  /// [editorFactory]: An optional editor factory for the editor to use. The
  /// default is a [BasicEditorFactory].
  const BasicSiteControls([this.editorFactory = const BasicEditorFactory()]);

  @override
  DialogControlButton buildAddNodeControl(BuildContext context, CompositeNode parent) {
    Controller controller = AddNodeController(parent, editorFactory);
    return DialogControlButton(controller: controller);
  }

  @override
  DialogControlButton buildAddSiteControl(BuildContext context, SiteState state) {
    // TODO: implement buildAddSiteControl
    throw UnimplementedError();
  }

  @override
  DialogControlButton buildDeleteNodeControl(BuildContext context, SiteState state) {
    // TODO: implement buildDeleteNodeControl
    throw UnimplementedError();
  }

  @override
  DialogControlButton buildDeleteSiteControl(BuildContext context, SiteState state) {
    // TODO: implement buildDeleteSiteControl
    throw UnimplementedError();
  }

  @override
  DialogControlButton buildEditNodeControl(BuildContext context, SiteState state) {
    // TODO: implement buildEditNodeControl
    throw UnimplementedError();
  }

  @override
  DialogControlButton buildEditSiteControl(BuildContext context, SiteState state) {
    // TODO: implement buildEditSiteControl
    throw UnimplementedError();
  }

  
}