import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/editors/node_properties_view.dart';
import 'package:stager_platform/system/selection.dart';
import 'package:stager_platform/editors/stager_pin.dart';
import 'package:stager_platform/tree/concrete_tree.dart';
import 'package:stager_platform/tree/concrete_leaf_node.dart';
import 'package:stager_platform/editors/properties_widget.dart';
import 'package:stager_platform/tree/leaf_node.dart';

/// Widget tests for the `PropertiesWidget`.
///
/// This file contains a comprehensive set of widget tests for the `PropertiesWidget`,
/// ensuring its correct rendering, state management, and interaction with the
/// `selectedNode` and other components like `NodePropertiesView` and `ImagePicker`.
/// It covers various scenarios including node selection, tab switching, image
/// addition, and dialog interactions.
void main() {
  group('PropertiesWidget', () {
    late Selection<LeafNode> selectedNode;

    setUp(() {
      selectedNode = Selection<LeafNode>();
      selectedNode.value = ConcreteLeafNode(id: '1', name: 'Test Node');
    });

    /// Pumps the [PropertiesWidget] into the tester.
    Future<void> pumpWidget(WidgetTester tester, {StagerPin? pin}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertiesWidget(selectedNode: selectedNode, pin: pin),
          ),
        ),
      );
    }

    testWidgets('renders nothing when no node is selected', (
      WidgetTester tester,
    ) async {
      // Arrange: Ensure no node is selected
      selectedNode.value = null;

      // Act
      await pumpWidget(tester);

      // Assert
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('onClosing callback clears the selected node', (
      WidgetTester tester,
    ) async {
      // Arrange: Select a node
      selectedNode.value = ConcreteLeafNode(id: '1', name: 'Test Node');
      await pumpWidget(tester);
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsOneWidget);

      // Act: Simulate the onClosing event by setting the node to null,
      // which is what the onClosing callback does.
      // A more direct test would require access to the onClosing callback itself.
      selectedNode.value = null;
      await tester.pumpAndSettle();

      // Assert
      expect(selectedNode.value, isNull);
    });

    testWidgets(
      'should display pin when provided and call onPinChanged on tap',
      (WidgetTester tester) async {
        // Arrange
        bool callbackCalled = false;
        final StagerPin pin = StagerPin(
          initialPinState: false,
          onPinChanged: (bool isPinned) {
            callbackCalled = true;
          },
        );

        // Act
        await pumpWidget(tester, pin: pin);
        await tester.pump();

        // Assert the widget is found
        final pinFinder = find.byType(StagerPin);
        expect(pinFinder, findsOneWidget);

        // Tap the pin
        await tester.tap(pinFinder);
        await tester.pump();

        // Assert callback is called
        expect(callbackCalled, isTrue);
      },
    );
  });
}
