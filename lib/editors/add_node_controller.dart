import 'package:flutter/material.dart';
import 'package:stager/editors/controller.dart';
import 'package:stager/editors/site_editor.dart';
import 'package:stager/tree/leaf_node.dart';
import 'package:stager/tree/composite_node.dart';
import 'package:stager/tree/concrete_leaf_node.dart';
import 'package:stager/tree/concrete_composite_node.dart';
import 'package:uuid/uuid.dart';

/// This is a controller that creates a new node in the site state.
class AddNodeController extends Controller<CompositeNode> {
  AddNodeController(super.state, super.editorFactory);

  @override
  SiteEditor editor(BuildContext context) {
    return editorFactory.createNodeEditor(context, state);
  }

  @override
  IconData iconData() {
    return Icons.add;
  }

  @override
  void process(Object input) {
    LeafNode newNode;
    // Prepare the input
    Map<String, dynamic> mapInput = input as Map<String, dynamic>;
    String name = mapInput['name'] as String;
    // Create the ID
    var uuid = Uuid();
    String id = uuid.v7();
    if (mapInput['isGroup'] as bool) {
      newNode = ConcreteCompositeNode(id: id, name: name);
    } else {
      newNode = ConcreteLeafNode(id: id, name: name);
    }
    // Add the new node to the tree
    state.addChild(newNode);
    // FIXME - I think the state should register as a listener of all nodes
    // and, thus, notify whenever the tree changes without explicitly calling it
    // like this.
    state.notify();
  }
}
