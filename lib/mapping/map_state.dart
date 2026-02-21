// Flutter packages
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'adapters/stager_map_options.dart';
import 'adapters/marker_layer_adapter.dart';
import 'adapters/polygon_layer_adapter.dart';
import 'adapters/tile_layer_adapter.dart';

/// Represents the data state of the MapEditor.
///
/// This class holds the configuration for map layers, including the tile server,
/// markers, and polygons. It follows a "viewer-first" philosophy and provides
/// reasonable defaults for initial display.
///
/// In a more advanced implementation, this state would be populated by 
/// `LayerAdapter`s that transform Stager `TreeNode`s into these flattened forms.
class MapState {
  /// The tile layer configuration.
  TileLayer tileLayer = TileLayer();

  /// The list of markers to be rendered on the map.
  List<Marker> markers = [];

  /// The list of polygons to be rendered on the map.
  List<Polygon> polygons = [];

  final MapOptions _mapOptions = MapOptions();
  MapOptions get mapOptions => _mapOptions;

  final MapController _mapController = MapController();
  MapController get mapController => _mapController;

  final TileLayerAdapter _tileLayerAdapter = TileLayerAdapter();
  final MarkerLayerAdapter _markerLayerAdapter = MarkerLayerAdapter();
  final PolygonLayerAdapter _polygonLayerAdapter = PolygonLayerAdapter();
  final StagerMapOptions _stagerMapOptions = StagerMapOptions();


  /// Creates a [MapState] instance with the given layer data.
  ///
  /// If no arguments are provided, it defaults to a rudimentary set of layers
  /// centered around a sample point.
  MapState() {

    // FIXME! Needs base layer AND feature (roads, boundaries, etc.) layer such
    // that the adapter returns two children to the map editor.
  // DO RICH ATTRIBUTION AS WELL!

    // FIXME! There are at least two marker layers to consider: 1) the marker
    // layer for all regular data markers and 2) the marker layer for new shapes
    // being edited. (Sufficient to put these in one at a time.)

    // FIXME! We need to add rich attribution layers for all active tile layers.
    // I need to think this through.

  }

  TileLayerAdapter get tileLayerAdapter => _tileLayerAdapter;
  MarkerLayerAdapter get markerLayerAdapter => _markerLayerAdapter;
  PolygonLayerAdapter get polygonLayerAdapter => _polygonLayerAdapter;
  MapOptions get options => _stagerMapOptions.options;
}
