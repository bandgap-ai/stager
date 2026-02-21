import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class PolygonLayerAdapter {

  List<Polygon> get polygons {
    return [
      Polygon(
        points: const [
          LatLng(38.99100, -77.96610),
          LatLng(38.99075, -77.96632),
          LatLng(38.99075, -77.9659),
        ],
        color: const Color(0x4D2196F3), // Colors.blue.withOpacity(0.3)
        borderStrokeWidth: 3,
        borderColor: Colors.blue,
      )
    ];
  }

  PolygonLayer get polygonLayer {
    return PolygonLayer(polygons: polygons);
  }
}