import 'package:stager_platform/tree/leaf_node.dart';
import 'package:stager_platform/tree/node_observer.dart';
import 'package:stager_platform/tree/node_properties.dart';

/// This is a mock node observer for testing the ability of Stager to notify
/// observers of changes to nodes.
class MockNodeObserver extends NodeObserver {

  /// Whether the node has been updated.
  bool _updated = false;
  /// Get the tracer value.
  bool get updated => _updated;

  /// Stores the node instance received during the last update.
  NodeProperties? updatedProps;

  LeafNode? lastUpdatedNode;

  /// Reset the tracer value to false.
  void reset() {
    _updated = false;
    updatedProps = null;
    lastUpdatedNode = null;
  }

  @override
  void update(node) {
    _updated = true;
    if (node is LeafNode) {
      lastUpdatedNode = node;
    } else if (node is NodeProperties) {
      updatedProps = node;
    }
  }

}