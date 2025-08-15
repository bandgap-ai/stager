import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/editors/basic_site_controls.dart';
import 'package:stager_platform/editors/site_controls.dart';
import 'package:stager_platform/site_state.dart';
import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/concrete_composite_node.dart';
import 'mock_editor_factory.dart';

void main() {

  late CompositeNode node;
  late SiteControls siteControls;
  late MockEditorFactory editorFactory;

  setUp(() {
    SiteState state = SiteState();
    node = ConcreteCompositeNode(id: "1", name: "Test Node");
    editorFactory = MockEditorFactory(state);
    siteControls = BasicSiteControls(editorFactory);
  });

  group('BasicSiteControls', ()
  {
    testWidgets('Should build the Add Node Control', (WidgetTester tester) async {

      // Reset the editor factory just in case
      editorFactory.reset();

      // Create a minimal Material App. This is actually easier than mocking or
      // faking it and it gives us additional testing options.
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => siteControls.buildAddNodeControl(context, node),
                ),
          ),
      );
      // Make sure to press the button! >:-D
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Check the factory was called
      expect(editorFactory.addNodeCalled, isTrue);

      // Nothing else required. The dialog is thoroughly tested in its own test.
    });

    testWidgets('Should build the Edit Node Control', (WidgetTester tester) async {

      // Reset the editor factory just in case
      editorFactory.reset();

      // Create a minimal Material App. This is actually easier than mocking or
      // faking it and it gives us additional testing options.
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => siteControls.buildEditNodeControl(context, node),
          ),
        ),
      );
      // Make sure to press the button! >:-D
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Check the factory was called
      expect(editorFactory.editNodeCalled, isTrue);

      fail("Not yet implemented");
    });

  });
}