import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/builders/basic_builder.dart';
import 'package:stager_platform/builders/stager_context.dart';

/// Unit tests for [BasicBuilder] and [BasicBuilderHandler].
void main() {
  group('BasicBuilder Tests', () {
    test('should initialize with the provided name', () {
      const builder = BasicBuilder(name: 'MyBuilder');
      expect(builder.name, 'MyBuilder');
    });
  });

  group('BasicBuilderHandler Tests', () {
    test('should initialize with the correct name and type', () {
      // This is a simple builder that returns the string 'built_value'
      final handler = BasicBuilderHandler<String>(
        name: 'test_builder',
        delegate: (context) => 'built_value',
      );
      expect(handler.name, 'test_builder');
      expect(handler.type, String);
    });

    test('should return the object created by the delegate function', () {
      // This is a simple builder that returns the answer to life, the universe,
      // and everything when the builder delegate function is called.
      final handler = BasicBuilderHandler<int>(
        name: 'int_builder',
        delegate: (context) => 42,
      );
      final result = handler.build();
      expect(result, 42);
    });

    test('should correctly pass the context map to the delegate', () {
      // Simple context with basic map of properties
      StagerContext context = StagerContext({'input': 'hello_world'});
      // The builder function simply returns the value of the 'input' property
      // from the context.
      final handler = BasicBuilderHandler<String>(
        name: 'context_builder',
        delegate: (context) => context.get('input') as String,
      );
      final result = handler.build(context);
      expect(result, 'hello_world');
    });

    test('should use an empty map as the default context', () {
      // Arrange
      bool contextWasEmpty = false;
      final handler = BasicBuilderHandler<void>(
        name: 'empty_context_tester',
        delegate: (context) {
          contextWasEmpty = context.isEmpty();
        },
      );
      handler.build();
      expect(contextWasEmpty, isTrue);
    });
  });
}
