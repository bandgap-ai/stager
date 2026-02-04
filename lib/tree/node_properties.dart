import 'package:stager_platform/tree/observable_subject.dart';

/// An abstract class defining the contract for properties associated with a tree node.
///
/// This class serves as a base for concrete implementations that will store
/// and manage key-value pairs representing node-specific data.
abstract class NodeProperties implements ObservableSubject {
  /// Retrieves the value of a property given its [key].
  ///
  /// [key]: The string identifier for the property.
  /// Returns the value associated with the [key], or `null` if the key is not found.
  /// Type safety: The returned value is of type [Object?]. Consumers should cast it
  /// to the expected type or perform type checks to ensure type safety.
  Object? getProperty(String key);

  /// Sets the [value] of a property for a given [key].
  ///
  /// [key]: The string identifier for the property.
  /// [value]: The value to set for the property. Can be `null`.
  /// Type safety: The [value] is accepted as [Object?]. Concrete implementations
  /// should handle the storage and retrieval of various types appropriately.
  void setProperty(String key, Object? value);

  /// Checks if a property exists for a given [key].
  ///
  /// [key]: The string identifier for the property.
  /// Returns `true` if the property exists, `false` otherwise.
  bool containsProperty(String key);

  /// Retrieves the internal map of properties.
  ///
  /// This getter provides direct access to the underlying map storing the properties.
  /// Type safety: The returned map contains [String] keys and [Object?] values.
  Map<String, Object?> get map;
}
