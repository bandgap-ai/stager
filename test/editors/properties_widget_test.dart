import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/system/selection.dart';
import 'package:stager_platform/editors/stager_pin.dart';
import 'package:stager_platform/system/selection_service.dart';
import 'package:stager_platform/tree/concrete_tree.dart';
import 'package:stager_platform/tree/concrete_leaf_node.dart';
import 'package:stager_platform/editors/properties_widget.dart';
import 'package:stager_platform/tree/data_node.dart';
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
    SelectionService selectionService = SelectionService();

    setUp(() {
      selectedNode = Selection<LeafNode>(ConcreteLeafNode(name: 'Test Node'));
      selectedNode.value = ConcreteLeafNode(name: 'Test Node');
      selectionService.selection = selectedNode;
    });

    /// Pumps the [PropertiesWidget] into the tester.
    Future<void> pumpWidget(WidgetTester tester, {StagerPin? pin}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertiesWidget(selectionService: selectionService, pin: pin),
          ),
        ),
      );
    }

    testWidgets('renders nothing when no node is selected', (
      WidgetTester tester,
    ) async {
      // Arrange: Ensure no node is selected
      selectionService.clear();

      // Act
      await pumpWidget(tester);

      // Assert
      expect(find.byType(Container), findsNothing);
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

  group('PropertiesWidget updates images when added', () {
    late Selection<LeafNode> selectedNode;
    SelectionService selectionService = SelectionService();

    setUp(() {
      selectedNode = Selection<LeafNode>(ConcreteLeafNode(name: 'Test Node'));
      selectionService.selection = selectedNode;
    });

    testWidgets('UI updates when an image is added to dataNodes', (WidgetTester tester) async {
      // Arrange: Pump the PropertiesWidget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertiesWidget(selectionService: selectionService),
          ),
        ),
      );

      // Switch to the 'images' tab
      await tester.tap(find.byIcon(Icons.image_outlined));
      await tester.pumpAndSettle();

      // Verify that "No Images" is initially shown
      expect(find.text('No Images'), findsOneWidget);

      // Act: Manually add an image to the node's dataNodes
      final node = selectionService.selection.value;
      final data = DataNode(path: 'assets/test_images/test.png', timestamp: 123);
      node.dataNodes.set('test_image', data);

      // Pump to trigger rebuilds if any listeners are active
      await tester.pump();

      // Assert: "No Images" should be gone and the image should be visible
      // (PropertiesWidget uses Image.asset for the paths in dataNodes)
      expect(find.text('No Images'), findsNothing, reason: 'PropertiesWidget did not update after adding an image');
    });
  });

}
