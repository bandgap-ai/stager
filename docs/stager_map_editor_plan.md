# Stager Map Editor Development Plan - 20260205

## Status
Approved

## Context & Background
The purpose of this plan is to develop a new map editor (or collection of map editors if needed) in
Stager to accommodate GIS workflows. 

The initial target client application is Tracee, Band Gap's AgTech tool that uses a custom map 
editor. That editor was vibe coded in late June 2025 and is so unextensible that it likely started 
the vibe code slopocalypse. However, it still serves as a sufficient starting point for a fresh from
scratch redesign.

## Goals
The list of goals for this design is significant it is replacing an existing system.
* Create a reusable map editor for GIS workflows.
* Enable ingestion of Stager Trees via visitation.
* Provide configurable TileLayers and widgets (like a control overlay).
* Provide a rigorous selection manager (controller) to broker selection management instead of 
storing selection state with regular data. 
* Enable point-and-click (and the mobile equivalent) editing for markers, polygons, etc.
* Make the map configurable with simple user-facing options.
* Enable tile server configuration.
* Enable multiple tile options/layers for sophisticated tile servers like ArcGIS.
* Provide configurable graphical cues like parent-child relationships.
* Utilize the new `LocationEditor` to allow users to configure their location or automatically detect 
it with GPS.
* Configurable RichAttributionWidgets.

## Exclusions
None.

## Proposed Design
Some key focus areas of this redesign are long term maintainability, extensibility, configurability,
and reusability. It is hard to accomplish these with a map editor, which is why the first version in
Tracee needs a rewrite (even though it functions very well).

## Alternatives Considered
None.

## Reviews & Audits

### First Audit - 20260205
* **Interaction Model**: The feedback loop between `flutter_map` and the Stager tree is resolved by 
having `LayerAdapter`s wrap flattened widgets (Markers, Polygons) in `GestureDetector`s. Taps will 
trigger updates to the specific `TreeNode` and the `SelectionService`.
* **Centralized Synchronization**: `MapEditor` will observe the `SelectionService` to support 
automated navigation (pan/zoom) when nodes are selected externally (e.g., in a Tree View).
* **Operational Modes**: The editor follows a "viewer-first" philosophy, where editing capabilities 
are enabled contextually based on specific user operations.
* **Persistence Strategy**: User-selected configurations will use `shared_preferences`. Proprietary 
or client-specific layers (like Tracee's ArcGIS layers) will be isolated in repository forks to 
maintain core library purity.
* **State Management**: The current separation between `MapState` and `_MapEditorState` is deemed 
sufficient for now, with further hardening deferred until specific synchronization bugs are 
identified.
* **Performance**: Implementation will focus on eliminating repetitive linear searching. Performance
will be measured rather than speculated upon, though thousands of features are expected to be 
handled efficiently.

### Second Audit - 20260212
* This plan did not previously consider the already existing Selection classes: 
[Selection](../lib/system/selection.dart)] and 
[SelectionObserver](../lib/system/selection_observer.dart). They are now discussed in the 
implementation details. 

## Implementation Details
This package uses the Flutter Map plugin. The base map is OpenStreetMap and there 
[are specific rules around using the OpenStreetMap tile server](https://operations.osmfoundation.org/policies/tiles/).

The [`MapEditor`](../lib/mapping/map_editor.dart) is small by design. It externalizes as much of its
functionality as possible to remain reconfigurable and reusable. The Map Editor's Flutter Map Layers
are implemented in separate files and loaded dynamically based on the configuration of the `MapEditor`
widget as it reloads.

Marker and Polygon layers are constructed with specialized `LayerAdapter`s. `LayerAdapter`s can be
specialized to data types without introducing those dependencies to `MapEditor`. `LayerAdapter`s can
adapt to any input, but their intended purpose is to adapt data in Stager `TreeNode`s to the flattened
form (set of arrays) required by Flutter Map. `LayerAdapter`s should observer the data they adapt and
reload the layers when the data changes. [Tree Node Iterators](../lib/tree/iterators.dart) are used
to iterate over the tree in the specialized `LayerAdapter`s. Tile layers and 
`RichAttributionWidget`s are handled as special `LayerAdapter` subclasses.

To handle user interaction, the `LayerAdapter` will set Flutter `GestureDetector`s on the map 
widgets' (like `Marker`) `onTap` callbacks. The callback will then dispatch updates to the target 
`TreeNode` and the `SelectionService`. Editing nodes will be enabled accomplished by type and as 
follows:
* Markers will appear in the `NodePropertiesView` for detailed editing after an `onTap` event, which
will set the selected Marker as the active node in `SelectionService`. Gross moves will be
accomplished by enabling a "Move" action control in the `MapEditor` that allows for click and drag
(i.e., `onLongPress` actions) changes. The changes will be committed to the node when the user 
releases the drag.
* Polygons will appear in the `NodePropertiesView` for review. Polygons will be editable via the 
same gross action ("Move" mode) as markers, and detail editing will be accomplished by editing the
position of a polygon marker directly.

Creating nodes can happen in at least two ways. First, users can add nodes by editing the Tree
directly via an editor. Second, users can activate a `Create` control in the `MapEditor` to add
Markers and Polygons.

The `MapEditor` widget is [a standard Stager editor](../lib/editors/stager_editor.dart), (and because
of its highly specialized purpose it is stored in the mapping directory). Thus, it participates in
both the Stager and the Flutter lifecycles. This means that some elements of the `MapEditor` can be
reconfigured using [an Editor Factory](../lib/editors/editor_factory.dart). It uses other Editor 
utilities as needed, such as [message dialogs](../lib/editors/message_dialog.dart). The view of the 
map and data (handled by Flutter Map) is wrapped inside a standard Flutter Stateful Widget, and this 
provides some limited opportunity for customization of the utility bar and controls used to 
manipulate the map.

The state of the `MapEditor` is stored in a [`MapState`](../lib/mapping/map_state.dart) object.
It is a collection of tile, marker, and polygon layer adapters; configuration details; attribution
widgets, and other data used by the `MapEditor`. The `MapState` class is distinct from the
`_MapEditorState` class defined in the `MapEditor` because `_MapEditorState` is specifically focused 
on the Flutter widget state of the `MapEditor` whereas `MapState` is focused on the data state.
Notably, it is the role of `_MapEditorState` to store options like the viewable list of layers and
tiles and `MapState` to store the configuration of the layers and tile servers. Changes to the
`MapState` result in notifications (via `SelectionService`) dispatched to `_MapEditorState` to
execute a new render of the map. One way to think about this statement is that the map is an
abstract thing defined by the data in `MapState` whereas the view of that map is the concrete thing
rendered in the `MapEditor` with view options set in `_MapEditorState`.

The `MapEditor` uses [the new `LocationEditor`](../lib/editors/location_editor.dart) to allow users to
configure their location or automatically detect it with GPS.

The `MapEditor` is the first `StagerEditor` to use 
[the new `SelectionService`](../lib/system/selection_service.dart). The `SelectionService` replaces 
the `_selectedNode` variable in the original implementation with 
[a `Selection<T>`](../lib/system/selection.dart) retrieved from the Service. The Service is a global
registry of selections that includes the current global selection (i.e., a single point 
picked on a map or a selected node in a TreeView) and local selections within a specific view (like 
a local element selected in a `NodePropertiesView`). The `SelectionService` can both observe other
objects and be observed. The `MapEditor` observes the `SelectionService` to automatically focus or 
highlight nodes selected elsewhere in clients.  The `SelectionService` interfaces for subjects
are `GlobalSelectionDispatcher` for global selections and 
[`SelectionObserver`](../lib/system/selection_observer.dart) for local selections. In fact, it is
not necessary to register with the `SelectionService` for local selections unless they need to be
shared since `Selection` is observable with `SelectionObserver` too.

The `SelectionService` also exposes a dynamic visitor interface for processing selections without
guessing or explicit type casting. The [`SelectionVisitor`](../lib/system/selection_visitor.dart),
['SelectionVisitorHandler'](../lib/system/selection_visitor_handler.dart], and
['BasicSelectionVisitorHandler'](../lib/system/basic_selection_visitor_handler.dart) are the main
classes providing this functionality and they are linked to `Selection` objects with its `accept()`
method.

The `SelectionService` does not store or return null selections. Clients should check 
`SelectionService.isSet()` before retrieving the active selection, subscribe for updates, or catch
the `NoSelectionException` from `SelectionService.selection()` instead. Clients that want to 
explicitly clear a selection from the service should call `SelectionService.clear()`.

Graphical relationships between parent nodes and their children are indicated in the map editor by
special polygons. These polygons are not explicitly or necessarily present in the Tree (or KML 
Tree), but they are computed and injected by the `LayerAdapter`s.

## Testing Plan

Flutter Map can be quite hard to test directly due to its reliance on native canvas rendering and 
third-party tile services. Therefore, the strategy for verification focuses on isolating business 
logic and data transformation from the rendering layer.

* **Unit Tests**: 
    * **`LayerAdapter` Verification**: Test each `LayerAdapter` subclass in isolation. Given a 
    pre-configured `StagerTree`, verify that the adapter produces the correct collection of 
    `flutter_map` data objects (Markers, Polygons, etc.) with the expected coordinates and 
    properties.
    * **`MapState` Logic**: Verify that `MapState` correctly manages the active tile servers and 
    layer adapters, and that it dispatches notifications correctly when its configuration is 
    mutated.
* **Widget Tests**: 
    * **UI Structure**: Verify that `MapEditor` correctly renders its structural components (utility 
    bar, creation controls, attribution widgets) based on the provided `MapState`.
    * **Interaction Feedback**: Use `tester.tap()` on mock markers and verify that the 
    `SelectionService` receives the correct node selection update.
    * **Mode Switching**: Verify that activating "Move" or "Create" modes correctly updates the UI 
    state and enables the appropriate gesture recognizers.
* **Integration Tests**: 
    * **End-to-End Ingestion**: Load a KML file using `KMLFile`, pass the resulting tree to 
    `MapEditor`, and verify that the count of rendered features matches the KML content.
    * **Cross-Subsystem Synchronization**: Verify that selecting a node in a separate `TreeView` 
    mock triggers the `MapEditor` to update its internal controller to "focus" on the selected 
    coordinates.

## Short Example
The following example show show to configure the Map Editor in a simple client application. A robust
version of this is implemented [in the example](../example/lib/main.dart).

```dart
To be added later
```

## Open Questions
None presently.

## Tickets

- [Implement SelectionService and Dispatcher interfaces](https://gitlab.com/bandgap/stager-platform/stager/-/issues/34)
- [Implement SelectionService unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/35)
- [Implement MapState data model](https://gitlab.com/bandgap/stager-platform/stager/-/issues/36)
- [Implement MapState unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/37)
- [Implement abstract LayerAdapter base class](https://gitlab.com/bandgap/stager-platform/stager/-/issues/38)
- [Implement KMLMarkerAdapter and unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/39)
- [Implement KMLPolygonAdapter and unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/40)
- [Implement OSMTileLayerAdapter and unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/41)
- [Implement MapEditor widget scaffold](https://gitlab.com/bandgap/stager-platform/stager/-/issues/42)
- [Implement _MapEditorState lifecycle and view logic](https://gitlab.com/bandgap/stager-platform/stager/-/issues/43)
- [Implement SelectionService observation in MapEditor](https://gitlab.com/bandgap/stager-platform/stager/-/issues/44)
- [Implement 'Move' interaction mode in LayerAdapters](https://gitlab.com/bandgap/stager-platform/stager/-/issues/45)
- [Implement 'Create' interaction mode in MapEditor](https://gitlab.com/bandgap/stager-platform/stager/-/issues/46)
- [Implement RichAttributionLayerAdapter and unit tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/47)
- [Create KML ingestion integration tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/48)
- [Create MapEditor cross-subsystem synchronization tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/49)
- [Create MapEditor UI/Interaction widget tests](https://gitlab.com/bandgap/stager-platform/stager/-/issues/50)
- [Update public API exports for GIS and Selection](https://gitlab.com/bandgap/stager-platform/stager/-/issues/51)

