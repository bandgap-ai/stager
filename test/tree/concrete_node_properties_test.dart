// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/tree/concrete_node_properties.dart';
import 'package:stager_platform/tree/node_observer.dart';

/// A simple implementation of [NodeObserver] for testing property notifications.
class TestObserver implements NodeObserver<ConcreteNodeProperties> {
  /// Indicates if the [update] method was called.
  bool wasUpdated = false;

  /// Stores the node instance received during the last update.
  ConcreteNodeProperties? updatedNode;

  @override
  void update(ConcreteNodeProperties node) {
    wasUpdated = true;
    updatedNode = node;
  }
}

/// Unit tests for the [ConcreteNodeProperties] class.
void main() {
  group('ConcreteNodeProperties', () {
    test('containsProperty should correctly identify existing keys', () {
      // Arrange
      final properties = ConcreteNodeProperties({'key1': 'value1'});

      // Act & Assert
      expect(properties.containsProperty('key1'), isTrue);
      expect(properties.containsProperty('nonExistent'), isFalse);
    });

    test('containsProperty should return true for keys with null values', () {
      // Arrange
      final properties = ConcreteNodeProperties({'nullKey': null});

      // Act & Assert
      expect(properties.containsProperty('nullKey'), isTrue);
    });

    test('getProperty should return null for non-existent keys', () {
      // Arrange
      final properties = ConcreteNodeProperties();

      // Act & Assert
      expect(properties.getProperty('missing'), isNull);
    });

    test('setProperty should add new properties and update existing ones', () {
      // Arrange
      final properties = ConcreteNodeProperties();

      // Act
      properties.setProperty('test', 123);
      expect(properties.getProperty('test'), 123);

      properties.setProperty('test', 456);
      expect(properties.getProperty('test'), 456);
    });

    test('map should return the internal property map', () {
      // Arrange
      final initialData = {'a': 1, 'b': 2};
      final properties = ConcreteNodeProperties(initialData);

      // Act
      final propertyMap = properties.map;

      // Assert: Verify equality of contents.
      expect(propertyMap, equals(initialData));
    });

    test('attach and notify should trigger observer update on property change', () {
      // Arrange
      final properties = ConcreteNodeProperties();
      final observer = TestObserver();

      // Act
      properties.attach(observer);
      properties.setProperty('key', 'value');

      // Assert: Verify observer received the update notification.
      expect(observer.wasUpdated, isTrue);
      expect(observer.updatedNode, equals(properties));
    });

    test('detach should prevent observer from receiving further updates', () {
      // Arrange
      final properties = ConcreteNodeProperties();
      final observer = TestObserver();

      // Act
      properties.attach(observer);
      properties.detach(observer);
      properties.setProperty('key', 'value');

      // Assert: Verify observer was NOT updated after detachment.
      expect(observer.wasUpdated, isFalse);
    });
  });
}
