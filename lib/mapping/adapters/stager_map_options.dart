import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../system/selection_service.dart';
import '../../tree/leaf_node.dart';

/// A class for managing [MapOptions] in Stager.
///
/// This class encapsulates the configuration for the [FlutterMap], including
/// the initial center, zoom level, and layer-specific options like whether to
/// use satellite imagery.
class StagerMapOptions {
  /// Whether to use the satellite imagery layer.
  bool useSatellite = false;

  final LatLng initialCenter = const LatLng(38.9908317, -77.9661061);
  final initialZoom = 18.0;
  final double minZoom = 0.0;
  final double maxZoom = 25.0;
  double currentZoom = 18.0;

  /// Returns the [MapOptions] for the [FlutterMap].
  MapOptions get flutterMapOptions {
    return MapOptions(
      // Default starting point: the geographic center.
      initialCenter: initialCenter,
      initialZoom: initialZoom,
      // FIXME Needs: Correct initial, min, and max zoom settings, onMapTap
      //  handler, and onMapLongPress handler.
    );
  }
}
