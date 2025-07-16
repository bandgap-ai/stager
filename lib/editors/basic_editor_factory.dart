/// This file defines abstract classes for editing different types of nodes
/// within the Stager tree structure.
library;

import 'package:flutter/material.dart';
import 'package:stager/site_state.dart';

/// This is an abstract factory class definition for creating editors.
abstract class BasicEditorFactory {

  /// Build a widget that can create a Stager entity.
  ///
  /// [context]: The build context for the widget.
  /// [state]: The state manager for the Stager entity.
  Widget create(BuildContext context, SiteState state);

  /// Build a widget that allows a Stager entity to be edited.
  ///
  /// [context]: The build context for the widget.
  /// [state]: The state manager for the Stager entity.
  Widget update(BuildContext context, SiteState state);

  /// Build a widget that can delete a Stager entity.
  ///
  /// [context]: The build context for the widget.
  /// [state]: The state manager for the Stager entity.
  Widget delete(BuildContext context, SiteState state);

}