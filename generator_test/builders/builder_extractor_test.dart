import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:stager_platform/builders/builder_extractor.dart';

void main() {
  group('BuilderExtractor Tests', () {
    test('extracts metadata to JSON correctly', () async {
      // 1. Define the mock source files
      final sourceFiles = {
        'stager_platform|lib/builders/basic_builder.dart': '''
class BasicBuilder {
  final String? name;
  const BasicBuilder({this.name});
}
''',
        'stager_platform|lib/builders/stager_context.dart': '''
class StagerContext {}
''',
        // The mock node we are testing
        'stager_platform|lib/test_node.dart': '''
import 'package:stager_platform/builders/basic_builder.dart';
import 'package:stager_platform/builders/stager_context.dart';

class AwesomeNode {}

@BasicBuilder(name: 'AwesomeNode')
AwesomeNode buildAwesome(StagerContext context) => AwesomeNode();
'''
      };

      // 2. Define the exact JSON string we expect to be generated.
      // Thanks to JsonMetadataBuilder, it is pure JSON without comment headers!
      final expectedOutput = {
        'stager_platform|lib/test_node.builder.info':
            '{"name":"AwesomeNode","type":"AwesomeNode","delegate":"buildAwesome","importPath":"package:stager_platform/test_node.dart"}'
      };

      // 3. Run the builder pipeline in memory
      await testBuilder(
        // We can now directly use your exported factory function!
        builderExtractor(BuilderOptions.empty),
        sourceFiles,
        outputs: expectedOutput,
      );
    });

    test('extracts multiple annotations from a single file', () async {
      final sourceFiles = {
        'stager_platform|lib/builders/basic_builder.dart': '''
class BasicBuilder {
  final String? name;
  const BasicBuilder({this.name});
}
''',
        'stager_platform|lib/builders/stager_context.dart': '''
class StagerContext {}
''',
        'stager_platform|lib/multi_node.dart': '''
import 'package:stager_platform/builders/basic_builder.dart';
import 'package:stager_platform/builders/stager_context.dart';

@BasicBuilder(name: 'NodeA')
String buildA(StagerContext c) => 'A';

@BasicBuilder(name: 'NodeB')
String buildB(StagerContext c) => 'B';
'''
      };

      // source_gen's GeneratorForAnnotation joins multiple generated chunks
      // with a single newline by default.
      final expectedOutput = {
        'stager_platform|lib/multi_node.builder.info':
            '{"name":"NodeA","type":"String","delegate":"buildA","importPath":"package:stager_platform/multi_node.dart"}\n\n'
            '{"name":"NodeB","type":"String","delegate":"buildB","importPath":"package:stager_platform/multi_node.dart"}'
      };

      await testBuilder(
        builderExtractor(BuilderOptions.empty),
        sourceFiles,
        outputs: expectedOutput,
      );
    });

    test('throws error on invalid annotation target (class)', () async {
      final sourceFiles = {
        'stager_platform|lib/builders/basic_builder.dart': '''
class BasicBuilder {
  final String? name;
  const BasicBuilder({this.name});
}
''',
        'stager_platform|lib/invalid_node.dart': '''
import 'package:stager_platform/builders/basic_builder.dart';

@BasicBuilder(name: 'InvalidClassNode')
class InvalidClassNode {}
'''
      };

      final logs = <LogRecord>[];

      // testBuilder swallows generator exceptions and logs them instead of throwing.
      // We pass an onLog callback to capture the build logs.
      await testBuilder(
        builderExtractor(BuilderOptions.empty),
        sourceFiles,
        onLog: logs.add,
      );

      // Verify that the builder logged our exact InvalidGenerationSourceError message
      expect(
        logs,
        contains(predicate<LogRecord>((record) =>
            record.level >= Level.SEVERE &&
            record.message.contains(
                '@BasicBuilder can only be applied to functions or static methods.'))),
        reason:
            'Builder should log a SEVERE error for invalid annotation targets.',
      );
    });
  });
}
