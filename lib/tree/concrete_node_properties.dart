/// Concrete implementation of [NodeProperties].
///
/// This class stores properties in a simple [Map<String, Object?>].
library;

import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/tree/node_observer.dart';

/// A concrete implementation of [NodeProperties] that manages key-value pairs.
///
/// It follows the Observer pattern to notify listeners whenever a property
/// is modified.
class ConcreteNodeProperties implements NodeProperties {
  /// The internal map holding the node's properties.
  final Map<String, Object?> _properties;

  /// Internal list of observers attached to this node properties instance.
  final List<NodeObserver> _nodePropertiesObservers = [];

  /// Creates a [ConcreteNodeProperties] instance.
  ///
  /// [initialProperties]: An optional map to initialize the properties with.
  ConcreteNodeProperties([Map<String, Object?>? initialProperties])
      : _properties = initialProperties ?? {};

  @override
  Map<String, Object?> get map => _properties;

  @override
  Object? getProperty(String key) {
    return _properties[key];
  }

  @override
  void setProperty(String key, Object? value) {
    _properties[key] = value;
    notify();
  }

  @override
  bool containsProperty(String key) {
    return _properties.containsKey(key);
  }

  /// Attaches a [NodeObserver] to this node properties instance.
  @override
  void attach(NodeObserver observer) {
    _nodePropertiesObservers.add(observer);
  }

  /// Detaches a [NodeObserver] from this node properties instance.
  @override
  void detach(NodeObserver observer) {
    _nodePropertiesObservers.remove(observer);
  }

  /// Notifies all attached [NodeObserver]s of a change.
  @override
  void notify() {
    for (final observer in _nodePropertiesObservers) {
      observer.update(this);
    }
  }
}
