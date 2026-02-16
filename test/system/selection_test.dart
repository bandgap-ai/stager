// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/system/selection.dart';
import 'mock_selection_observer.dart';

/// Unit tests for the [Selection] class.
void main() {
  group('Selection', () {
    test('should set and get the value', () {
      // Arrange
      final selection = Selection<String>('initial');
      expect(selection.value, 'initial');

      // Act
      selection.value = 'test';
      
      // Assert
      expect(selection.value, 'test');
    });

    test('should notify observer when selection changes', () {
      // Arrange
      final selection = Selection<int>(0);
      final observer = MockSelectionObserver<int>();
      selection.attach(observer);

      expect(observer.updated, isFalse);

      // Act
      selection.value = 10;
      
      // Assert
      expect(observer.updated, isTrue);
    });

    test('should not notify observer when selection is set to the same value', () {
      // Arrange
      final selection = Selection<String>('initial');
      final observer = MockSelectionObserver<String>();
      selection.attach(observer);

      observer.reset();
      expect(observer.updated, isFalse);

      // Act
      selection.value = 'initial';
      
      // Assert
      expect(observer.updated, isFalse);
    });

    test('should notify multiple observers', () {
      // Arrange
      final selection = Selection<double>(0.0);
      final observer1 = MockSelectionObserver<double>();
      final observer2 = MockSelectionObserver<double>();
      selection.attach(observer1);
      selection.attach(observer2);

      // Act
      selection.value = 3.14;
      
      // Assert
      expect(observer1.updated, isTrue);
      expect(observer2.updated, isTrue);
    });

    test('should not notify detached observer', () {
      // Arrange
      final selection = Selection<bool>(true);
      final observer = MockSelectionObserver<bool>();
      selection.attach(observer);

      // Verify initial state
      selection.value = false;
      expect(observer.updated, isTrue);

      observer.reset();
      
      // Act
      selection.detach(observer);
      selection.value = true;

      // Assert
      expect(observer.updated, isFalse);
    });
  });
}
