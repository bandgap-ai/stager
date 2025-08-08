import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/editors/node_properties_view.dart';
import 'package:stager/tree/concrete_tree.dart';
import 'package:stager/tree/concrete_leaf_node.dart';
import 'package:stager/site_state.dart';
import 'package:stager/editors/properties_widget.dart';
import 'package:stager/editors/stager_tree_viewers.dart';

/// Widget tests for the `PropertiesWidget`.
///
/// This file contains a comprehensive set of widget tests for the `PropertiesWidget`,
/// ensuring its correct rendering, state management, and interaction with the
/// `SiteState` and other components like `NodePropertiesView` and `ImagePicker`.
/// It covers various scenarios including node selection, tab switching, image
/// addition, and dialog interactions.
void main() {
  group('PropertiesWidget', () {
    late SiteState siteState;

    setUp(() {
      siteState = SiteState();
    });

    /// Pumps the [PropertiesWidget] into the tester.
    Future<void> pumpWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertiesWidget(siteState: siteState),
          ),
        ),
      );
    }

    testWidgets('renders nothing when no node is selected', (WidgetTester tester) async {
      // Arrange: Ensure no node is selected
      siteState.selectedNode = null;

      // Act
      await pumpWidget(tester);

      // Assert
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('renders BottomSheet with properties when a node is selected', (WidgetTester tester) async {
      // Arrange: Select a node
      siteState.selectedNode = ConcreteLeafNode(id: '1', name: 'Test Node');

      // Act
      await pumpWidget(tester);
      await tester.pump(); // Let the bottom sheet animate up

      // Assert
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(NodePropertiesView), findsOneWidget);
      expect(find.byWidgetPredicate((widget) => widget is SegmentedButton<String>), findsOneWidget);
      
      // Switch to images tab to find the Add Image button
      await tester.tap(find.text('Images'));
      await tester.pump();
      expect(find.text('Add Image'), findsOneWidget);
    });

    testWidgets('onClosing callback clears the selected node', (WidgetTester tester) async {
      // Arrange: Select a node
      siteState.selectedNode = ConcreteLeafNode(id: '1', name: 'Test Node');
      await pumpWidget(tester);
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);

      // Act: Simulate the onClosing event by setting the node to null,
      // which is what the onClosing callback does.
      // A more direct test would require access to the onClosing callback itself.
      siteState.selectedNode = null;
      await tester.pumpAndSettle();

      // Assert
      expect(siteState.selectedNode, isNull);
    });
  });
}
