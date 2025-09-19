import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/editors/selection.dart';

import 'mock_selection_observer.dart';

void main() {
  group('Selection', () {
    test('should set and get the value', () {
      final selection = Selection<String>();
      expect(selection.value, isNull);

      selection.value = 'test';
      expect(selection.value, 'test');
    });

    test('should notify observer when selection changes', () {
      final selection = Selection<int>();
      final observer = MockSelectionObserver<int>();
      selection.attach(observer);

      expect(observer.updated, isFalse);

      selection.value = 10;
      expect(observer.updated, isTrue);
      expect(observer.lastSelection, 10);
    });

    test('should not notify observer when selection is set to the same value', () {
      final selection = Selection<String>();
      final observer = MockSelectionObserver<String>();
      selection.value = 'initial';
      selection.attach(observer);

      observer.reset();
      expect(observer.updated, isFalse);

      selection.value = 'initial';
      expect(observer.updated, isFalse);
    });

    test('should notify multiple observers', () {
      final selection = Selection<double>();
      final observer1 = MockSelectionObserver<double>();
      final observer2 = MockSelectionObserver<double>();
      selection.attach(observer1);
      selection.attach(observer2);

      selection.value = 3.14;
      expect(observer1.updated, isTrue);
      expect(observer1.lastSelection, 3.14);
      expect(observer2.updated, isTrue);
      expect(observer2.lastSelection, 3.14);
    });

    test('should not notify detached observer', () {
      final selection = Selection<bool>();
      final observer = MockSelectionObserver<bool>();
      selection.attach(observer);

      selection.value = true;
      expect(observer.updated, isTrue);

      observer.reset();
      selection.detach(observer);

      selection.value = false;
      expect(observer.updated, isFalse);
    });

    test('should handle null values correctly', () {
      final selection = Selection<String?>();
      final observer = MockSelectionObserver<String?>();
      selection.attach(observer);

      selection.value = 'not null';
      expect(observer.updated, isTrue);
      expect(observer.lastSelection, 'not null');

      observer.reset();
      selection.value = null;
      expect(observer.updated, isTrue);
      expect(observer.lastSelection, isNull);
    });
  });
}
