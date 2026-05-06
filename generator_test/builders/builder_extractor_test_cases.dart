import 'package:source_gen_test/annotations.dart';
import 'package:stager_platform/builders/basic_builder.dart';
import 'package:stager_platform/system/stager_context.dart';

// Dummy class to act as our resolved 'T' type
class AwesomeNode {}

// Test 1: Valid top-level function extraction
@BasicBuilder(name: 'AwesomeNode')
AwesomeNode buildAwesome(StagerContext context) => AwesomeNode();

// Test 2: Validation check (Applying annotation to a class instead of a function)
@ShouldThrow(
  '@BasicBuilder can only be applied to top-level functions or static methods.',
)
@BasicBuilder(name: 'InvalidClassNode')
class InvalidClassNode {}