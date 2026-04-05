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
  /// @param contextProps The context properties.
  const StagerContext(this._contextProps);

  /// Check if the context is empty.
  ///
  /// @return True if the context is empty, false otherwise.
  bool isEmpty() => _contextProps.isEmpty;

  /// Get a property from the context.
  ///
  /// @param key The key of the property to get.
  /// @return The value of the property.
  /// @throws StagerContextException if the key is not found in the context.
  T get<T>(String key) {
    if (_contextProps.containsKey(key)) {
      return _contextProps[key] as T;
    } else {
      throw StagerContextException('Key "$key" not found in context');
    }
  }

  /// Get a property from the context, but allow the caller to specify a default
  /// value in case the property is not in the context.
  ///
  /// @param key The key of the property to get.
  /// @param defaultValue The default value to return if the key is not found in
  /// the context.
  /// @return The value of the property
  T getOrDefault<T>(String key, T defaultValue) {
    try {
      return get<T>(key);
    } catch (e) {
      return defaultValue;
    }
  }

  // rehydrate()

  // T build<T>()
}