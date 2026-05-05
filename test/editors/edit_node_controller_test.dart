import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/editors/edit_node_controller.dart';
import 'package:stager_platform/editors/controller.dart';
import 'package:stager_platform/editors/editor_factory.dart';
import 'package:stager_platform/site_state.dart';
import 'package:stager_platform/system/typed_value.dart';
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

      // Add some properties to the parent
      parent.properties.set<int>('value',456);
      parent.properties.set<bool>('is_active',false);

      // Make some new property values
      Map<String, Object> results = {
        'name': "Pearl Jam",
        'latitude': "4.0",
        'longitude': "-5.0",
        'value': "1112",
        'is_active': "true",
        'song_name': 'No Way'
      };

      // Update them
      controller.process(results);

      // Get and check the properties that were already there, but with
      // udpated values.
      expect(parent.name, "Pearl Jam");
      expect(parent.position.y, 4.0);
      expect(parent.position.x, -5.0);
      expect(parent.properties.get<int>('value'), 1112);
      expect(parent.properties.get<bool>('is_active'), isTrue);
      // Check the new property, which should be a string since it was added by
      // the UI.
      expect(parent.properties.get<String>('song_name'), 'No Way');
      print(parent.toMap());
      // There should now be 3 generic properties
      expect(parent.properties.map.length, 3);
      // Ensure that observers were notified the state changed.
      expect(observer.updated, isTrue);
      observer.reset();

      return;
    });

  });
}