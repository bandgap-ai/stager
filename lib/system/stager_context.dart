import 'typed_value.dart';

/// Basic typed exception for the StagerContext class.
class StagerContextException implements Exception {

  /// The error message to be reported.
  final String err;

  /// Constructor
  ///
  /// @param err The error message to be reported.
  StagerContextException(this.err);

  @override
  String toString() => 'StagerContextException: $err';
}

/// The StagerContext class is a key participant in the dynamic factory
/// infrastructure of Stager and acts as guide and courier for all the
/// information available to a [BasicBuilder].
///
/// Context properties are the properties that should be used to build the
/// object under construction. Callers can retrieve properties with either get()
/// or getOrDefault(). The former throws an exception and the latter returns a
/// default value specified by the caller. Properties can only be set on
/// construction, not by callers.
class StagerContext {
  /// The context properties.
  final Map<String,Object> _contextProps;

  /// Constructor
  ///
  /// [contextProps]: The context properties.
  const StagerContext(this._contextProps);

  /// Check if the context is empty.
  ///
  /// @return True if the context is empty, false otherwise.
  bool isEmpty() => _contextProps.isEmpty;

  /// Get a property from the context.
  ///
  /// [key]: The key of the property to get.
  /// Returns the value of the property or throws StagerContextException if the
  /// key is not found in the context.
  T get<T>(String key) {
    late T retVal;
    if (_contextProps.containsKey(key)) {
      Object contextValue = _contextProps[key]!;
      if (contextValue is T) {
        retVal = contextValue as T;
      } else {
        // Try rebuilding this as a TypedValue to get around all the possible
        // type mischief that could happen.
        StagerContext context = StagerContext({'value':[T,contextValue]});
        final TypedValue<Object> typedValue = buildTypedValue(context);
        retVal = typedValue.value as T;
      }
    } else {
      throw StagerContextException('Key "$key" not found in context');
    }
    return retVal;
  }

  /// Get a property from the context, but allow the caller to specify a default
  /// value in case the property is not in the context.
  ///
  /// [key]: The key of the property to get.
  /// [defaultValue]: The default value to return if the key is not found in
  /// the context.
  /// Returns the value stored at the specified key or the default if nothing is
  /// stored for the key.
  T getOrDefault<T>(String key, T defaultValue) {
    try {
      return get<T>(key);
    } catch (e) {
      return defaultValue;
    }
  }

  /// This returns the StagerContext as a copy of its internal map.
  ///
  /// Returns a copy of the internal map.
  Map<String,Object> toMap() => Map<String,Object>.from(_contextProps);

  /// Check if a property exists in the context.
  ///
  /// [key]: The key of the property to check.
  /// Returns true if the property exists, false otherwise.
  bool contains(String key) => _contextProps.containsKey(key);

  /// Check if a property exists in the context with the specified type
  ///
  /// [key]: The key of the property to check.
  /// Returns true if the property exists and is of the specified type, false
  /// otherwise.
  bool containsTyped<T>(String key) {
    if (_contextProps.containsKey(key)) {
      return _contextProps[key] is T;
    } else {
      return false;
    }
  }
}