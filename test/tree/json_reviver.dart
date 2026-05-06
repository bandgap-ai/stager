/// A reviver function for [jsonDecode] that ensures the resulting object
/// graph is strictly typed and adheres to the platform's No-Null Policy.
Object jsonReviver(Object? key, Object? value) {
  // Satisfy No-Null policy by converting nulls to empty strings.
  Object result = value ?? '';

  if (value is Map) {
    // Reify dynamic maps into strictly typed Map<String, Object>.
    result = Map<String, Object>.from(value);
  } else if (value is List) {
    // Reify dynamic lists into strictly typed List<Object>.
    result = List<Object>.from(value);
  }

  return result;
}