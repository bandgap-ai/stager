import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/editors/composite_node_editor.dart';
import 'package:stager_platform/editors/leaf_node_editor.dart';
import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/tree/tree.dart';

void main() {
  late ConcreteCompositeNode node;

  setUp(() {
    node = ConcreteCompositeNode(name: 'Test Node');
  });

  group('CompositeNodeEditor Tests', () {
    /// Tests that the CompositeNodeEditor delegates to the LeafNodeEditor since
    /// Stager does not yet define any special graphical behavior for composite
    /// nodes.
    testWidgets('CompositeNodeEditor delegates to LeafNodeEditor', (WidgetTester tester) async {
      node.name = 'Test Node';
      node.setProperty('description', TypedValue<String>('Some description'));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CompositeNodeEditor(state:node),
        ),
      ));
      expect(find.byType(LeafNodeEditor), findsOneWidget);
    });
    
  });
}
