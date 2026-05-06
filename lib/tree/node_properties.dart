import 'observable_subject.dart';
import '../system/typed_value.dart';

/// Exception thrown when a requested property cannot be found in [NodeProperties].
class NodePropertyException implements Exception {
  /// The error message.
  final String message;

  /// Constructor.
  NodePropertyException(this.message);

  @override
  String toString() => 'NodePropertyException: $message';
}

/// An abstract class defining the contract for properties associated with a tree node.
///
/// This class serves as a base for concrete implementations that will store
/// and manage key-value pairs representing node-specific data.
abstract class NodeProperties implements ObservableSubject {

  /// Retrieves the value of a property given its [key].
  ///
  /// [key]: The string identifier for the property.
  /// Returns the value associated with the [key], or a NodePropertiesException
  /// if the key is not found.
  T get<T>(String key);

  /// Retrieves the value of a property given its [key] or a default value if
  /// the requested key cannot be found.
  ///
  /// [key]: The string identifier for the property.
  /// [defaultValue]: The value to return if the [key] is not found.
  /// Returns the value associated with the [key] or the [defaultValue] if the
  /// key is not found.
  T getOrDefault<T>(String key, T defaultValue);

  /// Sets the [value] of a property for a given [key].
  ///
  /// [key]: The string identifier for the property.
  /// [value]: The value to set for the property. Per Stager's no-null policy,
  /// null values are not allowed.
  void set<T extends Object>(String key, T value);

  /// Resets the node properties to an initial default state or to the values
  /// provided in [newValues]. Since this can effectively clear all the
  /// properties of a node, possibly even its name and id, this method should
  /// be used with caution.
  ///
  /// This function notifies observers.
  ///
  /// [newValues]: A map of key-value pairs to set as the new properties. The
  /// default value is an empty map, so be careful not to brick your node.
  void reset([Map<String, TypedValue<Object>> newValues = const {}]);

  /// Merges the properties of another [NodeProperties] instance into this one.
  ///
  /// In the event of a duplicate, the [other] instance's value will be used.
  ///
  /// This function notifies observers.
  ///
  /// [other]: The [NodeProperties] instance to merge with.
  void merge(NodeProperties other);

  /// Checks if a property exists for a given [key].
  ///
  /// [key]: The string identifier for the property.
  /// Returns `true` if the property exists, `false` otherwise.
  bool contains(String key);

  /// Checks if the properties map is empty.
  ///
  /// Returns `true` if the properties map is empty, `false` otherwise.
  bool isEmpty();

  /// Returns the number of properties.
  int size();

  /// Retrieves the internal map of properties.
  ///
  /// This getter returns a map of all properties stored in this instance. It
  /// uses TypedValue<Object> values to inform the client of the type of the
  /// stored value. Per Stager's no-null policy, the map will not include null
  /// values.
  Map<String, TypedValue<Object>> get map;

  /// toMap() is an alternative to the getter map and it produces a pure
  /// Map<String,Object>. Where map() has its uses in programmatic situations,
  /// toMap() is more convenient for I/O.
  Map<String,Object> toMap();

  /// Magic json function
  Object toJson();
}
