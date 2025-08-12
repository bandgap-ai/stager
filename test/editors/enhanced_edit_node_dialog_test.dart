import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/tree/concrete_composite_node.dart';
import 'package:stager_platform/tree/concrete_leaf_node.dart';
import 'package:stager_platform/tree/concrete_node_properties.dart';
import 'package:stager_platform/editors/enhanced_edit_node_dialog.dart';

void main() {
  group('EnhancedEditNodeDialog Widget Tests', () {
    late ConcreteNodeProperties properties;
    late ConcreteLeafNode node;
    late ConcreteCompositeNode rootNode;

    setUp(() {
      properties = ConcreteNodeProperties();
      properties.setProperty('name', 'Test Node');
      properties.setProperty('latitude', 40.7128);
      properties.setProperty('longitude', -74.0060);
      
      // Create a tree structure for testing level determination
      rootNode = ConcreteCompositeNode(
        id: 'root-id',
        name: 'Root',
      );
      
      node = ConcreteLeafNode(
        id: 'node-id',
        name: 'Test Node',
        initialProperties: {
          'latitude': 40.7128,
          'longitude': -74.0060,
        },
      );
      rootNode.addChild(node);
    });


    testWidgets('should not show outline area editor for non-level 1 node', (tester) async {
      // Create a deeper node structure (level 2)
      final level1Node = ConcreteCompositeNode(
        id: 'level1-id',
        name: 'Level 1 Node',
      );
      rootNode.addChild(level1Node);
      
      final level2Node = ConcreteLeafNode(
        id: 'level2-id',
        name: 'Level 2 Node',
      );
      level1Node.addChild(level2Node);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => EnhancedEditNodeDialog(
                    properties: level2Node.properties,
                    node: level2Node,
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify outline area editor is not shown
      expect(find.text('Edit Node'), findsOneWidget);
      expect(find.text('Outline Area:'), findsNothing);
    });



  });
}
