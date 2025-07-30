import 'package:flutter/material.dart';
import 'package:stager/editors/widget_factory.dart';
import 'package:stager/editors/basic_widget_factory.dart';
import 'package:stager/site_state.dart';

/// The Stager Editor is an abstract base class for creating editors used by
/// Stager applications. It provides two features to give developers/clients a
/// head start:
/// 1. It is a StatefulWidget.
/// 2. It has a [widgetFactory] property that can be be overridden to provide
/// a custom widget factory for widgets used in the editor.
///
/// It uses a [BasicWidgetFactory] by default, which is a simple implementation
/// that uses the [standard_widgets.dart] library to create widgets.
///
/// A StagerEditor can be anything that edits a Stager tree. For example,
/// [EditNodeDialog] is a StagerEditor that edits a single node, and
/// [SiteEditor] is a StagerEditor that edits the entire tree.
abstract class StagerEditor extends StatefulWidget {

  /// The widget factory for creating widgets used in the editor.
  final WidgetFactory widgetFactory;

  /// FIXME!
  /// 1. Should this really be a SiteEditor?
  /// 2. Should SiteEditor really be something like "SiteListEditor?"
  /// 3. Should Nodes get their own editor type instead instead of extending
  /// this class?
  /// 4. Can selectedNode functionality be moved to this class?

  /// The site state for the site being manipulated by the editor.
  final SiteState state;

  /// Creates a Stager Editor.
  /// [widgetFactory] is an optional parameter that can be overridden to provide
  /// a custom widget factory.
  const StagerEditor({super.key, required this.state, this.widgetFactory = const BasicWidgetFactory()});

}