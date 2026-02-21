import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

class TileLayerAdapter {
  TileLayer get tileLayer {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'ai.bandgap.stager.example',
    );
  }

  RichAttributionWidget get attributionWidget {
    return RichAttributionWidget(
      attributions: [
        // FIXME! Should be open street map for this tile layer.
        // FIXME! Why does it show two attribution icons?
        TextSourceAttribution(
          'Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
          onTap: () => launchUrl(Uri.parse('https://www.esri.com/en-us/home')),
        ),
      ],
    );
  }
}