import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:code_builder/code_builder.dart' hide LibraryBuilder;
import 'package:dart_style/dart_style.dart';

import '../system/hello.dart';

Builder helloBuilder(BuilderOptions options) {
  return LibraryBuilder(HelloGenerator(), generatedExtension: '.hello.dart');
}

class HelloGenerator extends GeneratorForAnnotation<Hello> {
  @override
  String generateForAnnotatedElement(
      Element2 element, ConstantReader annotation, BuildStep buildStep) {

    // 1. Define the code structure
    final helloVariable = Field((b) => b
      ..name = 'hello${element.name3}'
      ..modifier = FieldModifier.constant
      ..type = refer('String')
      ..assignment = Code("'Hello World from ${element.name3}!'")
    );

    // 2. Emit it to a String
    final emitter = DartEmitter();
    final rawCode = '${helloVariable.accept(emitter)}';

    // 3. (Optional but recommended) Run it through the official Dart formatter
    return DartFormatter(languageVersion: DartFormatter.latestLanguageVersion).format(rawCode);

  }
}