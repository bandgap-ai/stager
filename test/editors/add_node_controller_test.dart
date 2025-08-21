import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/editors/add_node_controller.dart';
import 'package:stager_platform/editors/controller.dart';
import 'package:stager_platform/editors/editor_factory.dart';
import 'package:stager_platform/site_state.dart';
import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/concrete_composite_node.dart';
import 'package:uuid/uuid.dart';
import 'mock_composite_node_observer.dart';
import 'mock_editor_factory.dart';
import 'mock_node_builder.dart';

void main() {

  late CompositeNode parent;
  late MockEditorFactory editorFactory;
  late Controller controller;
  late MockCompositeNodeObserver observer;

  setUp(() {
    SiteState state = SiteState();

    parent = ConcreteCompositeNode(id: "1", name: "Parent");
    parent.attach(observer = MockCompositeNodeObserver());
    editorFactory = MockEditorFactory(state);
    controller = AddNodeController(parent, editorFactory);
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
      expect(editorFactory.addNodeCalled, isTrue);
    });

    test('Should return Icons.add', () {
      final SiteState state = SiteState();
      final EditorFactory editorFactory = MockEditorFactory(state);
      final Controller controller = AddNodeController(parent, editorFactory);
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
      expect(parent.children.length, equals(1));
      expect(parent.children[0].properties.getProperty('name') as String, equals(name));
      expect(() => Uuid.parse(parent.children[0].properties.getProperty('id') as String), returnsNormally);
      // Make sure it was observed and reset the observer.
      expect(observer.updated, isTrue);
      observer.reset();

      // Check adding a composite node.
      name = 'Test Composite Node';
      results = {'name': name, 'isGroup': true};
      controller.process(results);
      expect(parent.children.length, equals(2));
      expect(parent.children[1].properties.getProperty('name') as String, equals(name));
      expect(() => Uuid.parse(parent.children[1].properties.getProperty('id') as String), returnsNormally);
      // Make sure it was observed and reset the observer.
      expect(observer.updated, isTrue);
      observer.reset();

      return;
    });

    test('Should process input with mock builder', () {

      CompositeNode customParent = ConcreteCompositeNode(id: "1", name: "Parent");
      Controller customController = AddNodeController(customParent, editorFactory, MockNodeBuilder());

      // Check adding a leaf node.
      String name = 'Test Mock Leaf Node';
      Map<String, Object> results = {'name': name, 'isGroup': false};
      customController.process(results);
      expect(customParent.children[0].properties.getProperty('isMock'),isFalse);

      // Check adding a composite node.
      name = 'Test Mock Composite Node';
      results = {'name': name, 'isGroup': true};
      customController.process(results);
      expect(customParent.children[1].properties.getProperty('isMock'),isTrue);

      return;
    });

  });
}