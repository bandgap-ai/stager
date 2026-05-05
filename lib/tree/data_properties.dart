import '../system/typed_value.dart';
import 'concrete_node_properties.dart';
import 'data_node.dart';
import 'node_observer.dart';
import 'observable_subject.dart';

/// A specialized container for managing [DataNode] objects.
///
/// This acts as a sidecar to LeafNodes, providing a structured way to manage
/// binary attachments without cluttering the primary [NodeProperties].
class DataProperties implements ObservableSubject {
  final ConcreteNodeProperties _properties;

  /// Internal list of observers attached to this data properties instance.
  final List<NodeObserver> _dataPropertiesObservers = [];

  /// Creates a new DataProperties instance. Like the NodeProperties class, it
  /// can be loaded from a set of initial properties which should all be
  /// DataNodes in this case.
  DataProperties([Map<String, TypedValue<Object>> initialProperties = const {}])
      : _properties = ConcreteNodeProperties(initialProperties);

  /// Returns the size of the data properties container, which is the number of
  /// data nodes.
  int get size => _properties.size();

  /// Returns true if the data properties container is empty, false otherwise.
  bool get isEmpty => _properties.isEmpty();

  /// Returns true if the data properties container is not empty, false
  /// otherwise.
  bool get isNotEmpty => !isEmpty;

  /// Get all of the data nodes as a list.
  List<DataNode> get all => _properties.map.map(
          (key, value) => MapEntry(key,value.value as DataNode)).values.toList();

  /// A convenience function to get all of the paths as a list.
  List<String> get allPaths => _properties.map.map(
          (key, value) => MapEntry(key,(value.value as DataNode).path)).values.toList();

  /// Returns true if the data properties container contains a data node with
  /// the specified key, false otherwise.
  bool hasNode(String key) => _properties.contains(key);

  /// Returns the data node associated with the specified key.
  ///
  /// Throws a [NodePropertyException] if the key is not found.
  DataNode get(String key) => _properties.get<DataNode>(key);

  /// Sets the data node associated with the specified key.
  ///
  /// Throws a [NodePropertyException] if the key is not found.
  void set(String key, DataNode value) {
    _properties.set<DataNode>(key, value);
    notify();
  }

  /// Converts this container to a map.
  Map<String, Object> toMap() => _properties.map;

  @override
  void attach(NodeObserver observer) {
    _dataPropertiesObservers.add(observer);
  }

  @override
  void detach(NodeObserver observer) {
    _dataPropertiesObservers.remove(observer);
  }

  @override
  void notify() {
    for (final observer in _dataPropertiesObservers) {
      observer.update(this);
    }
  }

}
