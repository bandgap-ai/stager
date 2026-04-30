import "../system/stager_context.dart";
import "../stager_registry.g.dart";

/// This is a custom exception for registry errors.
class RegistryException implements Exception {
  final String message;

  RegistryException(this.message);

  @override
  String toString() => 'RegistryException: $message';
}

Map<String, Type> _availableTypesByString = stagerRegistryMap.map(
    (key, value) => MapEntry(key.toString(), key)
);

/// This function builds an object of the specified type with the parameters. It
/// is meant to be used in generic builders where the type may only be known in
/// an abstract, parameterized way. This is especially useful for rehydration in
/// I/O.
///
/// [type]: The type of the object to build.
/// [parameters]: The parameters to pass to the builder.
/// Returns the built object.
Object buildObject(String type, Map<String, Object> parameters) {
  late Object retVal;
  late Type realType;
  print(_availableTypesByString);
  if (_availableTypesByString.containsKey(type)) {
    realType = _availableTypesByString[type]!;
    if (stagerRegistryMap.containsKey(realType)) {
      StagerContext context = StagerContext(parameters);
      retVal = stagerRegistryMap[realType]!.build(context);
    } else {
      throw RegistryException('Mismatch between internal registry maps for '
          'type: $type. Please rebuild Stager or report this issue.');
    }
  } else {
    throw RegistryException('No builder registered for type: $type');
  }
  return retVal;
}