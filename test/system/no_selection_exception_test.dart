// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/system/no_selection_exception.dart';

/// Unit tests for the [NoSelectionException] class.
void main() {
  group('NoSelectionException', () {
    test('should store the correct viewId', () {
      // Arrange
      const viewId = 'test_view';
      
      // Act
      const exception = NoSelectionException(viewId);
      
      // Assert
      expect(exception.viewId, viewId);
    });

    test('toString() should return a descriptive error message', () {
      // Arrange
      const viewId = 'map_editor';
      const exception = NoSelectionException(viewId);
      
      // Act
      final message = exception.toString();
      
      // Assert
      expect(message, contains('NoSelectionException'));
      expect(message, contains('map_editor'));
    });

    test('is an Exception', () {
      // Arrange
      const exception = NoSelectionException('any');
      
      // Act & Assert
      expect(exception, isA<Exception>());
    });
  });
}
