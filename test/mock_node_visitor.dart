import 'package:stager_platform/tree/node_visitor.dart';

/// Node visitor mock for testing
class MockNodeVisitor extends NodeVisitor {

  /// Stores the last visited node
  bool _hasVisited = false;

  /// Returns true if the node has been visited
  bool get hasVisited => _hasVisited;

  @override
  void visit(Object node) {
    // Mark the node as visited
    _hasVisited = true;
  }

}