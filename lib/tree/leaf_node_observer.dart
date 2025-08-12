import 'package:stager_platform/tree/leaf_node.dart';
import 'package:stager_platform/tree/node_observer.dart';

/// An interface for observers that are interested in changes to [LeafNode] instances.
///
/// Implementations of this interface will be notified when a [LeafNode] changes.
abstract class LeafNodeObserver implements NodeObserver<LeafNode> {
  /// Called when the observed [LeafNode] instance has been updated.
  ///
  /// [node]: The [LeafNode] instance that has been updated.
  /// Implementations should ensure that the [node] object is of the expected type
  /// to avoid runtime type errors.
  @override
  void update(LeafNode node);
}
