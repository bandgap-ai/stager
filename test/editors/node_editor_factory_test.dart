import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/editors/node_editor_factory.dart';
import 'package:stager/site_state.dart';
import 'package:stager/tree/concrete_composite_node.dart';
import 'package:stager/tree/concrete_leaf_node.dart';
import 'package:stager/editors/message_dialog.dart';
import 'package:stager/editors/add_node_dialog.dart';

void main() {
  group('NodeEditorFactory Tests', () {
    late NodeEditorFactory factory;
    late SiteState siteState;

    setUp(() {
      factory = NodeEditorFactory();
      siteState = SiteState();
    });

    testWidgets('should show error dialog when no node is selected', (tester) async {
      // Clear the selected node
      siteState.selectedNode = null;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return factory.create(context, siteState);
              },
            ),
          ),
        ),
      );

      // Tap the button to trigger node creation
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should show error dialog
      expect(find.byType(MessageDialog), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('No node selected. Please select a site or node and try again.'), findsOneWidget);
    });

    testWidgets('should show add node dialog when composite node is selected', (tester) async {
      // Create and select a composite node
      final compositeNode = ConcreteCompositeNode(
        id: 'comp-id',
        name: 'Composite Node',
      );
      siteState.selectedNode = compositeNode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return factory.create(context, siteState);
              },
            ),
          ),
        ),
      );

      // Tap the button to trigger node creation
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should show add node dialog
      expect(find.byType(AddNodeDialog), findsOneWidget);
    });

    testWidgets('should show error dialog when leaf node is selected', (tester) async {
      // Create and select a leaf node
      final leafNode = ConcreteLeafNode(
        id: 'leaf-id',
        name: 'Leaf Node',
      );
      siteState.selectedNode = leafNode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return factory.create(context, siteState);
              },
            ),
          ),
        ),
      );

      // Tap the button to trigger node creation
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should show error dialog
      expect(find.byType(MessageDialog), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Only groups can contain other objects. Please select a group and try again.'), findsOneWidget);
    });

    testWidgets('should create composite node when group checkbox is checked', (tester) async {
      // Create and select a composite node
      final compositeNode = ConcreteCompositeNode(
        id: 'comp-id',
        name: 'Composite Node',
      );
      siteState.selectedNode = compositeNode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return factory.create(context, siteState);
              },
            ),
          ),
        ),
      );

      // Tap the button to trigger node creation
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should show add node dialog
      expect(find.byType(AddNodeDialog), findsOneWidget);
      
      // Enter node name
      await tester.enterText(find.byType(TextField), 'New Group');
      
      // Check the group checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Tap Add button
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify a new composite node was added
      expect(compositeNode.children.length, 1);
      expect(compositeNode.children.first.properties.getProperty('name'), 'New Group');
      expect(compositeNode.children.first.isComposite, true);
    });

    testWidgets('should create leaf node when group checkbox is not checked', (tester) async {
      // Create and select a composite node
      final compositeNode = ConcreteCompositeNode(
        id: 'comp-id',
        name: 'Composite Node',
      );
      siteState.selectedNode = compositeNode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return factory.create(context, siteState);
              },
            ),
          ),
        ),
      );

      // Tap the button to trigger node creation
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should show add node dialog
      expect(find.byType(AddNodeDialog), findsOneWidget);
      
      // Enter node name
      await tester.enterText(find.byType(TextField), 'New Node');
      
      // Don't check the group checkbox (should be unchecked by default)

      // Tap Add button
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify a new leaf node was added
      expect(compositeNode.children.length, 1);
      expect(compositeNode.children.first.properties.getProperty('name'), 'New Node');
      expect(compositeNode.children.first.isComposite, false);
    });
  });
}
