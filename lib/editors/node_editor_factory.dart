/// This file defines abstract classes for editing different types of nodes
/// within the Stager tree structure.
library;

import 'package:flutter/material.dart';
import 'package:stager/editors/basic_editor_factory.dart';
import 'package:stager/site_state.dart';
import 'package:stager/editors/add_node_dialog.dart';
import 'package:stager/tree/concrete_composite_node.dart';
import 'package:stager/tree/composite_node.dart';
import 'package:stager/tree/concrete_leaf_node.dart';
import 'package:stager/tree/leaf_node.dart';
import 'package:stager/editors/message_dialog.dart';

/// This is a factory that creates a NodeEditor.
class NodeEditorFactory extends BasicEditorFactory {

  /// Creates a new NodeEditor dialog.
  ///
  /// [context]: The build context for the widget.
  /// [state]: The state manager for the Stager entity.
  Widget _showCreateNodeMenu(BuildContext context, SiteState state) {

    // Figure out wha tto show and build it.
    Widget addWidget;
    if (state.selectedNode == null) {
      // Tell the user to select a widget to edit and try again.g
      String title = "Error";
      String msg = "No node selected. "
          "Please select a site or node and try again.";
      addWidget = MessageDialog(title: title, content: msg,);
    } else if (state.selectedNode!.isComposite) {
      // Open the add node dialog
      addWidget = AddNodeDialog();
    } else {
      // Create a leaf node.
      String title = "Error";
      String msg = "Only groups can contain other objects. "
          "Please select a group and try again.";
      addWidget = MessageDialog(title: title, content: msg,);
    }

    return addWidget;
  }

  /// Does the hard work of creating a new node.
  void _createNewNode(BuildContext context, SiteState state, results) {
    LeafNode newNode;
    if (results != null) {
      String name = results['name'] as String;
      if (results['isGroup']) {
          newNode = ConcreteCompositeNode(id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
          );
      } else {
          newNode = ConcreteLeafNode(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name);
      }
      // Add the new node to the tree
      (state.selectedNode! as CompositeNode).addChild(newNode);
      state.notify();

    }
  }

  @override
  Widget create(BuildContext context, SiteState state) {

    // Make the pretty "+" button for the menu and tie in the node creation
    // functionality.
    Widget editorWidget = IconButton(icon: Icon(Icons.add, color: Theme
        .of(context)
        .colorScheme
        .onPrimary),
        onPressed: () async {
          // Show the dialog.
          //
          // This should be inside an editor widget to eliminate the assumption
          // that pressing the button will open a dialog. What if we wanted to
          // open something else?
          //
          final results = await showDialog(
            context: context,
            builder: (context) => _showCreateNodeMenu(context,state),
          );
          // Build the new node
          if (context.mounted) {
            _createNewNode(context, state, results);
          }
        });

    return editorWidget;
  }

  @override
  Widget delete(BuildContext context, SiteState state) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Widget update(BuildContext context, SiteState state) {
    // TODO: implement update
    throw UnimplementedError();
  }

}