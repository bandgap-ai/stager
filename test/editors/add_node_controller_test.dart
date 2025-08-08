import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/editors/add_node_controller.dart';
import 'package:stager/editors/controller.dart';
import 'package:stager/editors/editor_factory.dart';
import 'package:stager/editors/site_editor.dart';
import 'package:stager/site_state.dart';
import 'package:stager/tree/composite_node.dart';
import 'package:stager/tree/tree_node.dart';
import 'package:uuid/uuid.dart';
import 'mock_editor_factory.dart';
import 'mock_site_state_observer.dart';

void main() {

  late SiteState state;
  late MockEditorFactory editorFactory;
  late Controller controller;
  late MockObserver observer;

  setUp(() {
    state = SiteState();
    TreeNode root = state.addSite('Test Site');
    state.selectedNode = root;
    state.attach(observer = MockObserver());
    editorFactory = MockEditorFactory(state);
    controller = AddNodeController(state, editorFactory);
  });

  group('AddNodeController', () {
    testWidgets('Should open the Add Node dialog', (WidgetTester tester) async {

      // Clean and check the mock editor factory
      editorFactory.reset();
      expect(editorFactory.addNodeCalled, isFalse);

      // Create a minimal Material App. This is actually easier than mocking or
      // faking it and it gives us additional testing options.
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                SiteEditor editor = controller.editor(context);
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
      expect(editorFactory.addNodeCalled, isTrue);
    });

    test('Should return Icons.add', () {
      final SiteState state = SiteState();
      final EditorFactory editorFactory = MockEditorFactory(state);
      final Controller controller = AddNodeController(state, editorFactory);
      expect(controller.iconData(), equals(Icons.add),);
    });

    test('Should process input', () {

      // The simplest way to determine if the process method was called is to
      // see if there is now a new node in the site state. First, create some
      // results to process for a Leaf node.

      // Make sure the observer has not been updated without being reset.
      expect(observer.updated, isFalse);

      // Check adding a leaf node.
      String name = 'Test Leaf Node';
      Map<String, Object> results = {'name': name, 'isGroup': false};
      controller.process(results);
      expect((state.selectedNode! as CompositeNode).children.length, equals(1));
      expect((state.selectedNode! as CompositeNode).children[0].properties.getProperty('name') as String, equals(name));
      expect(() => Uuid.parse((state.selectedNode! as CompositeNode).children[0].properties.getProperty('id') as String), returnsNormally);
      // Make sure it was observed and reset the observer.
      expect(observer.updated, isTrue);
      observer.reset();

      // Check adding a composite node.
      name = 'Test Composite Node';
      results = {'name': name, 'isGroup': true};
      controller.process(results);
      expect((state.selectedNode! as CompositeNode).children.length, equals(2));
      expect((state.selectedNode! as CompositeNode).children[1].properties.getProperty('name') as String, equals(name));
      expect(() => Uuid.parse((state.selectedNode! as CompositeNode).children[1].properties.getProperty('id') as String), returnsNormally);
      // Make sure it was observed and reset the observer.
      expect(observer.updated, isTrue);
      observer.reset();

      return;
    });

  });
}