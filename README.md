# The Stager Platform

[![pipeline status](https://gitlab.com/bandgap/stager-platform/stager/badges/main/pipeline.svg)](https://gitlab.com/bandgap/stager-platform/stager/-/commits/main)
[![coverage report](https://gitlab.com/bandgap/stager-platform/stager/badges/main/coverage.svg)](https://gitlab.com/bandgap/stager-platform/stager/-/commits/main)
[![SonarQube Cloud](https://sonarcloud.io/summary/new_code?id=bandgap_stager)](https://sonarcloud.io/summary/new_code?id=bandgap_stager)

Stager is a sophisticated Flutter and Dart framework designed to manage and
"stage" complex UI components and data structures. It provides a robust
architecture for hierarchical data management, specifically optimized for GIS
workflows and tree-based state manipulation. By distinguishing clearly between
display-only widgets and data-modifying editors, Stager ensures a clean
separation of concerns while offering high-level tools for dynamic component
registration and geographic data ingestion.

## Project Architecture

The core implementation resides within the `lib/` directory, which is organized
into specialized modules to handle different aspects of the platform's
lifecycle. Dynamic construction is managed by the `builders` module, which
leverages code generation for factory registration. Data models and sample sets
are housed in the `data` module, while the `tree` module provides the
foundational hierarchical structures. User interaction is split between the
`editors` module for data modification and the `mapping` module for
GIS-specific visualizations and adapters. Supporting these features are the
`persistence` layer for state storage, `providers` for external service
abstractions, and `system` services for global concerns like selection
brokerage.

Detailed design specifications, technical roadmaps, and integration guides are
maintained in the `doc/` directory. This includes comprehensive plans for KML
data integration, map editor development, and the implementation of a
compile-time dynamic factory system to manage statefulness across different
platforms.

### `buildX()` versus `X.fromJson()`

Stager allows clients to dynamically register builder functions (see 
[`BasicBuilder`](lib/builders/basic_builder.dart) and its tests) using 
annotations akin to `@Provider` in Java. In Stager might look like

```
@BasicBuilder(name: 'DataBuilder')
DataBuilder buildDataBuilder(StagerContext context) {
    ... code to build a DataBuilder instance
}

class DataBuilder {
    ... DataBuilder implementation
}
```

We use this mechanism for "dynamically" (although there is little dynamic about
it...) building classes for several reasons. First, it works well with large
class hierarchies and generics. Second, it doesn't have the type restrictions
of factory constructors. Finally, it allows us to construct classes via a
lookup table created by the Dart code generator instead of hard-wiring the
necessary logic everywhere.

## Developer Workflow

Development on the Stager Platform is primarily driven through the included
`Makefile`, which abstracts the underlying Flutter and Dart CLI commands into a
consistent, cross-platform interface. This ensures that essential tasks like
dependency resolution, code generation, and testing are executed with the
correct flags regardless of the host operating system. Developers can build the
entire project and run all tests by executing

```bash
make all 
```

Developers can see the available make targets by simply executing `make` 
without any arguments.

### Specific Build Targets

The `make all` target executes the `generate`, `build`, and `test` sub-targets.
The `generate` target runs the Dart `build_runner` to process source
annotations, generate the master `stager_registry.g.dart` file and produce other
required artifacts. The `build` target only executes the normal Flutter build. 
The `analyze` target will run the Flutter analyzer.

### Executing Tests

All tests in the project can be executed by running

```bash
make test
```

Full verification of the codebase is split between standard Flutter tests and
specialized generator tests that must be run by `dart` to test the code 
generators. The `flutter_test` target will run the normal unit tests and the
`dart_test` target will run the tests for the code generators.

### Cleaning Up

There is a standard `clean` target and running `make clean` will mostly reset
the project to its initial state. However, there are situations where a deeper
clean is required, and there are notes in [AGENT_NOTES.md](AGENT_NOTES.md) from
20260405 describing that process.

## Running the Demonstration

A fully functional demonstration of the platform's capabilities is provided in
the `example/` directory. To compile and launch this application on the native
desktop platform of the host OS, execute the `run` target:

```bash
make run
```

## Technical Standards

Stager distinguishes between display-only **Widgets** and data-modifying
**Editors**. All editors are required to be `StatefulWidgets` to manage their
internal modification state, while display widgets are generally implemented as
`StatelessWidgets`. The project adheres to strict agentic coding standards,
which are documented in `AGENTS.md` and `AGENT_NOTES.md`. These standards
mandate a test-driven development (TDD) workflow, the use of the Single Return
Principle, and comprehensive documentation for all public and private
implementations.

## Continuous Integration

The Stager Platform utilizes GitLab CI/CD to ensure code quality and stability.
The pipeline is configured to use the same `Makefile` targets employed during
local development, guaranteeing consistency between the developer's environment
and the automated verification process. Every commit triggers a sequence that
includes:
*   **Generation**: Running `make generate` to recreate the dynamic factory
    registry.
*   **Analysis**: Executing `make analyze` to enforce static analysis rules.
*   **Testing**: Running both standard unit tests and specialized generator
    tests via `make dart_test`.
*   **Security**: Automated SAST and Secret Detection scans.
*   **Quality**: Integration with SonarCloud for deep code analysis and
    coverage reporting.

The quality analysis specifically monitors both the core implementation and the
demonstration code in the `example/` directory. Automated reports are
generated using the `lcov.info` standard to track test coverage across the
entire platform, ensuring that performance and reliability standards are
consistently met.
