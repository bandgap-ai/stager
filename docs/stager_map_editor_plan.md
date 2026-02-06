# Stager Map Editor Development Plan - 20260205

## Status
Draft

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
* Utilize the new LocationEditor to allow users to configure their location or automatically detect 
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
Document feedback from peers and stakeholders. Summarize audit findings for shortcomings and likely failures.

## Implementation Details
This package uses the Flutter Map plugin. The base map is OpenStreetMap and there 
[are specific rules around using the OpenStreetMap tile server](https://operations.osmfoundation.org/policies/tiles/).

The [MapEditor](../lib/mapping/map_editor.dart) is small by design. It externalizes as much of its
functionality as possible to remain reconfigurable and reusable. The Map Editor's Flutter Map Layers
are implemented in separate files and loaded dynamically based on the configuration of the MapEditor
widget as it reloads.

Marker and Polygon layers are constructed with specialized LayerAdapters. LayerAdapters can be
specialized to data types without introducing those dependencies to MapEditor. LayerAdapters can
adapt to any input, but their intended purpose is to adapt data in Stager TreeNodes to the flattened
form (set of arrays) required by Flutter Map. LayerAdapters should observer the data they adapt and
reload the layers when the data changes. [Tree Node Iterators](../lib/tree/iterators.dart) are used
to iterate over the tree in the specialized LayerAdapters.

The MapEditor widget is [a standard Stager editor](../lib/editors/stager_editor.dart), (and because
of its highly specialized purpose it is stored in the mapping directory). Thus, it participates in
both the Stager and the Flutter lifecycles. This means that some elements of the MapEditor can be
reconfigured using [an Editor Factory](../lib/editors/editor_factory.dart) although this is
practically not so useful. It uses other Editor utilities as needed, such as 
[message dialogs](../lib/editors/message_dialog.dart). The view of the map and data (handled by 
Flutter Map) is wrapped inside a standard Flutter Stateful Widget, and this provides some
limited opportunity for customization of the utility bar and controls used to manipulate the map.

The state of the MapEditor is stored in a [MapState](../lib/mapping/map_state.dart) object.
It is a collection of tile, marker, and polygon layer adapters; configuration details; attribution
widgets, and other data used by the MapEditor. The MapState class is distinct from the
_MapEditorState class defined in the MapEditor because _MapEditorState is specifically focused on 
the Flutter widget state of the MapEditor whereas MapState is focused on the data state. (Confusing,
I know.)

The MapEditor uses [the new LocationEditor](../lib/editors/location_editor.dart) to allow users to
configure their location or automatically detect it with GPS.

The MapEditor is the first StagerEditor to use [the new SelectionService](../lib/system/selection_service.dart). 
The SelectionService replaces the `_selectedNode` variable in the original implementation. It is a 
global registry of selections that includes the current global selection (i.e., a single point 
picked on a map or a selected node in a TreeView) and local selections within a specific view (like 
a local element selected in a NodePropertiesView). The SelectionService is an observer and can be 
directed to register against subjects that provide global selection updates 
(GlobalSelectionDispatcher) and local selection updates (LocalSelectionDispatcher).

## Testing Plan

Flutter Map can be quite hard to test.

Describe the strategy for verification.
* **Unit Tests**: Logic and data models.
* **Widget Tests**: UI components and interaction.
* **Integration Tests**: End-to-end functionality.

## Short Example
The following example show show to configure the Map Editor in a simple client application. A robust
version of this is implemented [in the example](../example/lib/main.dart).

```dart
To be added later
```

## Open Questions
* **The Interaction Feedback Loop**: How exactly are interactions (like tapping a marker or dragging a polygon vertex) brokered from the `flutter_map` layer back to the specific `TreeNode`? Does the `LayerAdapter` handle these events and dispatch updates to the `SelectionService`?
* **Navigation and Synchronization**: Should the `MapEditor` observe the `SelectionService` to automatically pan and zoom to a feature when it is selected in an external view (like a Tree View or Property Grid)?
* **Performance with Large Trees**: For massive KML trees, will the adaptation process (visitation and array flattening) become a bottleneck? Is there a requirement for "dirty checking" or partial layer updates?
* **Edit vs. View Modes**: Will the map support a "Read Only" mode for simple visualization, or is it strictly an interactive "Editor" first?
* **Configuration Persistence**: How are user-selected tile servers, layer visibility, and attribution options persisted and eventually serialized?
* **Graphical Cue Management**: Will cues like parent-child connection lines be handled by specialized `LayerAdapters` or as a built-in feature of the core editor?
* **Pragmatic State Separation**: How can we further harden the boundary between `MapState` (data/config) and `_MapEditorState` (Flutter lifecycle) to avoid state synchronization bugs?

## Tickets

Generate tickets from the above content, then place those tickets in a separate CSV file following
the GitLab format. Finally, once a human creates those tickets in GitLab, they will place the URLs
back in here with standard Markdown link formatting.

The available ticket labels are currently:
* Bug - Bugs are issues that describe unexpected and unintended behavior... like getting a bug in the vacuum tubes of your brand new Harvard Mark II.
* Enhancement - These issues are intended to improve the functionality of the product.
* Feature - This label indicates that this is a new feature for the project. A feature label is different than an enhancement label because enhancements may satisfy nonfunctional requirements whereas features always satisfy functional requirements.
* Full AI - Any AI tools may be used on this task. This label usually indicates that the task is for new or simple code, or things that can be easily performed, such as test and documentation updates.
* Limited AI - AI tools should be limited because the affected code is more mature and stable. AI code-completion, etc., are fine, but full Gemini CLI type editing that can rewrite the whole file is not.
* Mapping - This label indicates the ticket supports the Mapping features in the Stager Platform.
* No AI - This label indicates that, for some reason or other, no AI tools should be used on this task. Tasks with this label could include those that affect customer code with certain license restrictions, old or brittle code where AI will do more harm than good, and things that AI just can't do and, thus, shouldn't try.
* Restricted AI - Tasks with this label have restrictions on how AI may be used on the project. This could be as simple as legal restrictions and managing IP risks, or as complicated as dealing with specific customer requirements on AI use.
* Testing - This label indicates the activity improves or supports testing in the project.
