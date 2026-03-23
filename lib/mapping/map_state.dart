import 'package:flutter_map/flutter_map.dart';
import 'package:stager_platform/stager.dart';
import '../site_state.dart';
import '../tree/iterators.dart';
import 'adapters/stager_map_options.dart';
import 'adapters/marker_layer_adapter.dart';
import 'adapters/polygon_layer_adapter.dart';
import 'adapters/tile_layer_adapter.dart';

void _defaultOnMarkerTap(LeafNode node) {
  SelectionService selectionService = SelectionService();
  selectionService.selection = Selection(node);
}

// List of supported marker types.
List<Type> _markerTypes = [LeafNode, ConcreteLeafNode,
  CompositeNode, ConcreteCompositeNode,
  TreeNode, ConcreteTreeNode];

// List of supported polygon types.
List<Type> _polygonTypes = [KMLPolygonNode];


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

  final MapController _mapController = MapController();
  MapController get mapController => _mapController;

  final TileLayerAdapter _tileLayerAdapter = TileLayerAdapter();
  final StagerMapOptions _stagerMapOptions = StagerMapOptions();

  final SiteState _siteState;

  final Map<Type, List<dynamic>> nodeTypeMap = {};

  /// This function rebuilds the layer adapters from the site state.
  void _rebuild() {
    nodeTypeMap.clear();
    final sites = _siteState.treeData;
    for (final site in sites) {
      final iterator = DepthFirstIterator(site);
      while (iterator.moveNext()) {
        LeafNode currentNode = iterator.current;
        if (nodeTypeMap.containsKey(currentNode.runtimeType)) {
          nodeTypeMap[currentNode.runtimeType]!.add(currentNode);
        } else {
          List<dynamic> nodeList = nodeTypeMap[currentNode.runtimeType] ?? [];
          nodeList.add(currentNode);
          nodeTypeMap[currentNode.runtimeType] = nodeList;
        }
      }
    }
  }

  void Function(LeafNode) onMarkerTap;

  /// Creates a [MapState] instance with the given site data.
  ///
  /// For the moment, this loads ALL site data into the map state and layer
  /// adapters on construction and for every update.
  ///
  /// [siteState]: The full set of site data.
  MapState(this._siteState, [this.onMarkerTap = _defaultOnMarkerTap]) {

    // FIXME! Needs base layer AND feature (roads, boundaries, etc.) layer such
    // that the adapter returns two children to the map editor.
  // DO RICH ATTRIBUTION AS WELL!

    // FIXME! There are at least two marker layers to consider: 1) the marker
    // layer for all regular data markers and 2) the marker layer for new shapes
    // being edited. (Sufficient to put these in one at a time.)

    // FIXME! We need to add rich attribution layers for all active tile layers.
    // I need to think this through.

    _rebuild();
  }

  TileLayerAdapter get tileLayerAdapter => _tileLayerAdapter;
  MarkerLayerAdapter get markerLayerAdapter {
    // Assemble the entries by looking up the supported marker types.
    // This is O(n) for n marker types as opposed to a .where() filter, which
    // is O(n*m) for n marker types and m total types since the filter iterates
    // over all stored types.
    final markerEntries = [
      for (final type in _markerTypes)
        if (nodeTypeMap.containsKey(type))
          MapEntry(type, nodeTypeMap[type]!)
    ];

    print(nodeTypeMap);
    print("Marker entries: $markerEntries");

    return MarkerLayerAdapter(markerEntries, onMarkerTap);
  }
  PolygonLayerAdapter get polygonLayerAdapter {
    final polygonEntries = [
      for (final type in _polygonTypes)
        if (nodeTypeMap.containsKey(type))
          MapEntry(type, nodeTypeMap[type]!)
    ];
    return PolygonLayerAdapter(polygonEntries, onMarkerTap);
  }
  StagerMapOptions get mapOptions => _stagerMapOptions;
}
