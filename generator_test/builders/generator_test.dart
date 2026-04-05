// test/generator_test.dart
import 'package:source_gen_test/source_gen_test.dart';
import 'package:stager_platform/builders/hello_builder.dart';

void main() async {
  // 1. Tell the test package where to find your mock classes
  final reader = await initializeLibraryReaderForDirectory(
    'generator_test/builders/',
    'hello_test_cases.dart',
  );

  // 2. Run the test suite against your generator
  initializeBuildLogTracking();
  testAnnotatedElements(
    reader,
    HelloGenerator(),
  );
}