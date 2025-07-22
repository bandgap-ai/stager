import 'package:flutter/cupertino.dart';
import 'package:stager/editors/dialog_control_button.dart';
import 'package:stager/editors/stager_editor.dart';

/// This is a factory interface for managing controls used to create editors
/// in the Site Editor.
abstract class SiteControls {

  /// Creates a [DialogControlButton] for adding a new node.
  ///
  /// [icon]: The icon to display for this control.
  /// [editor]: The editor launched by this control to add a new node.
  DialogControlButton addNode(Icon icon, StagerEditor editor);

  /// Creates a [DialogControlButton] for editing an existing node.
  ///
  /// [icon]: The icon to display for this control.
  /// [editor]: The editor launched by this control to edit an existing node.
  DialogControlButton editNode(Icon icon, StagerEditor editor);

  /// Creates a [DialogControlButton] for deleting a node.
  ///
  /// [icon]: The icon to display for this control.
  /// [editor]: The editor launched by this control to delete a node.
  DialogControlButton deleteNode(Icon icon, StagerEditor editor);

  /// Creates a [DialogControlButton] for adding a new site.
  ///
  /// [icon]: The icon to display for this control.
  /// [editor]: The editor launched by this control to add a new site.
  DialogControlButton addSite(Icon icon, StagerEditor editor);

  /// Creates a [DialogControlButton] for editing an existing site.
  ///
  /// [icon]: The icon to display for this control.
  /// [editor]: The editor launched by this control to edit an existing site.
  DialogControlButton editSite(Icon icon, StagerEditor editor);

  /// Creates a [DialogControlButton] for deleting a site.
  ///
  /// [icon]: The icon to display for this control.
  /// [editor]: The editor launched by this control to delete a site.
  DialogControlButton deleteSite(Icon icon, StagerEditor editor);
}