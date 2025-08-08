import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/editors/add_node_dialog.dart';
import 'package:stager/editors/basic_editor_factory.dart';
import 'package:stager/editors/basic_site_controls.dart';
import 'package:stager/editors/site_controls.dart';
import 'package:stager/site_state.dart';
import 'mock_editor_factory.dart';
import 'mock_widget_factory.dart';

void main() {

  late SiteState state;
  late BasicEditorFactory factory;
  late MockWidgetFactory widgetFactory;

  setUp(() {
    state = SiteState();
    factory = BasicEditorFactory();
    widgetFactory = MockWidgetFactory();
  });

  group('BasicEditorFactory', () {

    testWidgets('Should open the Add Node dialog - Happy Path', (WidgetTester tester) async {

      // Open the "Create a Node Editor"
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
              builder: (context) => factory.createNodeEditor(context,state, widgetFactory)
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