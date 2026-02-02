# KML Integration Design Plan - 2026-01-31

## Status
Implemented

All features were initially implemented on 20260201. A revision was opened on 20260202 to extend the
implementation to include a reach feature set for the KML nodes. That revision was closed after the
review of the 7th audit determined that the complexity of rebuilding the KML node architecture
warranted a new design plan.

## Context & Background
The Stager Platform requires a mechanism to import and manage hierarchical GIS data. KML (Keyhole Markup Language) is an industry-standard format whose folder-based structure aligns naturally with Stager's Composite tree architecture. This plan leverages native validation and a custom parser to bridge KML files into the Stager tree.

## Goals
*   Map KML hierarchy (`Document` -> `Folder` -> `Placemark`) to Stager's concrete tree nodes.
*   Implement a robust, iterative (non-recursive) parser for KML data.
*   Support core geometries: Point, LineString, and Polygon.
*   Integrate KML attributes and styles into `NodeProperties`.

## Exclusions
*   KML validation is provided via a federated plugin, [Stager Platform Native Plugins](https://gitlab.com/bandgap/stager-platform/stager_platform_native_plugins), and will not be reimplemented here.
*   Full support for advanced KML features like `NetworkLink`, `TimeSpan`, or complex `StyleMap` state transitions.
*   Write support (editing Stager nodes and serializing back to KML).
*   High-performance streaming (SAX) parsing for multi-gigabyte files (rudimentary DOM-based parsing is the initial target).

## Proposed Design
The integration uses a multi-layered approach:
1.  **Validation Layer**: Uses `KMLFile` to invoke native plugins for XSD validation. Refactored to throw `KMLValidationException` instead of returning error codes.
2.  **Node Layer**: Specialized subclasses of the Stager concrete hierarchy:
    *   `KmlTreeRootNode` extends `ConcreteTreeNode`.
    *   `KmlFolderNode` extends `ConcreteCompositeNode`.
    *   `KmlPlacemarkNode` extends `ConcreteLeafNode`.
3.  **Parsing Layer**: `KmlParser` uses the `xml` package to traverse the validated DOM and construct the node tree iteratively.

## Alternatives Considered
*   **GeoJSON**: Rejected because it is a flat format and doesn't natively represent the hierarchical relationships (folders/nesting) that are central to the Stager Platform.
*   **GeoPackage**: Rejected for the initial implementation due to the complexity of relational database mapping compared to the direct hierarchical mapping offered by KML.

## Reviews & Audits
An initial audit identified the following risks and required corrections:
*   **Race Condition**: `KMLFile.load()` was identified as asynchronous without being awaited, potentially leading to validation failures if the plugin reads schemas before they are written.
*   **Recursion Violation**: KML's nested structure invites recursive parsing, which violates the project's "No Recursion" rule. The parser must be strictly iterative.
*   **Coordinate Inversion**: KML uses `Longitude, Latitude` order, while Stager uses `Latitude, Longitude`. The parser must explicitly handle this swap.
*   **Memory Pressure**: DOM-based parsing loads the entire file into memory; a size limit or warning should be considered for mobile targets.

### Second Audit - 2026-01-31
*   **Style Strategy**: The "Open Questions" regarding Style resolution (#75) presents a risk to the implementation timeline. A baseline support level (e.g., inline styles only for V1) should be defined to avoid scope creep.
*   **Root Element Handling**: Question #76 (missing `<Document>`) must be addressed. The parser should support a raw `<kml>` root containing direct children, treating them as if they were in a default Document or Folder.
*   **Error Reporting**: The plan implies returning `null` on failure (`final KmlTreeRootNode? root`), but does not specify how specific validation or parsing errors are communicated to the caller (e.g., exceptions, error listeners, or a result object).
*   **Ticket Granularity**: Ticket #83 ("Implement KML specialized node subclasses") covers multiple files now that "1 class per file" is mandated. Consider breaking this into sub-tasks or ensuring the PR enforces the file separation.

### Third Audit - 2026-01-31
*   **Obsolete Open Questions**: The "Open Questions" section (#75, #76) has been fully addressed by the new "Implementation Details". The section should be removed to clear up the documentation.
*   **Style Scope Clarification**: The plan explicitly defers *shared* style definitions, but the "Goals" section still lists integrating styles. Validating whether *inline* styles are supported in V1 would clarify the scope against the goal.

### Fourth Audit - 2026-01-31
*   **Missing Style Class**: Accessing style properties via raw maps constitutes a type-safety risk. A dedicated `KMLStyle` data class is required to encapsulate style attributes (LineStyle, PolyStyle, IconStyle) before they are mapped to NodeProperties.
*   **Style Management Architecture**: To avoid two-pass parsing while supporting forward references (style URLs pointing to styles defined later in the file), a `KMLStyleManager` is required.
*   **Deferred Resolution**: The parser must store the style ID string during tree construction and resolve it to a `KMLStyle` object from the manager only when the property is requested. This enables a single-pass parse without strict definition order.

### Fifth Audit - 2026-01-31
*   **Null-Safety and Default Styles**: The current reliance on nullable fields for style attributes increases the risk of runtime errors in rendering logic. The architecture should move to non-nullable types with spec-compliant defaults (e.g., color `0xffffffff`, width `1.0`).
*   **Composition Over Inheritance for Styles**: While `IconStyle`, `LineStyle`, and `PolyStyle` could be subclasses, they are better modeled as components of a `KmlStyle` container. KML `<Style>` elements can contain one of each simultaneously, making composition more idiomatic and type-safe.

### Sixth Audit - 2026-01-31
*   **Primitive Return Codes**: `KMLFile.validate()` currently returns an `int`. This is a low-level implementation detail that should be abstracted. The API should move to a `Future<void>` that throws specific exceptions.
*   **API Ergonomics**: Requiring the user to call `validate()` before `parse()` is error-prone. `parse()` should automatically trigger validation.
*   **Method Naming**: `load()` is ambiguous. It should be renamed to `prepareSchemas()` to clearly indicate it is setting up the environment for native validation.

### Seventh Audit - 2026-02-02
*   **Baseline Feature Support**: An audit of the initial implementation reveals the following support status for key KML elements:
    *   **KML Documents & Folders**: Fully supported and mapped to `KMLTreeRootNode` and `KMLFolderNode`.
    *   **Placemarks**: Fully supported and mapped to `KMLPlacemarkNode`.
    *   **Paths (LineStrings)**: Supported with correct `Lon,Lat -> Lat,Lon` coordinate swapping and stored in the `outline` property.
    *   **Polygons**: Partially supported; only the outer boundary (`outerBoundaryIs`) is captured. Inner holes (`innerBoundaryIs`) are currently ignored.
    *   **Ground Overlays**: Not supported in the current implementation.

## Implementation Details

The implementation is largely contained in the following files:
*   **`lib/mapping/kml_file.dart`**: 
    *   Rename `load()` to `prepareSchemas()`.
    *   Refactor `validate()` to return `Future<void>` and throw `KMLValidationException` on failure.
    *   Enhance `parse()` to automatically call `validate()`.
    *   Ensure all errors are logged using the `Logger` package.
*   **`lib/mapping/nodes/`**: Create the specialized KML node subclasses. Each node type must be implemented in its own file.
*   **`lib/mapping/style/kml_style.dart`**: Create a data class to strongly type KML style attributes.
*   **`lib/mapping/style/kml_style_manager.dart`**: Create a manager to register styles and handle lookup.
*   **`lib/mapping/kml_parser.dart`**: Implement iterative parser. usage:
    *   Register all `<Style>` elements with `KMLStyleManager` as they are encountered.
    *   Pass the `KMLStyleManager` and raw style ID string to KML element constructors.
    *   **Deferred Resolution**: `KmlPlacemarkNode` retrieves the `KMLStyle` from the manager lazily (e.g. in a getter or property accessor) to support forward references.
*   **`lib/stager.dart`**: Update exports to include the new KML support in the public API.

If a KML file does not contain a `<Document>` element, the children contained in that folder or root are added to a default Document in Stager.

KMLParser (kml_parser.dart) does not return null on failure. Instead, it throws an exception and logs the reason for the load failure using a logger from the Logger package.

## Testing Plan
*   **Unit Tests**:
    *   Create a separate test file for each KML node type.
    *   `test/mapping/kml_parser_test.dart`: Test coordinate parsing, longitude/latitude swapping, and iterative hierarchy building.
    *   `test/tree/kml_visitor_verification_test.dart`: Verify that the type-erased `NodeVisitor` correctly identifies and extracts data from KmlPlacemarkNodes.
*   **Integration Tests**:
    *   `test/mapping/kml_file_test.dart`: End-to-end test from native validation to Stager tree generation.

## Short Example
```dart
final kmlFile = KMLFile(kmlXMLLocation: 'path/to/map_data.kml');

try {
  // Setup native environment (only needs to be done once per app session)
  await kmlFile.prepareSchemas();

  // Parse into a Stager tree root. Automatic validation occurs here.
  final KMLTreeRootNode root = await kmlFile.parse();

  // Traverse the GIS data using standard visitors
  root.accept(myMapRenderingVisitor);
} on KMLValidationException catch (e) {
  print('Invalid KML: ${e.message}');
} catch (e) {
  print('Failed to parse KML file: $e');
}
```

This example is encoded in [the KML integration test](../test/mapping/kml_integration_test.dart).

## Open Questions

All questions were resolved in the audits.

## Tickets

- [Refactor KMLFile.load() to be asynchronous](https://gitlab.com/bandgap/stager-platform/stager/-/issues/5)
- [Implement KML specialized node subclasses (1 class per file & test)](https://gitlab.com/bandgap/stager-platform/stager/-/issues/6)
- [Implement iterative KmlParser](https://gitlab.com/bandgap/stager-platform/stager/-/issues/7)
- [Handle Longitude/Latitude coordinate swap in KmlParser](https://gitlab.com/bandgap/stager-platform/stager/-/issues/8)
- [Implement memory safety checks for KML parsing](https://gitlab.com/bandgap/stager-platform/stager/-/issues/9)
- [Update public API exports for KML support](https://gitlab.com/bandgap/stager-platform/stager/-/issues/10)
- [Create unit tests for KmlParser](https://gitlab.com/bandgap/stager-platform/stager/-/issues/11)
- [Create visitor verification test for KML nodes](https://gitlab.com/bandgap/stager-platform/stager/-/issues/12)
- [Create integration test for KMLFile](https://gitlab.com/bandgap/stager-platform/stager/-/issues/13)
- [Add KMLStyle and KMLStyleManager classes for handling KML styles](https://gitlab.com/bandgap/stager-platform/stager/-/issues/14)
