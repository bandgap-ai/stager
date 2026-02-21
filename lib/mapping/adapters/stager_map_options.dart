import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StagerMapOptions {
  MapOptions get options {
    return MapOptions(
      // Default starting point: the geographic center.
      initialCenter: LatLng(38.9908317, -77.9661061),
      initialZoom: 18.0,
      // FIXME Needs: Correct initial, min, and max zoom settings, onMapTap
      //  handler, and onMapLongPress handler.
    );
  }
}