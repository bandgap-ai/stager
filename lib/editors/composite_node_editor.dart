import 'package:flutter/material.dart';
import 'package:stager_platform/editors/stager_editor.dart';
import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/editors/leaf_node_editor.dart';

/// This is an editor for composite nodes. Since Stager does not yet define any
/// special graphical user interface for composite nodes, this editor simply
/// delegates to the LeafNodeEditor.
class CompositeNodeEditor extends StagerEditor<CompositeNode> {

  /// Creates a [CompositeNodeEditor] widget.
  ///
  /// [state]: The composite node to be edited.
  /// [widgetFactory]: An optional widget factory for the editor to use.
  const CompositeNodeEditor({super.key, required super.state});

  @override
  State<CompositeNodeEditor> createState() => _CompositeNodeEditorState();

}

/// The state for the [CompositeNodeEditor] widget.
class _CompositeNodeEditorState extends State<CompositeNodeEditor> {
  @override
  Widget build(BuildContext context) {
    return LeafNodeEditor(state: widget.state);
  }
}
