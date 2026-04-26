import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/builders/stager_context.dart';
import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/tree/tree.dart';

/// Unit tests for the [TypedValue] class and its rehydration logic.
void main() {
  group('TypedValue Tests', () {
    test('should store and retrieve a String value', () {
      // Define a string input and wrap it in a TypedValue.
      const input = 'test_string';
      const typedValue = TypedValue<String>(input);

      // Verify that the stored value and reified type are correct.
      expect(typedValue.value, input);
      expect(typedValue.type, String);
    });

    test('should store and retrieve an int value', () {
      // Define an integer input and wrap it in a TypedValue.
      const input = 42;
      const typedValue = TypedValue<int>(input);

      // Verify that the stored value and reified type are correct.
      expect(typedValue.value, input);
      expect(typedValue.type, int);
    });

    test('should convert to a map correctly', () {
      // Define a double input and wrap it in a TypedValue.
      const input = 3.14;
      const typedValue = TypedValue<double>(input);

      // Convert the TypedValue to a Tuple
      final tuple = typedValue.toTuple();

      // Verify that the map contains the correct type string and value.
      expect(tuple.length, 2);
      expect(tuple[0], 'double');
      expect(tuple[1], input);
    });

    test('should fail with TypeError when value type mismatch occurs', () {
      // Use dynamic to bypass compile-time checks with an invalid type.
      const dynamic sneakyInput = 'not a double';

      // Verify that the runtime throws a TypeError during constructor assignment.
      expect(
        () => TypedValue<double>(sneakyInput),
        throwsA(isA<TypeError>()),
      );
    });

    test('should verify equality and hash code', () {
      // Create two identical TypedValue instances.
      const val1 = TypedValue<String>('equal');
      const val2 = TypedValue<String>('equal');

      // Create a different TypedValue instance.
      const val3 = TypedValue<String>('different');

      // Create a TypedValue with a different type.
      const val4 = TypedValue<int>(42);

      // Verify that identical instances are equal and have the same hash code.
      expect(val1, equals(val2));
      expect(val1.hashCode, equals(val2.hashCode));

      // Verify that different values result in inequality.
      expect(val1, isNot(equals(val3)));
      expect(val1.hashCode, isNot(equals(val3.hashCode)));

      // Verify that different types result in inequality.
      expect(val1, isNot(equals(val4)));
    });

    group('TypedValueRehydrationException Tests', () {
      test('toString should return a descriptive error message', () {
        // Create an exception with a specific message.
        final exception = TypedValueRehydrationException('Test Error');

        // Verify that toString() includes the exception name and message.
        expect(
          exception.toString(),
          'TypedValueRehydrationException: Test Error',
        );
      });
    });

    group('buildTypedValue Rehydration Edge Cases', () {
      test('should rehydrate a String', () {
        final context = StagerContext(const {
          'value': ['String', 'hi']
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<String>>());
        expect(result.value, 'hi');
      });

      test('should rehydrate an Object', () {
        final context = StagerContext(const {
          'value': ['Object', 42]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<Object>>());
        expect(result.value, 42);
      });

      test('should rehydrate a double from a string', () {
        final context = StagerContext(const {
          'value': ['double', '3.14']
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<double>>());
        expect(result.value, 3.14);
      });

      test('should rehydrate a double from an int', () {
        final context = StagerContext(const {
          'value': ['double', 42]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<double>>());
        expect(result.value, 42.0);
      });

      test('should rehydrate an int from a string', () {
        final context = StagerContext(const {
          'value': ['int', '123']
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<int>>());
        expect(result.value, 123);
      });

      test('should rehydrate a bool from a string', () {
        final context = StagerContext(const {
          'value': ['bool', 'true']
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<bool>>());
        expect(result.value, isTrue);
      });

      test('should throw TypedValueRehydrationException for unknown types', () {
        final context = StagerContext(const {
          'value': ['Unknown', '...']
        });
        expect(
          () => buildTypedValue(context),
          throwsA(isA<TypedValueRehydrationException>().having(
            (e) => e.message,
            'message',
            contains('No rehydration function registered for type: Unknown'),
          )),
        );
      });

      test('should throw TypedValueRehydrationException for malformed numbers', () {
        final contextInt = StagerContext(const {
          'value': ['int', 'abc']
        });
        expect(() => buildTypedValue(contextInt),
            throwsA(isA<TypedValueRehydrationException>()));

        final contextDouble = StagerContext(const {
          'value': ['double', 'xyz']
        });
        expect(() => buildTypedValue(contextDouble),
            throwsA(isA<TypedValueRehydrationException>()));
      });

      test(
          'should throw TypedValueRehydrationException for malformed context data',
          () {
        // Trigger re-wrapped StagerContextException
        final context = StagerContext(const {'key': 'missing_value'});
        expect(
          () => buildTypedValue(context),
          throwsA(isA<TypedValueRehydrationException>().having(
            (e) => e.message,
            'message',
            contains('Malformed context data'),
          )),
        );
      });

      test(
          'should throw TypedValueRehydrationException for non-iterable List input',
          () {
        final context = StagerContext(const {
          'value': ['List<int>', 123]
        });
        expect(
          () => buildTypedValue(context),
          throwsA(isA<TypedValueRehydrationException>().having(
            (e) => e.message,
            'message',
            contains('Input is not an iterable'),
          )),
        );
      });

      test('should throw TypedValueRehydrationException for non-map Map input',
          () {
        final context = StagerContext(const {
          'value': ['Map<String, String>', []]
        });
        expect(
          () => buildTypedValue(context),
          throwsA(isA<TypedValueRehydrationException>().having(
            (e) => e.message,
            'message',
            contains('Input is not a map structure'),
          )),
        );
      });

      test(
          'should throw TypedValueRehydrationException for failing Map rehydration',
          () {
        // Use a map with an int key that can't be parsed from 'A'
        final context = StagerContext(const {
          'value': [
            'Map<int, String>',
            {'A': 'val'}
          ]
        });
        expect(
          () => buildTypedValue(context),
          throwsA(isA<TypedValueRehydrationException>().having(
            (e) => e.message,
            'message',
            contains('Failed to rehydrate Map<int, String>'),
          )),
        );
      });
    });

    group('buildTypedValue Collection Rehydration', () {
      test('should rehydrate List<String>', () {
        final context = StagerContext(const {
          'value': [
            'List<String>',
            ['a', 'b']
          ]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<List<String>>>());
        expect(result.value, ['a', 'b']);
      });

      test('should rehydrate List<Object>', () {
        final context = StagerContext(const {
          'value': [
            'List<Object>',
            [1, 'a', 3.14]
          ]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<List<Object>>>());
        expect(result.value, [1, 'a', 3.14]);
      });

      test('should rehydrate List<int>', () {
        final context = StagerContext(const {
          'value': [
            'List<int>',
            [1, '2']
          ]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<List<int>>>());
        expect(result.value, [1, 2]);
      });

      test('should rehydrate List<double>', () {
        final context = StagerContext(const {
          'value': [
            'List<double>',
            [1, 2.5, "3.14"]
          ]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<List<double>>>());
        expect(result.value, [1.0, 2.5, 3.14]);
      });

      test('should rehydrate List<bool>', () {
        final context = StagerContext(const {
          'value': [
            'List<bool>',
            [true, 'false']
          ]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<List<bool>>>());
        expect(result.value, [true, false]);
      });

      test('should rehydrate Map<String, Object>', () {
        final context = StagerContext(const {
          'value': [
            'Map<String, Object>',
            {'a': 1, 'b': '2'}
          ]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<Map<String, Object>>>());
        expect(result.value, {'a': 1, 'b': '2'});
      });

      test('should rehydrate Map<String, int>', () {
        final context = StagerContext(const {
          'value': [
            'Map<String, int>',
            {'a': 1, 'b': '2'}
          ]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<Map<String, int>>>());
        expect(result.value, {'a': 1, 'b': 2});
      });

      test('should rehydrate Map<String, double>', () {
        final context = StagerContext(const {
          'value': [
            'Map<String, double>',
            {'a': 1.1, 'b': '2.2'}
          ]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<Map<String, double>>>());
        expect(result.value, {'a': 1.1, 'b': 2.2});
      });

      test('should rehydrate Map<String, bool>', () {
        final context = StagerContext(const {
          'value': [
            'Map<String, bool>',
            {'a': true, 'b': 'false'}
          ]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<Map<String, bool>>>());
        expect(result.value, {'a': true, 'b': false});
      });

      test('should rehydrate Map<int, int>', () {
        final context = StagerContext(const {
          'value': [
            'Map<int, int>',
            {'1': 10, 2: '20'}
          ]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<Map<int, int>>>());
        expect(result.value, {1: 10, 2: 20});
      });

      test('should rehydrate Map<int, double>', () {
        final context = StagerContext(const {
          'value': [
            'Map<int, double>',
            {'1': 10.5, 2: '20.5'}
          ]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<Map<int, double>>>());
        expect(result.value, {1: 10.5, 2: 20.5});
      });

      test('should rehydrate Map<int, bool>', () {
        final context = StagerContext(const {
          'value': [
            'Map<int, bool>',
            {'1': true, 2: 'false'}
          ]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<Map<int, bool>>>());
        expect(result.value, {1: true, 2: false});
      });

      test('should rehydrate Map<bool, String>', () {
        final context = StagerContext(const {
          'value': [
            'Map<bool, String>',
            {'true': 'A', false: 'B'}
          ]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<Map<bool, String>>>());
        expect(result.value, {true: 'A', false: 'B'});
      });

      test('should rehydrate Map<bool, int>', () {
        final context = StagerContext(const {
          'value': [
            'Map<bool, int>',
            {'true': 1, false: '0'}
          ]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<Map<bool, int>>>());
        expect(result.value, {true: 1, false: 0});
      });

      test('should rehydrate Map<bool, double>', () {
        final context = StagerContext(const {
          'value': [
            'Map<bool, double>',
            {'true': 1.0, false: '0.0'}
          ]
        });
        final result = buildTypedValue(context);
        expect(result, isA<TypedValue<Map<bool, double>>>());
        expect(result.value, {true: 1.0, false: 0.0});
      });

      test('should throw for malformed collection element', () {
        final context = StagerContext(const {
          'value': [
            'List<int>',
            [1, "not_an_int"]
          ]
        });
        expect(
          () => buildTypedValue(context),
          throwsA(isA<TypedValueRehydrationException>().having(
            (e) => e.message,
            'message',
            contains('Failed to rehydrate List<int>'),
          )),
        );
      });
    });

    test('Map serialization', () {
      // Initialize a concrete leaf node.
      final ConcreteLeafNode leaf = ConcreteLeafNode(name: 'testLeaf');

      // Add diverse properties to verify broad rehydration support.
      leaf.setProperty('scale', TypedValue<double>(0.5));
      leaf.setProperty('count', TypedValue<int>(10));
      leaf.setProperty('active', TypedValue<bool>(true));
      leaf.setProperty('coords', TypedValue<List<double>>([1.0, 2.0]));
      leaf.setProperty('meta', TypedValue<Map<String, String>>({'key': 'val'}));

      // Wrap the leaf in a TypedValue and create its map representation.
      final TypedValue<ConcreteLeafNode> typedLeaf =
          TypedValue<ConcreteLeafNode>(leaf);
      final Map<String, Object> testTypedMap = {'root': typedLeaf.toTuple()};

      // Define an expected map structure for visual/manual comparison.
      final Map<String, Object> testMap = {
        'root': [
          'ConcreteLeafNode',
          {
            'name': 'testLeaf',
            'id': ['UuidValue', leaf.id.toString()],
            'position': ['Point', leaf.position.toMap()],
            'scale': ['double', 0.5],
            'count': ['int', 10],
            'active': ['bool', true],
            'coords': ['List<double>', [1.0, 2.0]],
            'meta': ['Map<String, String>', {'key': 'val'}]
          }
        ]
      };

      // Retrieve the property map from the node.
      final leafPropMap = leaf.toMap();

      print('Original Property Map: $leafPropMap');
      print("Typed Leaf Map: $testTypedMap");
      print("Visual Expected Map: $testMap");

      // Dehydration: Flatten the property map into a serializable entry map.
      final Map<String, Object> entryMap = {};
      for (final entry in leafPropMap.entries) {
        if (entry.value is TypedValue) {
          entryMap[entry.key] = (entry.value as TypedValue).toTuple();
        } else {
          entryMap[entry.key] = entry.value;
        }
      }
      print("Serialized Entry Map (Dehydrated): $entryMap");

      // Rehydration: Reconstruct the property map using buildTypedValue.
      final reifiedMap = <String, Object>{};
      for (final entry in entryMap.entries) {
        // Create a StagerContext from the dehydrated map entry.
        // For tuples, we wrap it in a Map with the 'value' key to match
        // buildTypedValue's expectations.
        final context = StagerContext({'value': entry.value});

        // Rehydrate the TypedValue using the centralized builder function.
        // We only test the rehydration of TypedValue supported types here.
        if (entry.key != 'id' && entry.key != 'position' && entry.key != 'name') {
          final reifiedTypedValue = buildTypedValue(context);
          reifiedMap[entry.key] = reifiedTypedValue;
        } else {
          // Skip id, position and name as they are either raw or use custom
          // builders not yet registered in buildTypedValue's internal map.
          reifiedMap[entry.key] = leafPropMap[entry.key]!;
        }
      }

      print('Rehydrated Map: $reifiedMap');

      // Verify that the rehydration cycle is lossless and produces equal maps.
      expect(leafPropMap, reifiedMap);
    });

    test("toString() and toJson()", () {
      final testValue = TypedValue<double>(1.0);
      // The TypedValue class considers these equivalent
      expect(testValue.toString(), testValue.toTuple().toString());
      expect(testValue.toJson(), testValue.toTuple());
    });
  });
}
