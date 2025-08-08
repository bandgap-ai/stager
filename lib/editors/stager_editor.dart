import 'package:flutter/material.dart';
import 'package:stager/editors/widget_factory.dart';
import 'package:stager/editors/basic_widget_factory.dart';

/// This is an abstract base class for editors in Stager. It reduces the
/// Dart boilerplate code required to create a new typed editor widget with a
/// widget factory and a state.
abstract class StagerEditor<T> extends StatefulWidget {

  /// The widget factory for creating widgets used in the editor.
  final WidgetFactory widgetFactory;

  /// The state for the editor.
  final T state;

  /// Creates a StagerEditor.
  /// [state] is the site state for the site being manipulated by the editor.
  /// [widgetFactory] is an optional parameter that can be overridden to provide
  /// a custom widget factory.
  const StagerEditor({super.key, required this.state, this.widgetFactory = const BasicWidgetFactory()});
}