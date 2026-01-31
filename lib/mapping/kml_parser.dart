import 'dart:collection';
import 'package:xml/xml.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';

import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/mapping/nodes/kml_tree_root_node.dart';
import 'package:stager_platform/mapping/nodes/kml_folder_node.dart';
import 'package:stager_platform/mapping/nodes/kml_placemark_node.dart';
import 'package:stager_platform/mapping/style/kml_style.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// Parses KML (Keyhole Markup Language) content into a Stager node tree.
///
/// This parser is:
/// *   **Iterative**: Avoids recursion to prevent stack overflow on deep trees.
/// *   **Single-Pass**: Collects styles and builds the tree efficiently.
/// *   **Robust**: Handles missing/optional elements and coordinate ordering.
class KmlParser {
  final Logger _logger = Logger();
  final KmlStyleManager _styleManager = KmlStyleManager();

  /// Parses the given [xmlContent] string and returns the root of the node tree.
  ///
  /// Throws [XmlException] or [FormatException] if parsing fails.
  KmlTreeRootNode parse(String xmlContent) {
    try {
      final document = XmlDocument.parse(xmlContent);
      
      // 1. Register Styles
      _registerStyles(document);

      // 2. Build Tree
      return _buildTree(document);
    } catch (e) {
      _logger.e('Failed to parse KML content', error: e);
      rethrow;
    }
  }

  void _registerStyles(XmlDocument document) {
    _styleManager.clear();
    final styles = document.findAllElements('Style');
    for (final styleElement in styles) {
      final id = styleElement.getAttribute('id') ?? '';
      if (id.isEmpty) continue;

      String? lineColor;
      double? lineWidth;
      String? polyColor;
      bool? polyFill;
      bool? polyOutline;
      double? iconScale;
      String? iconHref;

      // Parse LineStyle
      final lineStyle = styleElement.getElement('LineStyle');
      if (lineStyle != null) {
        lineColor = lineStyle.getElement('color')?.innerText;
        final widthText = lineStyle.getElement('width')?.innerText;
        if (widthText != null) lineWidth = double.tryParse(widthText);
      }

      // Parse PolyStyle
      final polyStyle = styleElement.getElement('PolyStyle');
      if (polyStyle != null) {
        polyColor = polyStyle.getElement('color')?.innerText;
        final fillText = polyStyle.getElement('fill')?.innerText;
        if (fillText != null) polyFill = fillText == '1' || fillText.toLowerCase() == 'true';
        
        final outlineText = polyStyle.getElement('outline')?.innerText;
        if (outlineText != null) polyOutline = outlineText == '1' || outlineText.toLowerCase() == 'true';
      }

      // Parse IconStyle
      final iconStyle = styleElement.getElement('IconStyle');
      if (iconStyle != null) {
        final scaleText = iconStyle.getElement('scale')?.innerText;
        if (scaleText != null) iconScale = double.tryParse(scaleText);
        iconHref = iconStyle.getElement('Icon')?.getElement('href')?.innerText;
      }

      final kmlStyle = KmlStyle(
        id: id,
        lineColor: lineColor,
        lineWidth: lineWidth,
        polyColor: polyColor,
        polyFill: polyFill,
        polyOutline: polyOutline,
        iconScale: iconScale,
        iconHref: iconHref,
      );

      _styleManager.registerStyle(kmlStyle);
    }
  }

  KmlTreeRootNode _buildTree(XmlDocument document) {
    // Find the logical root element (Document or kml)
    final kmlElement = document.getElement('kml');
    XmlElement? rootContainer = kmlElement?.getElement('Document');
    
    // If no <Document>, use <kml> as the container, or fall back to a default
    // if <kml> has direct children but no Document.
    // Logic: Look for the 'Document' tag. If found, that's our root.
    // If not found, create a synthetic root and add kml's children to it.
    
    String rootId = 'root';
    String rootName = 'KML Document';
    String? rootStyleUrl;
    
    if (rootContainer != null) {
        rootId = rootContainer.getAttribute('id') ?? rootId;
        rootName = rootContainer.getElement('name')?.innerText ?? rootName;
        rootStyleUrl = rootContainer.getElement('styleUrl')?.innerText;
    }

    final treeRoot = KmlTreeRootNode(
      id: rootId,
      name: rootName,
      styleManager: _styleManager,
      styleUrl: rootStyleUrl,
    );

    // Stack for iterative traversal: (XmlElement parentXml, ConcreteCompositeNode parentNode)
    final stack = Queue<MapEntry<XmlElement, ConcreteCompositeNode>>();
    
    // Determine where to start traversing children
    if (rootContainer != null) {
       stack.add(MapEntry(rootContainer, treeRoot));
    } else if (kmlElement != null) {
       // Treating <kml> as a pseudo-container, but we already created treeRoot manually.
       // We need to feed <kml> into the stack but tell it to add to treeRoot.
       stack.add(MapEntry(kmlElement, treeRoot));
    }

    while (stack.isNotEmpty) {
      final entry = stack.removeLast(); // DFS
      final currentXml = entry.key;
      final parentNode = entry.value;

      // Iterate over direct children
      for (final child in currentXml.children) {
        if (child is! XmlElement) continue;

        if (child.name.local == 'Folder' || child.name.local == 'Document') {
           // Treat nested Documents as Folders
           final id = child.getAttribute('id') ?? 'folder_${child.hashCode}';
           final name = child.getElement('name')?.innerText ?? 'Unnamed Folder';
           final styleUrl = child.getElement('styleUrl')?.innerText;

           final folderNode = KmlFolderNode(
             id: id,
             name: name,
             styleManager: _styleManager,
             styleUrl: styleUrl,
           );
           
           parentNode.addChild(folderNode);
           stack.add(MapEntry(child, folderNode));

        } else if (child.name.local == 'Placemark') {
           final id = child.getAttribute('id') ?? 'pm_${child.hashCode}';
           final name = child.getElement('name')?.innerText ?? 'Unnamed Placemark';
           final styleUrl = child.getElement('styleUrl')?.innerText;

           final placemarkNode = KmlPlacemarkNode(
             id: id,
             name: name,
             styleManager: _styleManager,
             styleUrl: styleUrl,
           );

           // Parse Geometry
           _parseGeometry(child, placemarkNode);
           
           // Parse Attributes (description, etc.)
           final desc = child.getElement('description')?.innerText;
           if (desc != null) {
             placemarkNode.properties.setProperty('description', desc);
           }

           parentNode.addChild(placemarkNode);
        }
      }
    }

    return treeRoot;
  }

  void _parseGeometry(XmlElement placemark, KmlPlacemarkNode node) {
    // Check for Point
    final point = placemark.getElement('Point');
    if (point != null) {
      final coords = point.getElement('coordinates')?.innerText;
      if (coords != null) {
        final latLng = _parseCoordinate(coords);
        if (latLng != null) {
          node.properties.setProperty('latitude', latLng.latitude);
          node.properties.setProperty('longitude', latLng.longitude);
        }
      }
      return; // Assume single geometry for simplicity
    }

    // Check for LineString
    final lineString = placemark.getElement('LineString');
    if (lineString != null) {
       final coords = lineString.getElement('coordinates')?.innerText;
       if (coords != null) {
         final points = _parseCoordinateList(coords);
         if (points.isNotEmpty) {
             // Store outline as List<Map<String, double>> for Stager compatibility
             final outline = points.map((p) => {
               'latitude': p.latitude,
               'longitude': p.longitude,
             }).toList();
             node.properties.setProperty('outline', outline);
         }
       }
       return;
    }
    
    // Check for Polygon
    final polygon = placemark.getElement('Polygon');
    if (polygon != null) {
       // Outer boundary
       final outer = polygon.getElement('outerBoundaryIs')?.getElement('LinearRing')?.getElement('coordinates')?.innerText;
       if (outer != null) {
          final points = _parseCoordinateList(outer);
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

  LatLng? _parseCoordinate(String raw) {
    // KML is lon,lat,alt. Trim whitespace.
    final parts = raw.trim().split(',');
    if (parts.length >= 2) {
      final lon = double.tryParse(parts[0]);
      final lat = double.tryParse(parts[1]);
      if (lon != null && lat != null) {
        // Swap to Lat, Lon
        return LatLng(lat, lon);
      }
    }
    return null;
  }
  
  List<LatLng> _parseCoordinateList(String raw) {
     // Space-separated tuples
     final tuples = raw.trim().split(RegExp(r'\s+'));
     final points = <LatLng>[];
     for (final tuple in tuples) {
       final pt = _parseCoordinate(tuple);
       if (pt != null) {
         points.add(pt);
       }
     }
     return points;
  }
}
