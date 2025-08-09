import 'package:stager/editors/basic_widget_factory.dart';
import 'package:stager/editors/site_editor.dart';
import 'package:flutter/material.dart';
import 'package:stager/editors/stager_editor.dart';
import 'package:stager/tree/composite_node.dart';

class MockCompositeNodeEditor extends StagerEditor<CompositeNode> {
  /// A predefined [Key] that can be used to find this mock widget in tests.
  static const Key mockStagerEditorKey = Key('MockStagerEditorInstance');

  /// Observer bool to track if the widget has been built.
  bool built = false;

  /// Creates an instance of [MockCompositeNodeEditor].
  ///
  /// [key]: Optional key for the widget.
  /// [widgetFactory]: The [WidgetFactory] to be used by this mock. Defaults to [BasicWidgetFactory].
  /// You can pass a real or mocked [WidgetFactory] here.
  /// [childWidget]: An optional widget that this mock's [build] method will return.
  /// Useful if you need the mock to display a specific minimal UI for testing.
  MockCompositeNodeEditor({
    super.key,
    super.widgetFactory = const BasicWidgetFactory(), required super.state, // Use the default from StagerEditor or allow override
  });

  /// Mark the observer bool as false to reset the mock.
  void reset() {
    built = false;
  }

  @override
  // ignore: library_private_types_in_public_api
  _MockStagerEditorState createState() => _MockStagerEditorState();
}

class _MockStagerEditorState extends State<MockCompositeNodeEditor> {
  @override
  Widget build(BuildContext context) {
    widget.built = true; // Set the observer flag to true
    return AlertDialog(
      key: MockCompositeNodeEditor.mockStagerEditorKey,
      title: const Text("Mock Editor Dialog"),
      content: const Text("Now you see me!"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
