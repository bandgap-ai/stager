# Dynamic Factory for Stager Platform - March 2026

## Status
Implemented.

## Context & Background
The Stager Platform requires a dynamic factory registry to instantiate
different Node types provided by downstream clients and plugins. Historically
(e.g., in Eclipse ICE), this was handled at runtime using OSGi Declarative
Services and reflection, allowing the framework to sweep the classpath for
classes extending `AbstractItemBuilder` (via the OSGi Whiteboard Pattern).

However, Flutter's aggressive "tree-shaking" compiler eliminates any code not
explicitly imported, and `dart:mirrors` (reflection) is disabled. Therefore, we
cannot scan a directory to pick up classes at runtime. To solve this, we must
build a compile-time OSGi-like framework using Dart's `build_runner`.

## Goals
* Implement a dynamic, extensible factory system for Stager Nodes.
* Allow downstream clients to register builders simply by annotating a factory
  function.
* Maintain a clean `lib/` directory for the user (no cluttering with hundreds
  of intermediate files).
* Ensure strict compile-time safety (no null builder names, fully reified
  generic types).
* Rely on Dart's delegation model instead of heavy subclassing (unlike
  Java/C++).

## Exclusions
* This design does NOT attempt to use runtime reflection or `dart:mirrors`.
* This design does NOT handle dynamic injection of uncompiled code at runtime.

## Proposed Design
The architecture is a Two-Pass Compile-Time Code Generation System:

### The Contract (`StagerBuilder` & `BasicBuilder<T>`)
* Users annotate top-level or static factory functions with
  `@StagerBuilder(name: 'MyNode')`.
* The framework uses a `BasicBuilder<T>` class that takes the user's function
  as a delegate, rather than forcing the user to write a heavy subclass.

### Pass 1: The Extractor (`BuilderExtractor`)
* A `source_gen` builder sweeps the codebase looking for `@StagerBuilder`.
* Instead of generating Dart classes that clutter the `lib/` folder, it
  generates invisible `.builder.info` JSON files in the `.dart_tool` cache
  containing metadata (name, return type, function name, import path).

### Pass 2: The Compiler (`BuilderCompiler`)
* A custom Builder runs after Pass 1.
* It sweeps up all `.builder.info` JSON files from the cache.
* It generates a single master `stager_registry.g.dart` file containing a
  `List<BasicBuilder<dynamic>>` and maps them by their reified Type.

## Alternatives Considered
* **Runtime Reflection**: Explored but rejected. `dart:mirrors` causes crashes
  in Flutter and defeats tree-shaking.
* **Generating Subclasses (Java/C++ Style)**: Explored generating individual
  `my_node.builder.dart` files that subclass an `AbstractNodeBuilder` (similar
  to ICE's `AbstractItemBuilder`). Rejected because it creates excessive
  boilerplate and pollutes the developer's source tree. Dart's first-class
  functions allow for a cleaner delegation model via JSON metadata.

## Reviews & Audits
### First Audit
* `auto_apply: dependents` in `build.yaml` works for downstream
  clients, but a local targets override is required so Stager can compile its
  own internal nodes.
### Second Audit
* Default parameters in Dart must be compile-time constants.
  Ensured `[Map<String, dynamic> context = const {}]` is used in the `build()`
  method.
### Third Audit
* **Collision Policy**: `Type` is the primary registry key. The `name` property
  is for UI/Persistence. `BuilderExtractor` should throw a `BuildStep` error if
  internal package collisions occur.
* **Import Strategy**: All generated imports in `stager_registry.g.dart` will
  use absolute `package:` URIs to ensure stability across file moves.
* **Member Support**: Support is limited to top-level functions and static
  class methods. Class methods require capturing the `ClassName` in metadata.
### Fourth Audit
* **Naming Inconsistency**: Conflicts existed between "Compiler" and
  "Combiner." Standardized to `BuilderCompiler`.
* **Ambiguity in Context**: Recommended moving from a raw `Map` to a formal
  `StagerContext`.
* **Function Scope**: Support for static member functions was deemed
  unnecessary if top-level functions are supported.
* **Phase Logic**: Corrected the `build.yaml` logic to ensure the extractor
  runs and completes before the compiler.
* **Generated Location**: Questioned the need for the generated registry to
  live in `lib/` versus `.dart_tool`.
### Fifth Audit
* **The Import Problem**: Generating the master registry to the cache 
  (`build_to: cache`) prevents the user from importing it without using a 
  `part` directive in an anchor file. This also prevents the `BuilderCompiler`
  from generating its own dynamic `import` statements for the discovered nodes.
* **Resolution**: The `BuilderCompiler` (Pass 2) will use `build_to: source` 
  to generate a single, self-contained `stager_registry.g.dart` file directly 
  into the user's `lib/` directory. This violates the strictest interpretation 
  of "zero clutter," but producing one file is the standard Dart community 
  practice (e.g., `auto_route`, `objectbox`) and solves the import problem.

## Implementation Details

The builder annotation is defined by [`BasicBuilder`](../../lib/builders/basic_builder.dart) and its
only required property is the name of the builder. The name and type are extracted during the code
generation process. Actual construction is delegated to 
[`BasicBuilderHandler`](../../lib/builders/basic_builder.dart). The annotation is simply 
`@BasicBuilder`. Note that only functions can be annotated, not classes, and multiple functions can
be annotated per file.

[`StagerContext`](../../lib/system/stager_context.dart) is a formal context class that holds build
properties and provides handy utilities for dynamically instantiating classes,
etc. It is created during the build process for each new builder. 

`BasicBuilders` are added to the factory by a two step code generation process. First, the functions
annotated with `@BasicBuilder` are extracted by the 
[`BuilderExtractor`](../../lib/builders/builder_extractor.dart) during the `build_runner` phase of 
the build. The extractor class uses a two step process as well: It extracts information from the 
Dart AST using `GeneratorForAnnotation`, which it extends, and a second, custom 
`JsonMetadataBuilder` polishes the response to create a well-formed output. This is necessary since
`GeneratorForAnnotation` attempts to generate Dart code, not JSON, and the initial generated result
cannot be easy processed. The `BuilderExtractor` automatically outputs `*.builder.info` files into
the cache based on its configuration in [build.yaml](../../build.yaml).

The extraction process performs a number of important checks, including verification that the
extracted element is executable, determining the underlying reified type `T` of the element created
by the builder, the name of the builder and the name of the builder function, and proper import 
location identification. 
See ['builder_extractor_test.dart'](../../generator_test/builders/builder_extractor_test.dart)) for
more information and examples on how this works.

The [`BuilderCompiler`](lib/builders/builder_compiler.dart) is implemented as a standard Builder 
that uses the glob package to read the generated JSON files and the code_builder package to write 
the final map. It uses the Dart Type as the primary key and verifies the uniqueness of the name 
property. This compiler restricts support to only top-level factory functions.

Finally, build.yaml is configured for both builders. The `stager_platform|builder_extractor` is 
configured to build to the cache (`build_to: cache`) and is set to run before the compiler 
(`runs_before: ["stager_platform|builder_compiler"]`). Meanwhile, `stager_platform|builder_compiler`
is configured to build to the source (`build_to: source`). This configuration ensures that the final
generated registry file will reside directly in the source tree, allowing for standalone imports 
without requiring part directives.

FACTORY NOW!!!! 

Implement the standard Builder using
  `glob` to read JSON and `code_builder` to write the final map. Use `Type` as
  the primary key and verify uniqueness of the `name` property. Only top-level
  factory functions are supported.
* `build.yaml`: Configure `stager_platform|builder_extractor`
  (`build_to: cache`, `runs_before: ["stager_platform|builder_compiler"]`) and
  `stager_platform|builder_compiler` (`build_to: source`). The generated file
  will reside in the user's source tree to allow for standalone imports.

## Testing Plan

### Unit Tests
* Test `BasicBuilder` to ensure the delegate function fires correctly and
  handles the `StagerContext`.
* Use `source_gen_test` to validate the `BuilderExtractor`. The
  `@ShouldGenerate` blocks will verify the exact JSON string output.

### Integration Tests
* Run `build_runner` on a dummy package to verify the two-pass system
  successfully emits the `stager_registry.g.dart` file.

## Short Example

### User Code
```dart
@StagerBuilder(name: 'AwesomeNode')
AwesomeNode buildAwesome(StagerContext context) => AwesomeNode();
```

### Generated Registry (`stager_registry.g.dart`)
```dart
final List<BasicBuilder<dynamic>> _generatedBuilders = [
  BasicBuilder<AwesomeNode>(name: 'AwesomeNode', delegate: buildAwesome),
];

final Map<Type, BasicBuilder<dynamic>> stagerRegistry = {
  for (final builder in _generatedBuilders) builder.type: builder,
};
```

## Open Questions
* None.

## Tickets

- [Implement StagerBuilder and StagerContext](https://gitlab.com/bandgap/stager-platform/stager/-/issues/52)
- [Implement BasicBuilder and Execution Tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/53)
- [Implement BuilderExtractor (Pass 1)](https://gitlab.com/bandgap/stager-platform/stager/-/issues/54)
- [Implement BuilderCompiler (Pass 2)](https://gitlab.com/bandgap/stager-platform/stager/-/issues/55)
- [Configure build.yaml and Project Integration](https://gitlab.com/bandgap/stager-platform/stager/-/issues/56)
- [Create Dynamic Factory Integration Tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/57)
- [Update Public API and Documentation](https://gitlab.com/bandgap/stager-platform/stager/-/issues/58)
