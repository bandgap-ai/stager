// External packages
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';

// Project files
import 'nodes/kml_folder_node.dart';
import 'nodes/kml_placemark_node.dart';
import 'style/kml_icon_style.dart';
import 'style/kml_line_style.dart';
import 'style/kml_poly_style.dart';
import 'style/kml_style_manager.dart';

/// A utility class containing static methods for parsing KML elements and 
/// creating Stager nodes.
///
/// This class encapsulates the transformation logic from KML XML fragments to 
/// strongly-typed style components and Stager tree nodes, enabling granular 
/// unit testing.
class KMLParserUtils {
  /// Extracts LineStyle information from a `<Style>` element.
  ///
  /// [styleElement]: The XML element containing the style definition.
  ///
  /// Returns a non-nullable [KMLLineStyle].
  static KMLLineStyle parseLineStyle(XmlElement styleElement) {
    late KMLLineStyle style;
    final lineElem = styleElement.getElement('LineStyle');
    
    if (lineElem != null) {
      final color = lineElem.getElement('color')?.innerText ?? 'ffffffff';
      final widthText = lineElem.getElement('width')?.innerText;
      final width = double.tryParse(widthText ?? '1.0') ?? 1.0;
      style = KMLLineStyle(color: color, width: width);
    } else {
      style = const KMLLineStyle();
    }
    return style;
  }

  /// Extracts PolyStyle information from a `<Style>` element.
  ///
  /// [styleElement]: The XML element containing the style definition.
  ///
  /// Returns a non-nullable [KMLPolyStyle].
  static KMLPolyStyle parsePolyStyle(XmlElement styleElement) {
    late KMLPolyStyle style;
    final polyElem = styleElement.getElement('PolyStyle');
    
    if (polyElem != null) {
      final color = polyElem.getElement('color')?.innerText ?? 'ffffffff';
      final fillText = polyElem.getElement('fill')?.innerText;
      final fill = fillText != '0' && fillText?.toLowerCase() != 'false';
      
      final outlineText = polyElem.getElement('outline')?.innerText;
      final outline = outlineText != '0' && outlineText?.toLowerCase() != 'false';
      style = KMLPolyStyle(color: color, fill: fill, outline: outline);
    } else {
      style = const KMLPolyStyle();
    }
    return style;
  }

  /// Extracts IconStyle information from a `<Style>` element.
  ///
  /// [styleElement]: The XML element containing the style definition.
  ///
  /// Returns a non-nullable [KMLIconStyle].
  static KMLIconStyle parseIconStyle(XmlElement styleElement) {
    late KMLIconStyle style;
    final iconElem = styleElement.getElement('IconStyle');
    
    if (iconElem != null) {
      final scaleText = iconElem.getElement('scale')?.innerText;
      final scale = double.tryParse(scaleText ?? '1.0') ?? 1.0;
      final href = iconElem.getElement('Icon')?.getElement('href')?.innerText ?? '';
      style = KMLIconStyle(scale: scale, href: href);
    } else {
      style = const KMLIconStyle();
    }
    return style;
  }

  /// Creates a [KMLFolderNode] from a `<Folder>` or `<Document>` element.
  ///
  /// [element]: The XML element representing the folder.
  /// [styleManager]: The manager used to resolve styles.
  ///
  /// Returns a [KMLFolderNode].
  static KMLFolderNode createFolderNode(
    XmlElement element, 
    KMLStyleManager styleManager,
  ) {
    final id = element.getAttribute('id') ?? 'folder_${element.hashCode}';
    final name = element.getElement('name')?.innerText ?? 'Unnamed Folder';
    final styleUrl = element.getElement('styleUrl')?.innerText ?? 'default';

    return KMLFolderNode(
      id: id,
      name: name,
      styleManager: styleManager,
      styleUrl: styleUrl,
    );
  }

  /// Creates a [KMLPlacemarkNode] from a `<Placemark>` element.
  ///
  /// [element]: The XML element representing the placemark.
  /// [styleManager]: The manager used to resolve styles.
  ///
  /// Returns a [KMLPlacemarkNode].
  static KMLPlacemarkNode createPlacemarkNode(
    XmlElement element, 
    KMLStyleManager styleManager,
  ) {
    final id = element.getAttribute('id') ?? 'pm_${element.hashCode}';
    final name = element.getElement('name')?.innerText ?? 'Unnamed Placemark';
    final styleUrl = element.getElement('styleUrl')?.innerText ?? 'default';

    final node = KMLPlacemarkNode(
      id: id,
      name: name,
      styleManager: styleManager,
      styleUrl: styleUrl,
    );

    // Extract geometry data (Point, Polygon, etc.) from the XML.
    parseGeometry(element, node);
    
    // Capture descriptive attributes.
    final desc = element.getElement('description')?.innerText;
    if (desc != null) {
      node.properties.setProperty('description', desc);
    }

    return node;
  }

  /// Extracts geographic geometry data from a `<Placemark>` [element] and 
  /// populates the [node]'s properties.
  ///
  /// This method coordinates the extraction of Points, LineStrings, and 
  /// Polygons by delegating to specialized helper functions.
  ///
  /// [element]: The XML element representing the Placemark.
  /// [node]: The Stager node where the geometry will be stored.
  static void parseGeometry(XmlElement element, KMLPlacemarkNode node) {
    // Adhering to the optimized branch order by checking for the most 
    // common geometry types first. Using an if-else chain to adhere to the 
    // Single Return Principle (logical exit point).
    if (element.getElement('Point') != null) {
      parsePointGeometry(element, node);
    } else if (element.getElement('LineString') != null) {
      parseLineStringGeometry(element, node);
    } else {
      parsePolygonGeometry(element, node);
    }
  }

  /// Parses a `<Point>` geometry from the given [element] and updates the [node].
  ///
  /// [element]: The XML element representing the Placemark.
  /// [node]: The Stager node to update with Point coordinates.
  static void parsePointGeometry(XmlElement element, KMLPlacemarkNode node) {
    final point = element.getElement('Point');
    if (point != null) {
      final coords = point.getElement('coordinates')?.innerText;
      if (coords != null) {
        final latLng = parseCoordinate(coords);
        if (latLng != null) {
          node.properties.setProperty('latitude', latLng.latitude);
          node.properties.setProperty('longitude', latLng.longitude);
        }
      }
    }
  }

  /// Parses a `<LineString>` geometry from the given [element] and updates 
  /// the [node].
  ///
  /// [element]: The XML element representing the Placemark.
  /// [node]: The Stager node to update with LineString coordinates.
  static void parseLineStringGeometry(XmlElement element, KMLPlacemarkNode node) {
    final lineString = element.getElement('LineString');
    if (lineString != null) {
      final coords = lineString.getElement('coordinates')?.innerText;
      if (coords != null) {
        final points = parseCoordinateList(coords);
        if (points.isNotEmpty) {
          final outline = points.map((p) => {
            'latitude': p.latitude,
            'longitude': p.longitude,
          }).toList();
          node.properties.setProperty('outline', outline);
        }
      }
    }
  }

  /// Parses a `<Polygon>` geometry from the given [element] and updates 
  /// the [node].
  ///
  /// [element]: The XML element representing the Placemark.
  /// [node]: The Stager node to update with Polygon coordinates.
  static void parsePolygonGeometry(XmlElement element, KMLPlacemarkNode node) {
    final polygon = element.getElement('Polygon');
    if (polygon != null) {
      final outer = polygon.getElement('outerBoundaryIs')
                           ?.getElement('LinearRing')
                           ?.getElement('coordinates')?.innerText;
      if (outer != null) {
        final points = parseCoordinateList(outer);
        if (points.isNotEmpty) {
          final outline = points.map((p) => {
            'latitude': p.latitude,
            'longitude': p.longitude,
          }).toList();
          node.properties.setProperty('outline', outline);
        }
      }
    }
  }

  /// Parses a single KML coordinate string into a [LatLng] object.
  ///
  /// [raw]: A coordinate string in the format "longitude,latitude[,altitude]".
  ///
  /// Returns a [LatLng] with the values correctly swapped to (latitude, 
  /// longitude), or null if parsing fails.
  static LatLng? parseCoordinate(String raw) {
    late LatLng? result;
    // KML standard is lon,lat,alt. We must trim and split.
    final parts = raw.trim().split(',');
    if (parts.length >= 2) {
      final lon = double.tryParse(parts[0]);
      final lat = double.tryParse(parts[1]);
      if (lon != null && lat != null) {
        // Crucial Swap: KML is Lon,Lat; Stager/Leaflet is Lat,Lon.
        result = LatLng(lat, lon);
      } else {
        result = null;
      }
    } else {
      result = null;
    }
    return result;
  }
  
  /// Parses a space-separated list of KML coordinates.
  ///
  /// [raw]: A string containing multiple coordinate tuples.
  ///
  /// Returns a [List] of [LatLng] objects.
  static List<LatLng> parseCoordinateList(String raw) {
     // Coordinates in KML lists are separated by whitespace.
     final tuples = raw.trim().split(RegExp(r'\s+'));
     final points = <LatLng>[];
     for (final tuple in tuples) {
       final pt = parseCoordinate(tuple);
       if (pt != null) {
         points.add(pt);
       }
     }
     return points;
  }
}
