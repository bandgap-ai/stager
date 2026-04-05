import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/builders/stager_context.dart';

void main() {

  group('Basic property tests for StagerContext', () {

    Map<String,Object> testProps = {'foo':'bar','meow':1};

    test('Check empty context', () {
      StagerContext testContext = StagerContext({});
      expect(testContext.isEmpty(), true);
    });

    test('Check basic get()', () {
      StagerContext testContext = StagerContext(testProps);
      expect(testContext.get<String>('foo'), 'bar');
      expect(testContext.get<int>('meow'), 1);
      expect(testContext.isEmpty(), false);
      // Check the text of the exception thrown by get() if the value isn't
      // defined for the key. This is wrapped in a closure so expect() can
      // catch the exception.
      expect(
            () => testContext.get<int>('nope'),
        throwsA(
          isA<StagerContextException>().having(
                (e) => e.toString(),
            'toString()',
            'StagerContextException: Key "nope" not found in context',
          ),
        ),
      );

    });

    test('Check getOrDefault()', () {
      StagerContext testContext = StagerContext(testProps);
      expect(testContext.getOrDefault<String>('foo', 'default'), 'bar');
      expect(testContext.getOrDefault<String>('nope', 'default'), 'default');
      expect(testContext.getOrDefault<int>('meow', 0), 1);
      expect(testContext.getOrDefault<int>('nope', 9), 9);
    });
  });
}