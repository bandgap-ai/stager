import 'package:flutter/src/widgets/icon.dart';
import 'package:stager/editors/site_controls.dart';
import 'package:stager/editors/dialog_control_button.dart';
import 'package:stager/editors/stager_editor.dart';

/// This is a basic implementation of the Site Controls interface to create
/// simple button icons to control what editors are launched.
class BasicSiteControls extends SiteControls {
  @override
  DialogControlButton addNode(Icon icon, StagerEditor editor) {
    // TODO: implement addNode
    throw UnimplementedError();
  }

  @override
  DialogControlButton addSite(Icon icon, StagerEditor editor) {
    // TODO: implement addSite
    throw UnimplementedError();
  }

  @override
  DialogControlButton deleteNode(Icon icon, StagerEditor editor) {
    // TODO: implement deleteNode
    throw UnimplementedError();
  }

  @override
  DialogControlButton deleteSite(Icon icon, StagerEditor editor) {
    // TODO: implement deleteSite
    throw UnimplementedError();
  }

  @override
  DialogControlButton editNode(Icon icon, StagerEditor editor) {
    // TODO: implement editNode
    throw UnimplementedError();
  }

  @override
  DialogControlButton editSite(Icon icon, StagerEditor editor) {
    // TODO: implement editSite
    throw UnimplementedError();
  }
  
}