// test/stager/site_state_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/tree/concrete_tree.dart';
import '../lib/site_state.dart';
import 'package:stager/site_state_observer.dart';
import 'package:stager/tree/tree.dart';

// A mock observer to verify notification functionality.
class MockSiteStateObserver implements SiteStateObserver {
  bool wasUpdated = false;
  SiteState? updatedState;

  @override
  void update(SiteState siteState) {
    wasUpdated = true;
    updatedState = siteState;
  }
}

void main() {
  group('SiteState', () {
    test('should initialize with the correct default label and data', () {
      final siteState = SiteState();
      expect(siteState.label, 'Sites');
      expect(siteState.treeData, isA<List<TreeNode>>());
      expect(siteState.selectedNode, isNull);
    });

    test('should attach and detach an observer', () {
      final siteState = SiteState();
      final observer = MockSiteStateObserver();

      siteState.attach(observer);
      siteState.notify();
      expect(observer.wasUpdated, isTrue);

      observer.wasUpdated = false;
      siteState.detach(observer);
      siteState.notify();
      expect(observer.wasUpdated, isFalse);
    });

    test('should notify attached observers when selectedNode changes', () {
      // Arrange
      final siteState = SiteState();
      final observer = MockSiteStateObserver();
      final testNode = ConcreteTreeNode(id: '1', name: 'Test');
      siteState.attach(observer);

      // Act
      siteState.selectedNode = testNode;

      // Assert
      expect(observer.wasUpdated, isTrue);
      expect(observer.updatedState, same(siteState));
      expect(siteState.selectedNode, same(testNode));
    });

    test('should not notify observers if selectedNode is set to the same value', () {
      // Arrange
      final siteState = SiteState();
      final observer = MockSiteStateObserver();
      final testNode = ConcreteTreeNode(id: '1', name: 'Test');
      siteState.selectedNode = testNode; // Initial selection
      siteState.attach(observer);

      // Act
      siteState.selectedNode = testNode; // Set to same node

      // Assert
      expect(observer.wasUpdated, isFalse);
    });

    test('deleteNode should remove a child node and notify observers', () {
      // Arrange
      final siteState = SiteState();
      final observer = MockSiteStateObserver();
      final parent = siteState.treeData.first as CompositeNode;
      final child = parent.children.first;
      final initialChildCount = parent.children.length;
      siteState.attach(observer);

      // Act
      siteState.deleteNode(child);

      // Assert
      expect(parent.children.length, initialChildCount - 1);
      expect(parent.children.contains(child), isFalse);
      expect(observer.wasUpdated, isTrue);
    });

    test('deleteNode should clear selection if the selected node is deleted', () {
      // Arrange
      final siteState = SiteState();
      final nodeToDelete = siteState.treeData.first;
      siteState.selectedNode = nodeToDelete;

      // Act
      siteState.deleteNode(nodeToDelete);

      // Assert
      expect(siteState.selectedNode, isNull);
    });

    test('addSite should add a new tree to treeData and notify observers', () {
      // Arrange
      final siteState = SiteState();
      final observer = MockSiteStateObserver();
      final initialTreeCount = siteState.treeData.length;
      siteState.attach(observer);

      // Act
      siteState.addSite('New Site');

      // Assert
      expect(siteState.treeData.length, initialTreeCount + 1);
      expect(siteState.treeData.last.properties.getProperty("name"), 'New Site');
      expect(observer.wasUpdated, isTrue);
    });
  });
}