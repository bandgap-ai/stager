
/// This is an interface for observers that are interested in changes to
/// any type of [TreeNode], include [LeafNode] and [CompositeNode], and related
/// constructs such as [SiteState].
abstract class NodeObserver<T> {
  /// Called when the observed node instance has been updated.
  ///
  /// [node]: The node instance that has been updated.
  void update(T node);
}