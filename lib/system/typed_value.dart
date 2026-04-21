import '../builders/basic_builder.dart';
import '../builders/stager_context.dart';

/// Specialized exception for failures during [TypedValue] rehydration.
class TypedValueRehydrationException implements Exception {
  /// The error message.
  final String message;

  /// Constructor.
  TypedValueRehydrationException(this.message);

  @override
  String toString() => 'TypedValueRehydrationException: $message';
}

/// A generic utility for rehydrating primitive types into native types for
/// [TypedValue<T>] containers.
///
/// This helper implements the platform's standard rehydration pattern:
/// 1. Optimized check for existing reified type (happy path).
/// 2. Defensive parsing from string representation.
/// 3. Wrapping format errors in descriptive [TypedValueRehydrationException]s.
///
/// [input]: The object to rehydrate/convert.
/// [parser]: The function to use for string parsing.
T _rehydrate<T>(Object input, T Function(String) parser) {
  late final T result;

  // Optimized Branch Order: Handle the reified case first.
  if (input is T) {
    result = input as T;
  } else {
    try {
      // Fallback to parsing the string representation.
      result = parser(input.toString());
    } on FormatException catch (e) {
      // Wrap the standard FormatException in a domain-specific exception.
      throw TypedValueRehydrationException(
          'Failed to rehydrate $T from "$input": $e');
    }
  }

  return result;
}

/// Rehydrates a [String] value into a [TypedValue].
TypedValue<String> _convertToString(Object input) {
  // Strings are the base case for rehydration and always succeed.
  return TypedValue<String>(input.toString());
}

/// Rehydrates an [int] value into a [TypedValue].
TypedValue<int> _convertToInt(Object input) =>
    TypedValue<int>(_rehydrate<int>(input, int.parse));

/// Rehydrates a [double] value into a [TypedValue].
TypedValue<double> _convertToDouble(Object input) {
  late final TypedValue<double> result;

  // Optimized branch order: check if input is already numeric.
  if (input is double) {
    result = TypedValue<double>(input);
  } else if (input is int) {
    // Explicitly handle int-to-double conversion.
    result = TypedValue<double>(input.toDouble());
  } else {
    result = TypedValue<double>(_rehydrate<double>(input, double.parse));
  }

  return result;
}

/// Rehydrates a [bool] value into a [TypedValue].
TypedValue<bool> _convertToBool(Object input) =>
    TypedValue<bool>(_rehydrate<bool>(input, bool.parse));

/// Rehydrates a [List<T>] of primitives by delegating to the generic helper.
TypedValue<List<T>> _convertToList<T>(Object input, T Function(String) parser) {
  late final TypedValue<List<T>> result;

  if (input is List<T>) {
    result = TypedValue<List<T>>(input);
  } else if (input is Iterable) {
    try {
      final List<T> values =
          input.map((element) => _rehydrate<T>(element, parser)).toList();
      result = TypedValue<List<T>>(values);
    } on Exception catch (e) {
      throw TypedValueRehydrationException('Failed to rehydrate List<$T>: $e');
    }
  } else {
    throw TypedValueRehydrationException('Input is not an iterable: $input');
  }

  return result;
}

/// Rehydrates a [Map<K, V>] of primitives.
TypedValue<Map<K, V>> _convertToMap<K, V>(
  Object input,
  K Function(String) keyParser,
  V Function(String) valParser,
) {
  late final TypedValue<Map<K, V>> result;

  if (input is Map<K, V>) {
    result = TypedValue<Map<K, V>>(input);
  } else if (input is Map) {
    try {
      final Map<K, V> reifiedMap = {};
      for (final entry in input.entries) {
        final K key = _rehydrate<K>(entry.key, keyParser);
        final V value = _rehydrate<V>(entry.value, valParser);
        reifiedMap[key] = value;
      }
      result = TypedValue<Map<K, V>>(reifiedMap);
    } on Exception catch (e) {
      throw TypedValueRehydrationException('Failed to rehydrate Map<$K, $V>: $e');
    }
  } else {
    throw TypedValueRehydrationException('Input is not a map structure: $input');
  }

  return result;
}

// Internal registry of rehydrator delegates.
final Map<String, TypedValue<Object> Function(Object)> _typeMap = {
  "String": _convertToString,
  "int": _convertToInt,
  "double": _convertToDouble,
  "bool": _convertToBool,

  // List Rehydrators
  "List<String>": (input) => _convertToList<String>(input, (s) => s),
  "List<int>": (input) => _convertToList<int>(input, int.parse),
  "List<double>": (input) => _convertToList<double>(input, double.parse),
  "List<bool>": (input) => _convertToList<bool>(input, bool.parse),

  // Map<String, T> Rehydrators
  "Map<String, String>": (input) => _convertToMap<String, String>(input, (s) => s, (s) => s),
  "Map<String, int>": (input) => _convertToMap<String, int>(input, (s) => s, int.parse),
  "Map<String, double>": (input) => _convertToMap<String, double>(input, (s) => s, double.parse),
  "Map<String, bool>": (input) => _convertToMap<String, bool>(input, (s) => s, bool.parse),

  // Map<int, T> Rehydrators
  "Map<int, String>": (input) => _convertToMap<int, String>(input, int.parse, (s) => s),
  "Map<int, int>": (input) => _convertToMap<int, int>(input, int.parse, int.parse),
  "Map<int, double>": (input) => _convertToMap<int, double>(input, int.parse, double.parse),
  "Map<int, bool>": (input) => _convertToMap<int, bool>(input, int.parse, bool.parse),

  // Map<bool, T> Rehydrators
  "Map<bool, String>": (input) => _convertToMap<bool, String>(input, bool.parse, (s) => s),
  "Map<bool, int>": (input) => _convertToMap<bool, int>(input, bool.parse, int.parse),
  "Map<bool, double>": (input) => _convertToMap<bool, double>(input, bool.parse, double.parse),
};

/// A specialized builder for [TypedValue].
///
/// [context]: The context for building the [TypedValue].
/// Returns a [TypedValue] instance.
@BasicBuilder(name: 'TypedValue')
TypedValue<Object> buildTypedValue(StagerContext context) {
  late final TypedValue<Object> result;

  try {
    final String typeName = context.get<String>("type");
    final Object rawValue = context.get<Object>("value");

    if (_typeMap.containsKey(typeName)) {
      result = _typeMap[typeName]!(rawValue);
    } else {
      throw TypedValueRehydrationException(
          'No rehydration function registered for type: $typeName');
    }
  } on StagerContextException catch (e) {
    throw TypedValueRehydrationException('Malformed context data: ${e.err}');
  } on Exception catch (e) {
    throw TypedValueRehydrationException('Unexpected rehydration failure: $e');
  }

  return result;
}

/// A lightweight container that bundles a value with its reified type.
///
/// [TypedValue] acts as a typed tuple, primarily used to preserve type 
/// information when storing objects in generic collections like 
/// [Map<String, Object>]. This is important for streaming and persistence. Note
/// that calling TypedValue<T>.toString() is equivalent to
/// TypedValue<T>.toMap().toString() and TypedValue<T>.toJson() is equivalent to
/// TypedValue<T>.toMap() to maintain consistent output and parsing across API
/// calls and types.
class TypedValue<T extends Object> {
  /// The actual data value.
  final T value;

  /// The reified type of the [value].
  final Type type;

  /// Constructor.
  ///
  /// [value]: The data to be stored.
  const TypedValue(this.value)
      : type = T,
        // This assertion is a contract that is only enforced during development.
        assert(value is T, 'Value must be of type $T');

  /// Converts the [TypedValue] to a map for persistence.
  ///
  /// Returns a [Map<String, Object>] containing the string representation of 
  /// the [type] and the [value] itself.
  Map<String, Object> toMap() {
    late final Map<String, Object> result;

    result = {
      'type': type.toString(),
      'value': value as Object,
    };

    return result;
  }

  @override
  bool operator ==(Object other) {
    // Return true if the objects are identical or if the other object is a 
    // TypedValue with the same reified type and data value.
    return identical(this, other) ||
        (other is TypedValue<T> &&
            other.value == value &&
            other.type == type);
  }

  @override
  int get hashCode {
    // Generate a hash based on the value and reified type.
    return Object.hash(value, type);
  }

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String,dynamic> toJson() {
    return toMap();
  }
}
