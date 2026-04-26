// External packages
import 'package:xml/xml.dart';

// Project files
import '../system/point.dart';
import '../system/typed_value.dart';
import 'nodes/kml_document_node.dart';
import 'nodes/kml_folder_node.dart';
import 'nodes/kml_placemark_node.dart';
import 'nodes/kml_point_node.dart';
import 'nodes/kml_path_node.dart';
import 'nodes/kml_polygon_node.dart';
import 'kml_hole.dart';
import 'style/kml_icon_style.dart';
import 'style/kml_line_style.dart';
import 'style/kml_poly_style.dart';
import 'style/kml_style_manager.dart';

/// A utility class containing static methods for parsing KML elements and 
/// creating specialized Stager nodes following the redesigned hierarchy.
class KMLParserUtils {
  /// Extracts LineStyle information from a `<Style>` element.
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

  /// Creates a [KMLDocumentNode] from a `<Document>` element.
  static KMLDocumentNode createDocumentNode(
    XmlElement element, 
    KMLStyleManager styleManager,
  ) {
    final name = element.getElement('name')?.innerText ?? 'Unnamed Document';
    final styleUrl = element.getElement('styleUrl')?.innerText ?? 'default';

    return KMLDocumentNode(
      name: name,
      styleManager: styleManager,
      styleUrl: styleUrl,
    );
  }

  /// Creates a [KMLFolderNode] from a `<Folder>` element.
  static KMLFolderNode createFolderNode(
    XmlElement element, 
    KMLStyleManager styleManager,
  ) {
    final name = element.getElement('name')?.innerText ?? 'Unnamed Folder';

    return KMLFolderNode(
      name: name
    );
  }

  /// Creates a [KMLPlacemarkNode] from a `<Placemark>` element.
  static KMLPlacemarkNode createPlacemarkNode(
    XmlElement element, 
    KMLStyleManager styleManager,
  ) {
    final name = element.getElement('name')?.innerText ?? 'Unnamed Placemark';
    final styleUrl = element.getElement('styleUrl')?.innerText ?? 'default';

    final node = KMLPlacemarkNode(
      name: name,
      styleManager: styleManager,
      styleUrl: styleUrl,
    );

    // Capture feature attributes.
    final desc = element.getElement('description')?.innerText;
    if (desc != null) {
      node.setProperty('description', TypedValue<String>(desc));
    }

    return node;
  }

  /// Extracts geometries from a `<Placemark>` or `<MultiGeometry>` element
  /// and adds them as children to the [parentNode].
  ///
  /// This method iterates through Point, LineString, and Polygon elements,
  /// instantiating specialized nodes and adding them to the hierarchy. It
  /// throws a [FormatException] if any geometry is invalid.
  static void parseGeometries(
    XmlElement element,
    KMLPlacemarkNode parentNode,
    KMLStyleManager styleManager,
  ) {
    final multiGeo = element.getElement('MultiGeometry');
    final target = multiGeo ?? element;

    // Point
    for (final el in target.findElements('Point')) {
      parentNode.addChild(parsePointGeometry(el, styleManager));
    }

    // LineString
    for (final el in target.findElements('LineString')) {
      parentNode.addChild(parseLineStringGeometry(el, styleManager));
    }

    // Polygon
    for (final el in target.findElements('Polygon')) {
      parentNode.addChild(parsePolygonGeometry(el, styleManager));
    }
  }

  /// Parses a `<Point>` element and returns a [KMLPointNode].
  ///
  /// [element]: The `<Point>` XML element.
  /// [styleManager]: The manager for resolving styles.
  ///
  /// Returns a new [KMLPointNode].
  ///
  /// Throws [FormatException] if coordinates are missing or invalid.
  static KMLPointNode parsePointGeometry(
    XmlElement element, 
    KMLStyleManager styleManager,
  ) {
    late KMLPointNode node;
    final coords = element.getElement('coordinates')?.innerText;
    
    if (coords != null) {
      final point = parseCoordinate(coords);
      node = KMLPointNode(
        name: 'Point',
        styleManager: styleManager,
      );
      node.position = point;
    } else {
      throw const FormatException('KML Point missing coordinates');
    }
    
    return node;
  }

  /// Parses a `<LineString>` element and returns a [KMLPathNode].
  ///
  /// [element]: The `<LineString>` XML element.
  /// [styleManager]: The manager for resolving styles.
  ///
  /// Returns a new [KMLPathNode].
  ///
  /// Throws [FormatException] if coordinates are missing or empty.
  static KMLPathNode parseLineStringGeometry(
    XmlElement element, 
    KMLStyleManager styleManager,
  ) {
    late KMLPathNode node;
    final coords = element.getElement('coordinates')?.innerText;
    
    if (coords != null) {
      final points = parseCoordinateList(coords);
      if (points.isNotEmpty) {
        node = KMLPathNode(
          name: 'Path',
          outline: points,
          styleManager: styleManager
        );
      } else {
        throw const FormatException('KML LineString has no valid coordinates');
      }
    } else {
      throw const FormatException('KML LineString missing coordinates');
    }
    
    return node;
  }

  /// Parses a `<Polygon>` element and returns a [KMLPolygonNode].
  ///
  /// [element]: The `<Polygon>` XML element.
  /// [styleManager]: The manager for resolving styles.
  ///
  /// Returns a new [KMLPolygonNode].
  ///
  /// Throws [FormatException] if outer boundary coordinates are missing or empty.
  static KMLPolygonNode parsePolygonGeometry(
    XmlElement element, 
    KMLStyleManager styleManager,
  ) {
    late KMLPolygonNode node;
    final outer = element.getElement('outerBoundaryIs')
                         ?.getElement('LinearRing')
                         ?.getElement('coordinates')?.innerText;
                         
    if (outer != null) {
      final points = parseCoordinateList(outer);
      if (points.isNotEmpty) {

        // Parse inner holes if they exist
        final holes = List<KMLHole>.empty(growable: true);
        for (final inner in element.findElements('innerBoundaryIs')) {
          final ring = inner.getElement('LinearRing');
          final ringCoords = ring?.getElement('coordinates')?.innerText;
          if (ringCoords != null) {
            final holePoints = parseCoordinateList(ringCoords);
            if (holePoints.isNotEmpty) {
              holes.add(KMLHole(points: holePoints));
            }
          }
        }

        // Create the node
        node = KMLPolygonNode(
            name: 'Polygon',
            styleManager: styleManager,
            outline: points,
            holes: holes
        );

      } else {
        throw const FormatException('KML Polygon outer boundary has no coordinates');
      }
    } else {
      throw const FormatException('KML Polygon missing outer boundary');
    }
    
    return node;
  }

  /// Parses a single KML coordinate string into a [Point] object.
  ///
  /// [raw]: A coordinate string in the format "longitude,latitude[,altitude]".
  ///
  /// Returns a non-nullable [Point] with values correctly mapped to 
  /// (longitude, latitude, [altitude]).
  ///
  /// Throws [FormatException] if the input string is invalid or malformed.
  static Point parseCoordinate(String raw) {
    late Point result;
    // KML standard is lon,lat,alt. We must trim and split.
    final parts = raw.trim().split(',');
    
    if (parts.length >= 2) {
      final lon = double.tryParse(parts[0]);
      final lat = double.tryParse(parts[1]);
      final alt = parts.length >= 3 ? (double.tryParse(parts[2]) ?? 0.0) : 0.0;
      
      if (lon != null && lat != null) {
        // KML is Lon,Lat,Alt. Point convention is x=lon, y=lat, z=alt.
        result = Point(coords: [lon, lat, alt]);
      } else {
        throw FormatException('KML coordinate contains non-numeric values: $raw');
      }
    } else {
      throw FormatException('Malformed KML coordinate string: $raw');
    }
    
    return result;
  }
  
  /// Parses a space-separated list of KML coordinates.
  ///
  /// [raw]: A string containing multiple coordinate tuples.
  ///
  /// Returns a [List] of [Point] objects.
  static List<Point> parseCoordinateList(String raw) {
     // Coordinates in KML lists are separated by whitespace.
     final tuples = raw.trim().split(RegExp(r'\s+'));
     final points = <Point>[];
     for (final tuple in tuples) {
       try {
         points.add(parseCoordinate(tuple));
       } catch (e) {
         // Skip invalid individual coordinates in a list.
       }
     }
     return points;
  }
}
