import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/editors/add_node_dialog.dart';
import 'package:stager_platform/editors/basic_editor_factory.dart';
import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/concrete_composite_node.dart';
import 'mock_widget_factory.dart';

void main() {

  late CompositeNode parent;
  late BasicEditorFactory factory;
  late MockWidgetFactory widgetFactory;

  setUp(() {
    parent = ConcreteCompositeNode(id: "id", name: "name");
    factory = BasicEditorFactory();
    widgetFactory = MockWidgetFactory();
  });

  group('BasicEditorFactory', () {

    testWidgets('Should open the Add Node dialog - Happy Path', (WidgetTester tester) async {

      // Open the "Create a Node Editor"
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
              builder: (context) => factory.createNodeEditor(context, parent, widgetFactory)
          ),
        ),
      );

      // Find the parent dialog
      expect(find.byType(AddNodeDialog), findsOne);
      // Find the AlertDialog that implements the editor on the happy path
      expect(find.byType(AlertDialog), findsOne);

    });

  });
}