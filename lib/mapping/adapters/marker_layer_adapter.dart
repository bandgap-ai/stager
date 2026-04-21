import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../system/selection_service.dart';
import '../../tree/leaf_node.dart';

class MarkerLayerAdapter {

  void Function(LeafNode) onMarkerTap;
  final Iterable<MapEntry<Type, List<dynamic>>> entries;
  final SelectionService selectionService = SelectionService();

  MarkerLayerAdapter(this.entries, this.onMarkerTap);

  Marker _makeMarker(double latitude, double longitude, LeafNode node) {
    // See if this is the selected node.
    bool isSelected = selectionService.isSet() ? (selectionService.selection.value == node) : false;
    return Marker(
        point: LatLng(latitude, longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            onMarkerTap(node); // Trigger callback on marker tap
          },
          child: Icon(
            Icons.location_on, // Use icon based on tree level
            // Yellow when selected, green when not
            color: isSelected ? const Color.fromARGB(255, 243, 228, 92) : const Color.fromARGB(255, 85, 219, 152),
            size: 40.0,
          ),
        ),
      );
  }

  List<Marker> get markers {
    // For every entry, cast it to ConcreteLeafNode and extract the latitude and
    // longitude properties into a marker created with the _makeMarker()
    // function.
    List<Marker> markers = [];
    for (final entry in entries) {
      for (final node in entry.value) {
        final latitude = node.properties.get<double>("latitude");
        final longitude = node.properties.get<double>("longitude");
        if (latitude != null && longitude != null) {
          markers.add(_makeMarker(latitude, longitude, node));
        }
      }
    }

    return markers;
  }

  MarkerLayer get markerLayer {
    return MarkerLayer(markers: markers);
  }
}