import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MarkerLayerAdapter {

  List<Marker> get markers {
    return [
      Marker(
        point: const LatLng(38.9908317, -77.9661061),
        width: 40,
        height: 40,
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40,
        ),
      )
    ];
  }

  MarkerLayer get markerLayer {
    return MarkerLayer(markers: markers);
  }
}