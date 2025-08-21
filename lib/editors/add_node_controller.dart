import 'package:flutter/material.dart';
import 'package:stager_platform/editors/controller.dart';
import 'package:stager_platform/editors/stager_editor.dart';
import 'package:stager_platform/tree/leaf_node.dart';
import 'package:stager_platform/tree/composite_node.dart';
import 'package:uuid/uuid.dart';
import 'package:stager_platform/tree/node_builder.dart';
import 'package:stager_platform/tree/basic_node_builder.dart';

/// This is a controller that creates a new child node in the parent node it
/// is configured with when created.
class AddNodeController extends Controller<CompositeNode> {

  /// Node builder injected for building new nodes
  final NodeBuilder nodeBuilder;

  /// Creates a new AddNodeController.
  ///
  /// [state]: The CompositeNode that is the parent of the node that will be
  /// created.
  /// [editorFactory]: The editor factory to be used.
  /// [nodeBuilder]: The node builder to be used. Defaults to a
  /// [BasicNodeBuilder].
  AddNodeController(super.state, super.editorFactory, [this.nodeBuilder = const BasicNodeBuilder()]);

  @override
  StagerEditor editor(BuildContext context) {
    return editorFactory.createNodeBuilder(context, state);
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
      newNode = nodeBuilder.buildCompositeNode(id, name);
    } else {
      newNode = nodeBuilder.buildLeafNode(id, name);
    }
    // Add the new node to the tree
    state.addChild(newNode);
    // Let the watchers know
    state.notify();
  }
}
