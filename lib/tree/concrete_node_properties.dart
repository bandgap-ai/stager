/// Concrete implementation of [NodeProperties].
///
/// This class stores properties in a [Map] of [TypedValue] objects.
library;

import 'package:collection/collection.dart';
import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/tree/node_observer.dart';
import 'package:stager_platform/system/typed_value.dart';

/// A concrete implementation of [NodeProperties] that manages typed key-value pairs.
///
/// It follows the Observer pattern to notify listeners whenever a property
/// is modified. It uses [TypedValue] containers to preserve type information.
///
/// Per Stager's "no-null policy," null values are not allowed.
class ConcreteNodeProperties implements NodeProperties {
  /// The internal map holding the node's properties as typed values.
  final Map<String, TypedValue<Object>> _properties = {};

  /// Internal list of observers attached to this node properties instance.
  final List<NodeObserver> _nodePropertiesObservers = [];

  /// Creates a [ConcreteNodeProperties] instance.
  ///
  /// [initialProperties]: A map of typed properties to initialize the 
  /// container with. Defaults to an empty map.
  ConcreteNodeProperties([
    Map<String, TypedValue<Object>> initialProperties = const {},
  ]) {
    // Transfer the initial typed properties into the internal storage.
    _properties.addAll(initialProperties);
  }

  @override
  Map<String, TypedValue<Object>> get map => _properties;

  @override
  T get<T>(String key) {
    late final T result;

    // Handle the happy path (property exists) first.
    if (contains(key)) {
      // Access the entry from the internal map.
      final entry = _properties[key]!;

      // Handle the happy path where types match first.
      if (entry.type == T || T == Object) {
        // Perform the cast to the requested generic type T.
        result = entry.value as T;
      } else {
        // Throw about the type error
        throw NodePropertyException(
            'Type mismatch for property "$key": Expected $T but found ${entry.type}.');
      }
    } else {
      // Throw about the missing key
      throw NodePropertyException('Property "$key" not found in properties.');
    }

    return result;
  }

  @override
  T getOrDefault<T>(String key, T defaultValue) {
    late final T result;

    // Delegate to the main getter and return the default if it throws an
    // exception.
    try {
      result = get<T>(key);
    } on NodePropertyException catch (_) {
      // Return the provided default if the property is missing.
      result = defaultValue;
    }

    return result;
  }

  @override
  void set<T extends Object>(String key, T value) {
    // Create a TypedValue that explicitly captures the reified type T.
    // We cast it to TypedValue<Object> to satisfy the internal map storage,
    // which is safe as T is non-nullable per Stager's no-null policy.
    _properties[key] = TypedValue<T>(value) as TypedValue<Object>;

    // Notify all attached observers that the node's properties have changed.
    notify();
  }

  @override
  void reset([Map<String, TypedValue<Object>> newValues = const {}]) {
    // Flush it an add the new values.
    _properties.clear();
    _properties.addAll(newValues);
    notify();
  }

  @override
  void merge(NodeProperties other) {
    reset(mergeMaps(_properties, other.map));
    notify();
  }

  @override
  bool contains(String key) {
    // Return whether the internal map contains an entry for the specified key.
    return _properties.containsKey(key);
  }

  @override
  bool isEmpty() {
    return _properties.isEmpty;
  }

  @override
  int size() {
    return _properties.length;
  }

  /// Attaches a [NodeObserver] to this node properties instance.
  @override
  void attach(NodeObserver observer) {
    // Add the observer to the registry for change notifications.
    _nodePropertiesObservers.add(observer);
  }

  /// Detaches a [NodeObserver] from this node properties instance.
  @override
  void detach(NodeObserver observer) {
    // Remove the observer so it no longer receives updates from this instance.
    _nodePropertiesObservers.remove(observer);
  }

  /// Notifies all attached [NodeObserver]s of a change.
  @override
  void notify() {
    // Execute the update callback for every registered observer.
    for (final observer in _nodePropertiesObservers) {
      observer.update(this);
    }
  }


}
