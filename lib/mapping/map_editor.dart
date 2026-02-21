// Flutter packages
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:stager_platform/stager.dart';
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

class _PositionSelectionVisitor implements SelectionVisitor<LatLng> {
  LatLng position;

  _PositionSelectionVisitor([this.position = const LatLng(0.0, 0.0)]);

  @override
  void visit(LatLng element) {
    position = element;
  }
}

/// The state class for [MapEditor], managing the Flutter Map lifecycle.
///
/// While [MapState] focuses on the data state (layer adapters, tile servers),
/// [_MapEditorState] is responsible for the Flutter widget state, including
/// managing viewable layers, handling re-renders triggered by [MapState]
/// notifications (via [SelectionService]), and coordinating with the
/// [SelectionService] for automated navigation.
class _MapEditorState extends State<MapEditor>
    implements SelectionObserver<LatLng> {
  final SelectionService selectionService = SelectionService();
  final SelectionVisitorHandler handler = BasicSelectionVisitorHandler();
  final _PositionSelectionVisitor posVisitor = _PositionSelectionVisitor();

  @override
  void initState() {
    super.initState();
    // Register against the selection service for location updates
    selectionService.attach(this, MapEditor.viewId);
    // Setup its visitor
    handler.register(LatLng, posVisitor);
  }

  @override
  void dispose() {
    // Detach from the selection service because this class will be destroyed,
    // which will cause errors until it is reinitialized.
    selectionService.detach(this, MapEditor.viewId);
    super.dispose();
  }

  FlutterMap _buildMap(MapState state) {
    return FlutterMap(
      mapController: state.mapController,
      options: state.options,
      children: [
        state.tileLayerAdapter.tileLayer,
        state.tileLayerAdapter.attributionWidget,
        state.markerLayerAdapter.markerLayer,
        state.polygonLayerAdapter.polygonLayer,
      ],
    );
  }

  void _showLocationDialog(BuildContext context, MapState state) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return buildCustomDialog(
          context,
          "Set Location",
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LocationEditor(
              onLocationChanged: (location) {
                selectionService.setSelectionForView(
                  Selection<LatLng>(location),
                  MapEditor.viewId,
                );
                // Close the sub-menu
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  Align _buildControlBar(BuildContext context, MapState state) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0), // Margin from the top
        child: FloatingActionButton.small(
          onPressed: () {
            _showLocationDialog(context, state);
          },
          child: const Icon(Icons.search), // The "looking glass" icon
        ),
      ),
    );
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

  @override
  void update() {
    // Verify the widget is still mounted before attempting to update state,
    // especially in case it is triggered by asynchronous services (like from
    // the location editor's lookups).
    if (mounted) {
      setState(() {
        Selection<dynamic> selection = selectionService.getSelectionForView(
          MapEditor.viewId,
        );
        selection.accept(handler);
        widget.state.mapController.move(posVisitor.position, 15.0);
      });
    }
  }
}
