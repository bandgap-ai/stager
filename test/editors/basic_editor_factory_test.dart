import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  group('BasicEditorFactory', ()
  {
    testWidgets('Should open the Add Node dialog - Happy Path', (WidgetTester tester) async {

      // Open the "Create a Node Editor"
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => factory.createNodeEditor(context,state, widgetFactory)
          ),
        ),
      );
      // Make sure to press the button! >:-D
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();




     fail("Not yet implemented.");
    });

    testWidgets('Should open the Add Node dialog - Null Selection', (WidgetTester tester) async {


      fail("Not yet implemented.");
    });

    testWidgets('Should open the Add Node dialog - Leaf Selected', (WidgetTester tester) async {


      fail("Not yet implemented.");
    });

    testWidgets('Set a custom widget factory', (WidgetTester tester) async {


      fail("Not yet implemented.");
    });
  });
}