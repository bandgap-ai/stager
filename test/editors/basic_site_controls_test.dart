import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/editors/basic_site_controls.dart';
import 'package:stager/editors/message_dialog.dart';
import 'package:stager/editors/site_controls.dart';
import 'package:stager/site_state.dart';
import 'package:stager/tree/composite_node.dart';
import 'package:stager/tree/concrete_composite_node.dart';
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

    testWidgets('Should show message dialog when selected node is null', (WidgetTester tester) async {

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

      // First check the factory was NOT called
      expect(editorFactory.addNodeCalled, isFalse);

      // Verify the error dialog is visible.
      expect(find.byType(MessageDialog), findsOneWidget);
      expect(find.text("No node selected. "
          "Please select a site or node and try again."), findsOneWidget);

      return;
    });

    testWidgets('Should show error message when leaf node is selected', (WidgetTester tester) async {

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

      // First check the factory was NOT called
      expect(editorFactory.addNodeCalled, isFalse);

      // Verify the error dialog is visible.
      expect(find.byType(MessageDialog), findsOneWidget);
      expect(find.text("Only groups can contain other objects. "
          "Please select a group and try again."), findsOneWidget);

      return;
    });

  });
}