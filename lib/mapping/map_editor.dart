// Flutter packages
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../editors/standard_widgets.dart';
import '../system/basic_selection_visitor_handler.dart';
import '../system/selection.dart';
import '../system/selection_service.dart';
import '../system/selection_visitor.dart';
import '../system/selection_visitor_handler.dart';
import 'location_editor.dart';
import 'nodes/map_selection_visitor_handler.dart';
import '../system/generic_delegating_observer.dart';
import '../editors/stager_editor.dart';
import 'map_state.dart';

/// A specialized [StagerEditor] for GIS workflows and map-based data management.
///
/// This editor hosts a [FlutterMap] and leverages [MapState] to manage
/// geographic data ingestion via visitation, selection brokerage, and
/// interactive editing modes.
///
/// The [MapEditor] participates in both the Stager and Flutter lifecycles,
/// allowing it to be reconfigured via an editor factory and utilize standard
/// editor utilities like message dialogs.
///
/// It is the first editor to integrate with the [SelectionService], observing
/// global selection updates to automatically focus or highlight nodes selected
/// in other views (e.g., [TreeView] or [NodePropertiesView]). It also
/// integrates with the [LocationEditor] to allow users to configure their
/// location or automatically detect it with GPS.
class MapEditor extends StagerEditor<MapState> {
  /// A global id for the map editor.
  static const String viewId = "mapEditor";

  /// Creates a [MapEditor] instance.
  ///
  /// [state]: The [MapState] configuration for the editor.
  const MapEditor({super.key, required super.state});

  @override
  State<MapEditor> createState() => _MapEditorState();
}

/// The state class for [MapEditor], managing the Flutter Map lifecycle.
///
/// While [MapState] focuses on the data state (layer adapters, tile servers),
/// [_MapEditorState] is responsible for the Flutter widget state, including
/// managing viewable layers, handling re-renders triggered by [MapState]
/// notifications (via [SelectionService]), and coordinating with the
/// [SelectionService] for automated navigation.
class _MapEditorState extends State<MapEditor> {
  final SelectionService selectionService = SelectionService();
  final SelectionVisitorHandler handler = BasicSelectionVisitorHandler();
  late GenericSelectionVisitor<LatLng> locationChangeVisitor;
  late MapSelectionVisitorHandler globalSelectionHandler;
  bool _useSatellite = false;

  late final GenericDelegatingObserver _localObserver;
  late final GenericDelegatingObserver _globalObserver;

  @override
  void initState() {
    super.initState();

    // Initialize specialized observers
    _localObserver = GenericDelegatingObserver(_handleLocalSelection);
    _globalObserver = GenericDelegatingObserver(_handleGlobalSelection);

    // Register against the selection service for location updates from the
    // location editor
    selectionService.attach(_localObserver, MapEditor.viewId);
    // Setup its visitor
    final defaultLoc = widget.state.mapOptions.initialCenter;
    locationChangeVisitor = GenericSelectionVisitor(defaultLoc);
    handler.register(LatLng, locationChangeVisitor);

    // And global selection updates
    selectionService.attach(_globalObserver);
    // Setup the visitor for global selection updates
    globalSelectionHandler = MapSelectionVisitorHandler();
  }

  @override
  void dispose() {
    // Detach from the selection service because this class will be destroyed,
    // which will cause errors until it is reinitialized.
    selectionService.detach(_localObserver, MapEditor.viewId);
    selectionService.detach(_globalObserver);
    super.dispose();
  }

  /// Utility function for moving to a location. It preserves the current zoom
  /// level.
  void _moveToPoint(LatLng point) {
    final currentZoom = widget.state.mapController.camera.zoom;
    widget.state.mapController.move(point, currentZoom);
  }

  /// Handles selection updates from the local "mapEditor" channel (e.g. from
  /// the LocationEditor).
  void _handleLocalSelection() {
    if (mounted && selectionService.isSet(MapEditor.viewId)) {
      setState(() {
        Selection<dynamic> selection = selectionService.getSelectionForView(
          MapEditor.viewId,
        );
        selection.accept(handler);
        _moveToPoint(locationChangeVisitor.value);
      });
    }
  }

  /// Handles selection updates from the global selection channel (e.g. marker
  /// taps).
  void _handleGlobalSelection() {
    if (mounted && selectionService.isSet()) {
      setState(() {
        selectionService.selection.accept(globalSelectionHandler);
        _moveToPoint(globalSelectionHandler.location.toLatLng());
      });
    }
  }

  FlutterMap _buildMap(MapState state) {
    return FlutterMap(
      mapController: state.mapController,
      options: state.mapOptions.flutterMapOptions,
      children: [
        state.tileLayerAdapter.getTileLayer(_useSatellite),
        state.tileLayerAdapter.getAttributionWidget(_useSatellite),
        state.polygonLayerAdapter.polygonLayer,
        state.markerLayerAdapter.markerLayer,
      ],
    );
  }

  /// Opens a dialog to set the map location.
  ///
  /// This follows the "Apply" pattern where coordinates can be edited
  /// reactively, but the actual map movement and dialog closure only
  /// happen when the user clicks "Set".
  void _showLocationDialog(BuildContext context, MapState state) {
    // Capture the current center as the starting point for editing.
    LatLng currentEditingLocation = widget.state.mapController.camera.center;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return buildCustomDialog(
          dialogContext,
          "Set Location",
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LocationEditor(
              initialLocation: currentEditingLocation,
              onLocationChanged: (location) {
                // Update the pending location as the user interacts with the
                // editor (auto-locate, address lookup, or manual typing).
                currentEditingLocation = location;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Only now do we broadcast the change to the selection service
                // and close the dialog.
                selectionService.setSelectionForView(
                  Selection<LatLng>(currentEditingLocation),
                  MapEditor.viewId,
                );
                Navigator.pop(dialogContext);
              },
              child: const Text("Set"),
            ),
          ],
        );
      },
    );
  }

  Align _buildControlBar(BuildContext context, MapState state) {
    return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                onPressed: () {
                  _showLocationDialog(context, state);
                },
                child: const Icon(Icons.search),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                onPressed: () {
                  setState(() {
                    // Toggle the value in stagerMapOptions via state
                    _useSatellite = !_useSatellite;
                  });
                },
                child: Icon(_useSatellite ? Icons.map : Icons.satellite_alt),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Build the map, which is at the bottom of the Stack.
        _buildMap(widget.state),
        // Add the centered control bar at the top of the map. This sits above
        // the map in the stack.
        _buildControlBar(context, widget.state),
      ],
    );
  }
}
