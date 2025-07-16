/// Concrete implementation of [NodeProperties].
///
/// This class stores properties in a simple [Map<String, Object?>].
library;
import 'package:stager/tree/tree.dart';

class ConcreteNodeProperties implements NodeProperties {
  /// The internal map holding the node's properties.
  final Map<String, Object?> _properties;

  /// Internal list of observers attached to this node properties instance.
  final List<NodePropertiesObserver> _nodePropertiesObservers = [];

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

  /// Attaches a [NodePropertiesObserver] to this node properties instance.
  @override
  void attach(NodePropertiesObserver observer) {
    _nodePropertiesObservers.add(observer);
  }

  /// Detaches a [NodePropertiesObserver] from this node properties instance.
  @override
  void detach(NodePropertiesObserver observer) {
    _nodePropertiesObservers.remove(observer);
  }

  /// Notifies all attached [NodePropertiesObserver]s of a change.
  @override
  void notify() {
    for (final observer in _nodePropertiesObservers) {
      observer.update(this);
    }
  }
}