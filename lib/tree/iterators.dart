
/// This file contains concrete implementations of iterators for the Stager tree.
library;

import 'package:stager_platform/tree/tree.dart';

/// A depth-first iterator for [LeafNode]s.
///
/// This iterator traverses the tree starting from a given root node,
/// visiting nodes in a depth-first manner.
class DepthFirstIterator implements Iterator<LeafNode> {
  /// The stack used for depth-first traversal.
  final List<LeafNode> _stack = [];

  /// The current node being iterated over.
  LeafNode? _current;

  /// Creates a [DepthFirstIterator] starting from the given [root] node.
  ///
  /// [root]: The starting node for the traversal.
  DepthFirstIterator(LeafNode root) {
    _stack.add(root);
  }

  @override
  LeafNode get current => _current!;

  @override
  bool moveNext() {
    if (_stack.isEmpty) {
      _current = null;
      return false;
    }

    _current = _stack.removeLast();

    // If the current node is a composite, add its children to the stack
    // in reverse order to ensure correct depth-first traversal.
    if (_current!.isComposite) {
      final compositeNode = _current! as CompositeNode;
      for (int i = compositeNode.children.length - 1; i >= 0; i--) {
        _stack.add(compositeNode.children[i]);
      }
    }
    return true;
  }
}

/// A breadth-first iterator for [LeafNode]s.
///
/// This iterator traverses the tree starting from a given root node,
/// visiting nodes level by level.
class BreadthFirstIterator implements Iterator<LeafNode> {
  /// The queue used for breadth-first traversal.
  final List<LeafNode> _queue = [];

  /// The current node being iterated over.
  LeafNode? _current;

  /// Creates a [BreadthFirstIterator] starting from the given [root] node.
  ///
  /// [root]: The starting node for the traversal.
  BreadthFirstIterator(LeafNode root) {
    _queue.add(root);
  }

  @override
  LeafNode get current => _current!;

  @override
  bool moveNext() {
    if (_queue.isEmpty) {
      _current = null;
      return false;
    }

    _current = _queue.removeAt(0);

    // If the current node is a composite, add its children to the queue.
    if (_current!.isComposite) {
      final compositeNode = _current! as CompositeNode;
      _queue.addAll(compositeNode.children);
    }
    return true;
  }
}
