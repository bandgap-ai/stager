// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/system/typed_value.dart';

import 'mock_node_observer.dart';

/// Unit tests for the [ConcreteNodeProperties] class.
void main() {
  group('ConcreteNodeProperties Tests', () {
    test('containsProperty should correctly identify existing and missing keys', () {
      // Create a properties container with a pre-defined String property to 
      // check containment logic.
      final properties = ConcreteNodeProperties({
        'key1': const TypedValue<String>('value1'),
      });

      // Verify that the container accurately reports the presence of 'key1' 
      // and the absence of a non-existent key.
      expect(properties.contains('key1'), isTrue);
      expect(properties.contains('nonExistent'), isFalse);
    });

    test('constructor should initialize with provided typed properties', () {
      // Define a set of initial typed values representing a typical node's 
      // identity properties.
      final initialData = {
        'id': const TypedValue<String>('leaf1'),
        'name': const TypedValue<String>('Leaf 1'),
      };
      
      // Instantiate the container using the reified property map.
      final properties = ConcreteNodeProperties(initialData);

      // Confirm that the internal map matches the initialization data exactly.
      expect(properties.map, equals(initialData));
    });

    test('getProperty should retrieve correctly typed values', () {
      // Initialize properties with a specifically typed string value.
      final properties = ConcreteNodeProperties({
        'name': const TypedValue<String>('Test'),
      });

      // Verify that the generic getter correctly retrieves and casts the value 
      // without requiring manual casting at the call site.
      expect(properties.get<String>('name'), 'Test');
      // Try getting the value as an object. Convert it to a string for testing.
      expect(properties.get<Object>('name').toString(), 'Test');
    });

    test('getProperty should throw NodePropertyException for missing keys', () {
      // Initialize an empty properties container to test error conditions.
      final properties = ConcreteNodeProperties();

      // Ensure that attempting to access a non-existent key triggers the 
      // platform-standard property exception.
      expect(
        () => properties.get<String>('missing'),
        throwsA(isA<NodePropertyException>()),
      );
    });

    test('getProperty should throw NodePropertyException for type mismatches', () {
      // Initialize properties with an integer to test strict type enforcement.
      final properties = ConcreteNodeProperties({
        'count': const TypedValue<int>(42),
      });

      // Verify that requesting an 'int' property as a 'String' triggers a 
      // descriptive type mismatch error.
      expect(
        () => properties.get<String>('count'),
        throwsA(isA<NodePropertyException>().having(
          (e) => e.message,
          'message',
          contains('Type mismatch'),
        )),
      );
    });

    test('getOrDefault should return the stored value when types match', () {
      // Initialize properties with a double to test the fallback mechanism.
      final properties = ConcreteNodeProperties({
        'scale': const TypedValue<double>(0.5),
      });

      // Confirm that the correct value is returned when the key is found and 
      // the type is correct.
      expect(properties.getOrDefault<double>('scale', 1.0), 0.5);
    });

    test('getOrDefault should return the default value for missing keys', () {
      // Initialize an empty container to test the default value path.
      final properties = ConcreteNodeProperties();

      // Verify that the provided default is returned when the requested key 
      // is not present in the map.
      expect(properties.getOrDefault<int>('missing', 10), 10);
    });

    test('getOrDefault should return the default value for type mismatches', () {
      // Initialize properties with a string to test fallback on type error.
      final properties = ConcreteNodeProperties({
        'name': const TypedValue<String>('Stager'),
      });

      // Confirm that the default value is returned if the key exists but the 
      // requested type is incorrect.
      expect(properties.getOrDefault<int>('name', 0), 0);
    });

    test('setProperty should add and update typed properties', () {
      // Start with an empty container to verify the addition of new data.
      final properties = ConcreteNodeProperties();

      // Add a numeric property and verify that it is wrapped in a TypedValue 
      // with the correct reified type.
      properties.set<double>('scale', 0.5);
      expect(properties.get<double>('scale'), 0.5);
      expect(properties.map['scale']!.type, double);

      // Update the existing property and ensure the new value is stored correctly.
      properties.set<double>('scale', 1.0);
      expect(properties.get<double>('scale'), 1.0);
    });

    test('notifications should trigger on property modifications', () {
      // Setup the container and attach a mock observer for reactivity testing.
      final properties = ConcreteNodeProperties();
      final observer = MockNodeObserver();
      properties.attach(observer);

      // Trigger a state change by setting a property.
      properties.set<String>('status', 'active');

      // Verify that the observer's update method was called with the 
      // correct instance.
      expect(observer.updated, isTrue);
      expect(observer.updatedProps, equals(properties));
    });

    test('notifications should NOT trigger after observer is detached', () {
      // Setup an observer and then immediately detach it to verify lifecycle 
      // management.
      final properties = ConcreteNodeProperties();
      final observer = MockNodeObserver();
      properties.attach(observer);
      properties.detach(observer);

      // Modify the state and ensure no notification occurs.
      properties.set<String>('status', 'inactive');
      expect(observer.updated, isFalse);
    });

    test('reset()', () {
      final properties = ConcreteNodeProperties();
      properties.set<String>('key1', 'value1');
      properties.set<String>('key2', 'value2');
      MockNodeObserver observer = MockNodeObserver();
      properties.attach(observer);

      properties.reset();

      // Verify that the observer's update method was called with the
      // correct instance.
      expect(observer.updated, isTrue);
      expect(observer.updatedProps, equals(properties));

      expect(properties.contains('key1'), isFalse);
      expect(properties.contains('key2'), isFalse);
      expect(properties.isEmpty(), isTrue);
      expect(properties.size(), 0);

      properties.set<String>('key1', 'value1');
      properties.set<String>('key2', 'value2');

      // Reset the observer
      observer.reset();

      final newValues = {'key3': const TypedValue<String>('value3'),
                         'key4': const TypedValue<String>('value4')};
      properties.reset(newValues);

      // Verify that the observer's update method was called with the
      // correct instance.
      expect(observer.updated, isTrue);
      expect(observer.updatedProps, equals(properties));

      expect(properties.contains('key1'), isFalse);
      expect(properties.contains('key2'), isFalse);
      expect(properties.contains('key3'), isTrue);
      expect(properties.get<String>('key3'), 'value3');
      expect(properties.contains('key4'), isTrue);
      expect(properties.get<String>('key4'), 'value4');
      expect(properties.isEmpty(), false);
      expect(properties.size(), 2);
    });

    test('merge()', () {
      final properties = ConcreteNodeProperties();
      properties.set<String>('key1', 'value1');
      final observer = MockNodeObserver();
      properties.attach(observer);

      final otherProperties = ConcreteNodeProperties();
      otherProperties.set<String>('key2', 'value2');

      properties.merge(otherProperties);

      expect(properties.contains('key1'), isTrue);
      expect(properties.contains('key2'), isTrue);
      expect(properties.get<String>('key1'), 'value1');
      expect(properties.get<String>('key2'), 'value2');
      // Check the observer
      expect(observer.updated, isTrue);

      // Now confirm that adding a duplicate "key2" will result in the original
      // value being overwritten
      final otherProperties2 = ConcreteNodeProperties();
      otherProperties2.set<String>('key2', 'value2_2');

      properties.merge(otherProperties2);

      expect(properties.contains('key1'), isTrue);
      expect(properties.get<String>('key1'), 'value1');
      expect(properties.contains('key2'), isTrue);
      expect(properties.get<String>('key2'), 'value2_2');

    });
  });
}
