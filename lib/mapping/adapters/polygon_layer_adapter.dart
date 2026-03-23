import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../system/selection_service.dart';
import '../../tree/leaf_node.dart';
import '../nodes/kml_polygon_node.dart';

/// An adapter for managing polygon layers in Stager.
///
/// This class provides methods to retrieve the appropriate [PolygonLayer]
/// based on the map's configuration and the data in the [StagerTree].
class PolygonLayerAdapter {
  /// The callback for when a polygon is tapped.
  final void Function(LeafNode) onPolygonTap;

  /// The entries from the node type map.
  final Iterable<MapEntry<Type, List<dynamic>>> entries;

  /// The service used to manage selections.
  final SelectionService selectionService = SelectionService();

  /// Creates a [PolygonLayerAdapter].
  PolygonLayerAdapter(this.entries, this.onPolygonTap);

  /// Creates a [Polygon] from a list of points and a node.
  Polygon _makePolygon(List<LatLng> points, LeafNode node) {
    late final Polygon result;

    // See if this is the selected node.
    final bool isSelected =
        selectionService.isSet() ? (selectionService.selection.value == node) : false;

    // FIXME: Polygon in flutter_map does not have an onTap or a child widget
    // like Marker does. Taps on polygons are handled via MapEvents or
    // specialized layers. For now, we follow the structural pattern of
    // MarkerLayerAdapter.
    result = Polygon(
      points: points,
      color: isSelected
          ? const Color(0x7F2196F3) // Colors.blue.withOpacity(0.5)
          : const Color(0x4D2196F3), // Colors.blue.withOpacity(0.3)
      borderStrokeWidth: 3,
      borderColor: Colors.blue,
    );

    return result;
  }

  /// Returns the list of polygons to be rendered.
  List<Polygon> get polygons {
    final List<Polygon> polygons = [];

    for (final entry in entries) {
      for (final node in entry.value) {
        // We look for an "outline" property which should be a List<LatLng>.
        final dynamic outline =
            node.properties.getProperty(KMLPolygonNode.outlineKey);
        if (outline is List<LatLng>) {
          polygons.add(_makePolygon(outline, node));
        }
      }
    }

    return polygons;
  }

  /// Returns the [PolygonLayer] for the map.
  PolygonLayer get polygonLayer {
    return PolygonLayer(polygons: polygons);
  }
}
