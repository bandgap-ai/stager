import 'dart:convert';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';
import 'package:stager_platform/builders/builder_compiler.dart';

void main() {
  group('BuilderCompiler Tests', () {
    test('aggregates multiple JSON files into a single registry', () async {
      // 1. Define the mock intermediate JSON files in the "cache".
      final sourceFiles = {
        'stager_platform|lib/node_a.builder.info':
            '{"name":"NodeA","type":"String","delegate":"buildA","importPath":"package:stager_platform/node_a.dart"}',
        'stager_platform|lib/node_b.builder.info':
            '{"name":"NodeB","type":"int","delegate":"buildB","importPath":"package:stager_platform/node_b.dart"}',
        // A file with multiple JSON lines.
        'stager_platform|lib/multi.builder.info':
            '{"name":"NodeC","type":"double","delegate":"buildC","importPath":"package:stager_platform/multi.dart"}\n'
            '{"name":"NodeD","type":"bool","delegate":"buildD","importPath":"package:stager_platform/multi.dart"}',
      };

      // 2. Dynamically derive the expected substrings from the source files.
      // This ensures the test doesn't need manual updates when builders are
      // added or modified in the mock data.
      final expectedSubstrings = [
        "import 'package:stager_platform/builders/basic_builder.dart';",
        "final List<BasicBuilderHandler<dynamic>> _generatedBuilders = [",
        "final Map<Type, BasicBuilderHandler<dynamic>> stagerRegistryMap = {",
        "for (final builder in _generatedBuilders) builder.type: builder,",
      ];

      for (final content in sourceFiles.values) {
        final lines = content.split('\n');
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;

          final json = jsonDecode(trimmed) as Map<String, dynamic>;
          final type = json['type'] as String;
          final name = json['name'] as String;
          final delegate = json['delegate'] as String;
          final importPath = json['importPath'] as String;

          expectedSubstrings.add("import '$importPath';");
          expectedSubstrings.add(
            "BasicBuilderHandler<$type>(name: '$name', delegate: $delegate)",
          );
        }
      }

      // 3. Define the expected output registry file using the dynamic list.
      final expectedOutput = {
        'stager_platform|lib/stager_registry.g.dart':
            decodedMatches(containsAll(expectedSubstrings)),
      };

      // 4. Run the compiler using synthetic $lib$ input.
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
