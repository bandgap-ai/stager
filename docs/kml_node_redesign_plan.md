# KML Node Redesign Plan - 20260202

## Status
Approved

## Context & Background

The current implementation of KML support in Stager is inadequate because it does not support a
minimally viable set of KML features. Namely, it does not support the independence of KML Folders
and Documents correctly, nor does it accurately represent the role of the KML Placemark as a
geometry aggregator. It also leaves out certain features, such as polygons and paths, that are
consider basic "table stakes" in a mapping application.

The purpose of this plan is to redesign and extend the support of KML features, geometry, 
iconography, and other critical components within Stager.

## Goals

* Implement a comprehensive type hierarchy that distinguishes between KML Features (containers) and Geometries (data).
* Enable KMLPlacemarkNode to serve as a geometry aggregator, supporting one or more KMLGeometryNode children.
* Provide full support for KMLPolygonNode with inner holes and KMLGroundOverlayNode with iconography.
* Establish a pattern of strongly-typed accessors for all KML-specific properties to eliminate "bare map" access risks.
* Ensure the new hierarchy is compatible with the KMLStylable mixin at the feature level.

## Exclusions
There are no exclusions at this time although the plan is only focused on KML and will not extend to
other tasks.

## Proposed Design

The new architecture will have the following type hierarchy:
- KMLTreeRootNode (extends ConcreteTreeNode)
- KMLFeatureNode (abstract, extends ConcreteCompositeNode) with accessors for visibility, snippet, extended data, etc., which are stored as node properties.
-- KMLDocumentNode (extends KMLFeatureNode with KMLStylable mixin)
-- KMLFolderNode (extends KMLFeatureNode)
-- KMLPlacemarkNode (extends KMLFeatureNode with KMLStylable mixin) with a property/getter to indicate if it contains a MultiGeometry (multiple geometry children).
- KMLGeometryNode (abstract, extends ConcreteLeafNode)
-- KMLPointNode (extends KMLGeometryNode)
-- KMLPathNode (LineString) (extends KMLGeometryNode)
-- KMLPolygonNode (extends KMLGeometryNode) with a `List<KMLHole>` property stored as a node property.
-- KMLGroundOverlayNode (extends KMLGeometryNode with KMLStylable mixin)
- StagerIcon (new abstract class in lib/data compatible with and stored as an Object in node properties)
-- KMLIcon (extends StagerIcon)
- LatLonBox (new class in lib/mapping compatible with and stored as an Object in node properties)
- KMLHole (new class in lib/mapping)

This redesign correctly identifies that Document, Folder, and Placemark are containers. Placing 
KMLGroundOverlayNode under KMLGeometryNode (as a LeafNode) correctly identifies it as a terminal 
node in the Stager tree, even though it is a Feature in the KML spec.

This design naturally supports KML MultiGeometry by allowing KMLPlacemarkNode to hold multiple 
KMLGeometryNode children.

To ensure compatibility with future overrides of summarize(), the specialized accessors must use 
standardized property keys (e.g., 'kml_visibility', 'kml_holes').

## Alternatives Considered
The original design was considered and, obviously, found wanting. Alternatives of the new class
hierarchy were also considered, such as having Ground Overlays subclass features, but that led to
problems with adding children to a terminal node. Earlier revisions also included Icons, LatLonBoxes,
and holes as bare maps in node properties, which is undesirable due to the complexity of managing
such an arrangement.

It is possible to introduce a `KMLContainerNode` abstract class to further group `KMLDocumentNode` 
and `KMLFolderNode`, but that is not presently needed and, therefore, omitted.

## Reviews & Audits

### First Audit - 20260202
* **Naming Collision Prevention**: Renamed the base `Icon` class to `StagerIcon` to avoid conflicts with `package:flutter/widgets.dart`.
* **Polygon Plurality**: Updated the specification for `KMLPolygonNode` to support a `List<KMLHole>` instead of a single hole, accurately reflecting the KML schema.
* **Stylable Ground Overlays**: Explicitly included the `KMLStylable` mixin for `KMLGroundOverlayNode` to support visual properties despite its placement in the geometry branch of the hierarchy.
* **Consolidated Placemark Container**: Removed `KMLMultiGeometryNode`. `KMLPlacemarkNode` now handles multiple geometry children directly and provides an `isMultiGeometry` getter.

### Second Audit - 20260203
* **Improper Styling of Folders**: The initial redesign allowed `KMLFolderNode` to use the `KMLStylable` mixin. This is forbidden by the KML spec. The mixin should be moved from the base `KMLFeatureNode` to specific subclasses.
* **Invalid Nesting (Documents in Folders)**: The design allowed `KMLFolderNode` to contain `KMLDocumentNode`s. This is also forbidden. Runtime enforcement in `addChild` is required to maintain tree integrity.

## Implementation Details

Icon support is provided in lib/data/icon.dart at the full library level since there is more than
one type of icon in Stager. KML icons extend this class in lib/mapping/kml_icon.dart. Specialized
KML features for latlon boxes and holes are implemented in lib/mapping/lat_lon_box.dart and 
lib/mapping/kml_hole.dart, respectively.

Node layers are implemented in lib/mapping/nodes following the hierarchy above an adhering to a
one class per file rule. Tests are in tests/mapping.

`KMLFeatureNode` serves as the base for containers but no longer implements `KMLStylable`. Styling is instead applied to `KMLDocumentNode`, `KMLPlacemarkNode`, and `KMLGroundOverlayNode`. 

`KMLFolderNode` overrides the `addChild` method to explicitly reject `KMLDocumentNode` children, throwing an `ArgumentError` to ensure KML spec compliance.

KMLParser and its utilities have been refactored to detect and instantiate the new node types. This
is effectively a complete rewrite of the parser, its utilities, and its tests since the structure of
the original nodes is not preserved.

The KMLPlacemarkNode implements a getter `isMultiGeometry` that returns true if it contains more than
one `KMLGeometryNode` child.

The KMLGroundOverlayNode does not expose its LatLonBox as an outline in this revision and will,
therefore, break compatibility with TreeNode.summarize() until that functionality is updated. The 
summarization logic for KML-specific trees will be addressed in a future revision or through a 
specialized KMLTreeVisitor.

There is not a strict 1-1 entity mapping between Stager's KML implementation and the KML spec since
all XML elements are naturally composites with attributes serving as the leaf nodes. Stager strictly
defines composite and leaf nodes as separate entities. Thus, in some cases, there are a few apparent
matches.
* GroundOverlayNode is a terminal node in KML and Stager, although in KML it is considered a peer
to Placemark.
* MultiGeometry is a collection in KML; in Stager, this is handled by `KMLPlacemarkNode` aggregating multiple `KMLGeometryNode` children.

## Testing Plan
* **Unit Tests**:
    * Verify the `StagerIcon`, `KMLIcon`, `LatLonBox`, and `KMLHole` data models for correct property storage and serialization.
    * Test each node class in `lib/mapping/nodes/` to ensure constructors correctly initialize properties and that accessors map to the correct internal keys in `NodeProperties`.
    * Verify `KMLPlacemarkNode` correctly manages multiple `KMLGeometryNode` children and reports `isMultiGeometry` accurately.
    * Verify `KMLFolderNode` correctly rejects `KMLDocumentNode` children.
* **Widget Tests**:
    * Although UI components are not part of this redesign, ensure that existing `LocationEditor` components can still interact with nodes containing geographic properties.
* **Integration Tests**:
    * Test the `KMLParser` with complex KML files containing nested folders, documents, and placemarks with multiple geometries.
    * Verify that styles are correctly resolved via the `KMLStylable` mixin across different feature types, including Ground Overlays.
    * Confirm that the `KMLTreeRootNode` provides a valid Stager tree that can be traversed by existing `NodeVisitor` implementations.

## Short Example
```dart
// Example of the new type-safe API
final styleManager = KMLStyleManager();

// Placemark is now a composite container for geometries
final placemark = KMLPlacemarkNode(
  id: 'pm1',
  name: 'Central Park',
  styleManager: styleManager,
);

// Create and configure a polygon geometry
final polygon = KMLPolygonNode(
  id: 'poly1',
  name: 'Park Boundary',
  styleManager: styleManager,
);

// Using strongly-typed accessors instead of raw property maps
polygon.outline = [
  LatLng(40.764, -73.973),
  LatLng(40.800, -73.958),
  LatLng(40.796, -73.949),
  LatLng(40.761, -73.964),
  LatLng(40.764, -73.973),
];

// Support for complex geometry with multiple holes
polygon.addHole(KMLHole(
  points: [
    LatLng(40.771, -73.970),
    LatLng(40.775, -73.968),
    LatLng(40.771, -73.965),
    LatLng(40.771, -73.970),
  ],
));

placemark.addChild(polygon);

// Example of a terminal GroundOverlay node
final overlay = KMLGroundOverlayNode(
  id: 'overlay1',
  name: 'Historical Overlay',
  styleManager: styleManager,
);

overlay.icon = KMLIcon(href: 'assets/historical_map.png');
overlay.latLonBox = LatLonBox(
  north: 40.8,
  south: 40.7,
  east: -73.9,
  west: -74.0,
);

placemark.addChild(overlay);

// Check for MultiGeometry status
if (placemark.isMultiGeometry) {
  print('${placemark.name} has multiple geometries.');
}
```

## Open Questions
None.

## Tickets

- [Implement StagerIcon and KMLIcon data models with unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/16)
- [Implement LatLonBox data model with unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/17)
- [Implement KMLHole data model with unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/18)
- [Implement KMLFeatureNode abstract base class with unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/19)
- [Implement KMLDocumentNode with unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/20)
- [Implement KMLFolderNode with unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/21)
- [Implement KMLPlacemarkNode composite with unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/22)
- [Implement KMLGeometryNode abstract base class with unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/23)
- [Implement KMLPointNode with unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/24)
- [Implement KMLPathNode with unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/25)
- [Implement KMLPolygonNode with unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/26)
- [Implement KMLGroundOverlayNode with unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/27)
- [Refactor KMLParserUtils for new node hierarchy](https://gitlab.com/bandgap/stager-platform/stager/-/issues/28)
- [Refactor KMLParserUtils geometry detection logic](https://gitlab.com/bandgap/stager-platform/stager/-/issues/29)
- [Rewrite KMLParser for composite Placemarks and containers](https://gitlab.com/bandgap/stager-platform/stager/-/issues/30)
- [Update public API exports for new KML hierarchy](https://gitlab.com/bandgap/stager-platform/stager/-/issues/31)
- [Update Visitor Verification tests for new KML hierarchy](https://gitlab.com/bandgap/stager-platform/stager/-/issues/32)
- [Update KML Integration tests for new KML hierarchy](https://gitlab.com/bandgap/stager-platform/stager/-/issues/33)
