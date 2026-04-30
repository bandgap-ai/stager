import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/editors/edit_node_controller.dart';
import 'package:stager_platform/editors/controller.dart';
import 'package:stager_platform/editors/editor_factory.dart';
import 'package:stager_platform/site_state.dart';
import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/concrete_composite_node.dart';
import 'mock_composite_node_observer.dart';
import 'mock_editor_factory.dart';

void main() {

  late CompositeNode parent;
  late MockEditorFactory editorFactory;
  late Controller controller;
  late MockCompositeNodeObserver observer;

  setUp(() {
    SiteState state = SiteState();

    parent = ConcreteCompositeNode(name: "Parent");
    parent.attach(observer = MockCompositeNodeObserver());
    editorFactory = MockEditorFactory(state);
    controller = EditNodeController(parent, editorFactory);
  });

  group('EditNodeController', () {
    testWidgets('Should open the Edit Node dialog', (WidgetTester tester) async {

      // Clean and check the mock editor factory
      editorFactory.reset();
      expect(editorFactory.editCompositeNodeCalled, isFalse);

      // Create a minimal Material App. This is actually easier than mocking or
      // faking it and it gives us additional testing options.
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                controller.editor(context);
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );
      // Make sure to press the button! >:-D
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // First check the factory was called
      expect(editorFactory.editCompositeNodeCalled, isTrue);
    });

    test('Should return Icons.edit', () {
      final SiteState state = SiteState();
      final EditorFactory editorFactory = MockEditorFactory(state);
      final Controller controller = EditNodeController(parent, editorFactory);
      expect(controller.iconData(), equals(Icons.edit),);
    });

    test('Should process input', () {

      // The simplest way to determine if the process method was called is to
      // see if there is now a new node in the site state. First, create some
      // results to process for a parent.node.

      // Make sure the observer has not been updated without being reset.
      expect(observer.updated, isFalse);

      // Make some new property values
      Map<String, Object> results = {
        'name': 'Updated Name',
        'value': 456,
        'is_active': false,
      };

      // Update them
      controller.process(results);

      // Get and check the properties.
      expect(parent.name, 'Updated Name');
      expect(parent.typedProperty('value').value, 456);
      expect(parent.typedProperty('is_active').value, false);
      // There should now be 4 properties
      expect(parent.toMap().length, 4);
      // Ensure that observers were notified the state changed.
      expect(observer.updated, isTrue);
      observer.reset();

      return;
    });

  });
}