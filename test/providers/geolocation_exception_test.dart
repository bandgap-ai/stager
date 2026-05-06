import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/providers/geolocation_exception.dart';

void main() {
  group('GeolocationException', () {
    test('should store the provided message', () {
      // Arrange
      const message = 'Test error message';

      // Act
      const exception = GeolocationException(message);

      // Assert
      expect(exception.message, message);
    });

    test('toString() should return a formatted string with the message', () {
      // Arrange
      const message = 'Test error message';
      const exception = GeolocationException(message);

      // Act
      final result = exception.toString();

      // Assert
      expect(result, 'GeolocationException: $message');
    });
  });
}
