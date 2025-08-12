import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/node_observer.dart';

/// This is a mock composite node observer for testing.
class MockCompositeNodeObserver implements NodeObserver<CompositeNode> {
  @override
  void update(CompositeNode node) {
    _updated = true;
  }

  bool _updated = false;

  bool get updated => _updated;

  void reset() {
    _updated = false;
  }

}