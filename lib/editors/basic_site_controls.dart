import 'package:stager/editors/site_controls.dart';
import 'package:stager/editors/dialog_control_button.dart';
import 'package:stager/site_state.dart';
import 'package:flutter/material.dart';
import 'package:stager/editors/add_node_controller.dart';
import 'package:stager/editors/controller.dart';
import 'package:stager/editors/basic_editor_factory.dart';
import 'package:stager/editors/editor_factory.dart';

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
  DialogControlButton buildAddNodeControl(BuildContext context, SiteState state) {
    Controller controller = AddNodeController(state, editorFactory);
    return DialogControlButton(controller: controller, state: state);
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