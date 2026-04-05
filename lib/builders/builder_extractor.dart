import 'dart:convert';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'basic_builder.dart';

/// A custom builder that outputs pure JSON metadata.
class JsonMetadataBuilder implements Builder {
  final Generator generator;
  final String extension;

  JsonMetadataBuilder(this.generator, this.extension);

  @override
  Map<String, List<String>> get buildExtensions => {
    '.dart': [extension]
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    // 1. Get the library for the current input file
    final library = await buildStep.resolver.libraryFor(buildStep.inputId);

    // 2. Use source_gen's LibraryReader to run our extractor
    final output = await generator.generate(LibraryReader(library), buildStep);

    // 3. Only write if the generator actually produced something
    if (output!.isNotEmpty) {
      await buildStep.writeAsString(
        buildStep.inputId.changeExtension(extension),
        output,
      );
    }
  }
}

Builder builderExtractor(BuilderOptions options) {
  // Output hidden JSON files into the build cache using our custom builder
  return JsonMetadataBuilder(BuilderExtractor(), '.builder.info');
}

class BuilderExtractor extends GeneratorForAnnotation<BasicBuilder> {
  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {

    // 1. Ensure they only annotated a function or method
    if (element is! ExecutableElement) {
      throw InvalidGenerationSourceError(
        '@BasicBuilder can only be applied to functions or static methods.',
        element: element,
      );
    }

    // 2. Extract the name (fallback to the function name if not explicitly provided)
    final explicitName = annotation.peek('name')?.stringValue;
    final builderName = explicitName ?? element.name;

    // 3. Extract the 'T' by looking at what the function returns!
    final returnType = element.returnType.getDisplayString(withNullability: false);

    // 4. Package it up for Pass 2
    final nodeData = {
      'name': builderName,
      'type': returnType,
      'delegate': element.name,
      'importPath': buildStep.inputId.uri.toString(),
    };

    return jsonEncode(nodeData);
  }
}