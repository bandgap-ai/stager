import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/system/generic_delegating_observer.dart';

void main() {
  group('GenericDelegatingObserver', () {
    test('should call the provided callback when update is called', () {
      // Arrange
      bool wasCalled = false;
      final observer = GenericDelegatingObserver<String>(() {
        wasCalled = true;
      });

      // Act
      observer.update();

      // Assert
      expect(wasCalled, isTrue);
    });
  });
}
