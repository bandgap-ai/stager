# KML Integration Design Plan - 2026-01-31

## Status
In Review

## Context & Background
The Stager Platform requires a mechanism to import and manage hierarchical GIS data. KML (Keyhole Markup Language) is an industry-standard format whose folder-based structure aligns naturally with Stager's Composite tree architecture. This plan leverages native validation and a custom parser to bridge KML files into the Stager tree.

## Goals
*   Implement native KML validation via a federated plugin to act as a gatekeeper.
*   Map KML hierarchy (`Document` -> `Folder` -> `Placemark`) to Stager's concrete tree nodes.
*   Implement a robust, iterative (non-recursive) parser for KML data.
*   Support core geometries: Point, LineString, and Polygon.
*   Integrate KML attributes and styles into `NodeProperties`.

## Exclusions
*   Full support for advanced KML features like `NetworkLink`, `TimeSpan`, or complex `StyleMap` state transitions.
*   Write support (editing Stager nodes and serializing back to KML).
*   High-performance streaming (SAX) parsing for multi-gigabyte files (rudimentary DOM-based parsing is the initial target).

## Proposed Design
The integration uses a multi-layered approach:
1.  **Validation Layer**: Uses `KMLFile` to invoke native plugins for XSD validation.
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

## Implementation Details
*   **`lib/mapping/kml_file.dart`**: Refactor `load()` to be asynchronous and ensure schema copying is completed before validation.
*   **`lib/mapping/kml_nodes.dart`**: Create the specialized KML node subclasses.
*   **`lib/mapping/kml_parser.dart`**: Implement the iterative stack-based parser.
*   **`lib/stager.dart`**: Update exports to include the new KML support in the public API.

## Testing Plan
*   **Unit Tests**:
    *   `test/mapping/kml_parser_test.dart`: Test coordinate parsing, longitude/latitude swapping, and iterative hierarchy building.
    *   `test/tree/kml_visitor_verification_test.dart`: Verify that the type-erased `NodeVisitor` correctly identifies and extracts data from KmlPlacemarkNodes.
*   **Integration Tests**:
    *   `test/mapping/kml_file_test.dart`: End-to-end test from native validation to Stager tree generation.

## Short Example
```dart
final kmlFile = KMLFile(kmlXMLLocation: 'path/to/map_data.kml');

// Load schemas and await completion
await kmlFile.load();

// Parse into a Stager tree root
final KmlTreeRootNode? root = await kmlFile.parse();

if (root != null) {
  // Traverse the GIS data using standard visitors
  root.accept(myMapRenderingVisitor);
  
  // Use ConcreteTreeNode's built-in summarization
  final summary = root.summarize();
  print('Map center: ${summary.centerPoint}');
}
```

## Open Questions
*   Should shared `Style` definitions be resolved during the first pass of parsing or on-demand by the rendering visitor?
*   How should we handle KML files with no `<Document>` element?

## Tickets

- [Add a log reader](https://gitlab.com/bandgap/stager-platform/stager/-/issues/4)
- [Refactor KMLFile.load() to be asynchronous](https://gitlab.com/bandgap/stager-platform/stager/-/issues/5)
- [Implement KML specialized node subclasses](https://gitlab.com/bandgap/stager-platform/stager/-/issues/6)
- [Implement iterative KmlParser](https://gitlab.com/bandgap/stager-platform/stager/-/issues/7)
- [Handle Longitude/Latitude coordinate swap in KmlParser](https://gitlab.com/bandgap/stager-platform/stager/-/issues/8)
- [Implement memory safety checks for KML parsing](https://gitlab.com/bandgap/stager-platform/stager/-/issues/9)
- [Update public API exports for KML support](https://gitlab.com/bandgap/stager-platform/stager/-/issues/10)
- [Create unit tests for KmlParser](https://gitlab.com/bandgap/stager-platform/stager/-/issues/11)
- [Create visitor verification test for KML nodes](https://gitlab.com/bandgap/stager-platform/stager/-/issues/12)
- [Create integration test for KMLFile](https://gitlab.com/bandgap/stager-platform/stager/-/issues/13)
