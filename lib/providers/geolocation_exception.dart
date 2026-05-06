/// Exception thrown when a geolocation or geocoding operation fails.
///
/// This exception provides a descriptive [message] explaining the cause of the
/// failure.
class GeolocationException implements Exception {
  /// The message describing the error.
  final String message;

  /// Creates a [GeolocationException] with the given [message].
  const GeolocationException(this.message);

  @override
  String toString() {
    return 'GeolocationException: $message';
  }
}
