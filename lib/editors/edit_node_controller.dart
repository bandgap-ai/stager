import 'package:flutter/material.dart';
import '../editors/controller.dart';
import '../editors/stager_editor.dart';
import '../system/stager_context.dart';
import '../system/typed_value.dart';
import '../tree/leaf_node.dart';
import '../tree/composite_node.dart';
import '../system/point.dart';

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
  void process(Map<String, Object> input) {

    // Pull name for a manual update
    if (input.containsKey("name")) {
      state.name = input.remove("name")! as String;
    }

    // Pull latitude and longitude to rebuild the position, if they are there
    if (input.containsKey("latitude") && input.containsKey("longitude")) {
      final longitude = double.parse(input.remove("longitude")! as String);
      final latitude = double.parse(input.remove("latitude")! as String);
      state.position = Point(coords: [longitude, latitude]);
    }

    // If id is present, remove it. (Really shouldn't be there anyway...)
    input.remove("id");

    // For all other values, convert them to TypedValues since we don't actually
    // know what they are.
    //
    // It really would nice to have a fucking "fromTupleOrDefault()" function.
    final properties = state.properties;
    for (final mapEntry in input.entries) {
      // If the property is already on the node, then use its type information
      // to create an update. If the property isn't already on the node, then
      // create a TypedValue<String> for it. This uses the tuple representation
      // of TypedValue for deserialization.
      List<Object> tuple = [];
      Type type = properties.contains(mapEntry.key)
          ? properties.map[mapEntry.key]!.type : String;
      // Load the new value
      tuple = [type, mapEntry.value];
      input.update(mapEntry.key, (value) => tuple);
    }

    // Process the results
    state.fromMap(input);
    return;
  }
}
