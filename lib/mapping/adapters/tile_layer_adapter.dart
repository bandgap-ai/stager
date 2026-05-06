import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

/// An adapter for managing tile layers and their attributions.
///
/// This class provides methods to retrieve the appropriate [TileLayer] and
/// [RichAttributionWidget] based on the map's configuration, such as whether
/// to use standard or satellite imagery.
class TileLayerAdapter {
  /// Returns the [TileLayer] for the map.
  ///
  /// [useSatellite]: Whether to use the ESRI World Imagery satellite layer.
  TileLayer getTileLayer(bool useSatellite) {
    late final TileLayer result;

    if (useSatellite) {
      result = TileLayer(
        urlTemplate:
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        userAgentPackageName: 'ai.bandgap.stager.example',
      );
    } else {
      result = TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'ai.bandgap.stager.example',
      );
    }

    return result;
  }

  /// Returns the [RichAttributionWidget] for the tile layer.
  ///
  /// [useSatellite]: Whether to use the ESRI attribution for satellite imagery.
  RichAttributionWidget getAttributionWidget(bool useSatellite) {
    late final RichAttributionWidget result;

    if (useSatellite) {
      result = RichAttributionWidget(
        attributions: [
          TextSourceAttribution(
            'Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, '
            'IGN, IGP, UPR-EGP, and the GIS User Community',
            onTap: () => launchUrl(Uri.parse('https://www.esri.com/en-us/home')),
          ),
        ],
      );
    } else {
      result = RichAttributionWidget(
        attributions: [
          TextSourceAttribution(
            'OpenStreetMap contributors',
            onTap: () =>
                launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
          ),
        ],
      );
    }

    return result;
  }
}
