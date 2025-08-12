import 'package:stager_platform/tree/node_properties.dart';
import 'package:stager_platform/tree/node_observer.dart';

/// An interface for observers that are interested in changes to [NodeProperties].
///
/// Implementations of this interface will be notified when the properties of a node change.
abstract class NodePropertiesObserver implements NodeObserver<NodeProperties> {
  /// Called when the observed [NodeProperties] instance has been updated.
  ///
  /// [properties]: The [NodeProperties] instance that has been updated.
  /// Implementations should ensure that the [properties] object is of the expected type
  /// to avoid runtime type errors, especially if specific property types are expected.
  @override
  void update(NodeProperties properties);
}
