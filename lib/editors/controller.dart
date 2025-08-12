import 'package:flutter/material.dart';
import 'package:stager/editors/stager_editor.dart';
import 'package:stager/editors/editor_factory.dart';

/// This is a simple interface to centralize the control logic for processing
/// state updates gathered from editors. It is implemented for each type of
/// edit control/function.
///
/// EditorFactories are injected for customization and testing, and state types
/// are templated. It's a "choose your own adventure" kind of interface...
abstract class Controller<T> {

  /// The editor factory used to create the editor.
  final EditorFactory editorFactory;

  /// The controller state.
  final T state;

  /// Creates a new controller.
  ///
  /// [state]: The controller state.
  /// [editorFactory]: The editor factory used to create the editor.
  Controller(this.state, this.editorFactory);

  /// Processes changes to the state in response to an input.
  ///
  /// [input]: The input to be processed to change the state.
  void process(Object input);

  /// Returns the icon data that should be used for the control button.
  IconData iconData();

  /// Returns the editor that can perform the intended function.
  ///
  /// [context]: The build context.
  StagerEditor editor(BuildContext context);

}