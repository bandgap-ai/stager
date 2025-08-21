import 'package:stager_platform/tree/node_observer.dart';

/// This is a mock node observer for testing the ability of Stager to notify
/// observers of changes to nodes.
class MockNodeObserver extends NodeObserver {

  /// Whether the node has been updated.
  bool _updated = false;
  /// Get the tracer value.
  bool get updated => _updated;

  /// Reset the tracer value to false.
  void reset() {
    _updated = false;
  }

  @override
  void update(node) {
    _updated = true;
  }

}