import 'package:flutter/material.dart';
import 'package:stager_platform/editors/controller.dart';
import 'package:stager_platform/editors/stager_editor.dart';
import 'package:stager_platform/tree/leaf_node.dart';
import 'package:stager_platform/tree/composite_node.dart';

/// This is a controller that creates a new child node in the parent node it
/// is configured with when created.
class EditNodeController extends Controller<LeafNode> {

  /// Creates a new EditNodeController.
  ///
  /// [state]: The CompositeNode that is the parent of the node that will be
  /// created.
  /// [editorFactory]: The editor factory to be used.
  EditNodeController(super.state, super.editorFactory);

  @override
  StagerEditor editor(BuildContext context) {
    StagerEditor editor;
    if (state.isComposite) {
      editor = editorFactory.createCompositeNodeEditor(context, state as CompositeNode);
    } else {
      editor = editorFactory.createLeafNodeEditor(context, state);
    }
    return editor;
  }

  @override
  IconData iconData() {
    return Icons.edit;
  }

  @override
  void process(Object input) {

    // FIXME: Why take an input of Object? Why not take what we actually want?

    // Prepare the input
    Map<String, Object> mapInput = input as Map<String, Object>;
    // Process the results
    state.loadPropertiesFromMap(mapInput);
    return;
  }
}
