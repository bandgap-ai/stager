// test/src/hello_test_cases.dart
import 'package:source_gen_test/annotations.dart';
import 'package:stager_platform/system/hello.dart'; // Import your @hello annotation

// 1. Define the exact string you expect your code_builder to output.
// NOTE: It must match the exact formatting of DartFormatter!
@ShouldGenerate(
  '''const String helloTestClass = 'Hello World from TestClass!';\n''',
)
@hello
class TestClass {}

@ShouldGenerate(
  '''const String helloAnotherClass = 'Hello World from AnotherClass!';\n''',
)
@hello
class AnotherClass {}