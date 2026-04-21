import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/editors/composite_node_editor.dart';
import 'package:stager_platform/editors/leaf_node_editor.dart';
import 'package:stager_platform/tree/tree.dart';

void main() {
  late ConcreteCompositeNode node;
  late NodeProperties testProperties;

  setUp(() {
    node = ConcreteCompositeNode(id: 'test_id', name: 'Test Node');
    testProperties = node.properties;
  });

  group('CompositeNodeEditor Tests', () {
    /// Tests that the CompositeNodeEditor delegates to the LeafNodeEditor since
    /// Stager does not yet define any special graphical behavior for composite
    /// nodes.
    testWidgets('CompositeNodeEditor delegates to LeafNodeEditor', (WidgetTester tester) async {
      testProperties.set('name', 'Test Node');
      testProperties.set('description', 'Some description');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CompositeNodeEditor(state:node),
        ),
      ));
      expect(find.byType(LeafNodeEditor), findsOneWidget);
    });
    
  });
}
