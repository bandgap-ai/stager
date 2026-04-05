import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';
import 'package:stager_platform/builders/builder_compiler.dart';

void main() {
  group('BuilderCompiler Tests', () {
    test('aggregates multiple JSON files into a single registry', () async {
      // 1. Define the mock intermediate JSON files in the "cache"
      final sourceFiles = {
        'stager_platform|lib/node_a.builder.info':
            '{"name":"NodeA","type":"String","delegate":"buildA","importPath":"package:stager_platform/node_a.dart"}',
        'stager_platform|lib/node_b.builder.info':
            '{"name":"NodeB","type":"int","delegate":"buildB","importPath":"package:stager_platform/node_b.dart"}',
        // A file with multiple JSON lines
        'stager_platform|lib/multi.builder.info':
            '{"name":"NodeC","type":"double","delegate":"buildC","importPath":"package:stager_platform/multi.dart"}\n'
            '{"name":"NodeD","type":"bool","delegate":"buildD","importPath":"package:stager_platform/multi.dart"}',
      };

      // 2. Define the expected output registry file
      final expectedOutput = {
        'stager_platform|lib/stager_registry.g.dart': decodedMatches(containsAll([
          "import 'package:stager_platform/builders/basic_builder.dart';",
          "import 'package:stager_platform/multi.dart';",
          "import 'package:stager_platform/node_a.dart';",
          "import 'package:stager_platform/node_b.dart';",
          "final List<BasicBuilderHandler<dynamic>> _generatedBuilders = [",
          "BasicBuilderHandler<String>(name: 'NodeA', delegate: buildA)",
          "BasicBuilderHandler<int>(name: 'NodeB', delegate: buildB)",
          "BasicBuilderHandler<double>(name: 'NodeC', delegate: buildC)",
          "BasicBuilderHandler<bool>(name: 'NodeD', delegate: buildD)",
          "final Map<Type, BasicBuilderHandler<dynamic>> stagerRegistry = {",
          "for (final builder in _generatedBuilders) builder.type: builder,",
        ])),
      };

      // 3. Run the compiler using synthetic $lib$ input
      await testBuilder(
        builderCompilerBuilder(BuilderOptions.empty),
        sourceFiles,
        outputs: expectedOutput,
      );
    });

    test('does not generate a registry if no builder info is found', () async {
      final sourceFiles = {
        'stager_platform|lib/some_other_file.txt': 'Not a builder info file',
      };

      await testBuilder(
        builderCompilerBuilder(BuilderOptions.empty),
        sourceFiles,
        outputs: {}, // No outputs expected
      );
    });
  });
}

/// Helper to check if the decoded string contains all expected substrings.
Matcher containsAll(List<String> substrings) {
  return predicate<String>((String actual) {
    for (final s in substrings) {
      if (!actual.contains(s)) {
        return false;
      }
    }
    return true;
  }, 'contains all of ${substrings.join(', ')}');
}
