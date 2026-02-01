// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// External packages
import 'package:xml/xml.dart';

// Project files
import 'package:stager_platform/mapping/kml_parser_utils.dart';
import 'package:stager_platform/mapping/nodes/kml_placemark_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// Unit tests for the [KMLParserUtils] class.
///
/// These tests verify the granular transformation logic from KML XML fragments 
/// to strongly-typed style components, Stager nodes, and geographic data.
void main() {
  group('KMLParserUtils', () {
    /// Tests for parsing individual style components from XML elements.
    group('Style Parsing', () {
      /// Verifies that <LineStyle> attributes (color, width) are correctly extracted.
      test('parseLineStyle extracts color and width', () {
        final xml = XmlDocument.parse(
            '<Style><LineStyle><color>ff0000ff</color><width>2.5</width></LineStyle></Style>');
        final style = KMLParserUtils.parseLineStyle(xml.rootElement);
        expect(style.color, 'ff0000ff');
        expect(style.width, 2.5);
      });

      /// Verifies that <PolyStyle> attributes (fill, outline) are correctly extracted.
      test('parsePolyStyle extracts fill and outline', () {
        final xml = XmlDocument.parse(
            '<Style><PolyStyle><fill>0</fill><outline>1</outline></PolyStyle></Style>');
        final style = KMLParserUtils.parsePolyStyle(xml.rootElement);
        expect(style.fill, isFalse);
        expect(style.outline, isTrue);
      });

      /// Verifies that <IconStyle> attributes (href, scale) are correctly extracted.
      test('parseIconStyle extracts href and scale', () {
        final xml = XmlDocument.parse(
            '<Style><IconStyle><scale>1.5</scale><Icon><href>test.png</href></Icon></IconStyle></Style>');
        final style = KMLParserUtils.parseIconStyle(xml.rootElement);
        expect(style.scale, 1.5);
        expect(style.href, 'test.png');
      });
    });

    /// Tests for creating specialized KML nodes from XML elements.
    group('Node Creation', () {
      late KMLStyleManager manager;

      setUp(() {
        manager = KMLStyleManager();
      });

      /// Verifies that a folder node is correctly instantiated with metadata.
      test('createFolderNode sets basic properties', () {
        final xml = XmlDocument.parse(
            '<Folder id="f1"><name>My Folder</name></Folder>');
        final node = KMLParserUtils.createFolderNode(xml.rootElement, manager);
        // Correctly accessing properties via the underlying source of truth.
        expect(node.properties.getProperty('id'), 'f1');
        expect(node.properties.getProperty('name'), 'My Folder');
      });

      /// Verifies that a placemark node extracts its name, description, and geometry.
      test('createPlacemarkNode extracts description and geometry', () {
        final xml = XmlDocument.parse('''
          <Placemark id="pm1">
            <name>Point 1</name>
            <description>A point</description>
            <Point><coordinates>10,20</coordinates></Point>
          </Placemark>
        ''');
        final node =
            KMLParserUtils.createPlacemarkNode(xml.rootElement, manager);
        // Correctly accessing properties via the underlying source of truth.
        expect(node.properties.getProperty('id'), 'pm1');
        expect(node.properties.getProperty('name'), 'Point 1');
        expect(node.properties.getProperty('description'), 'A point');
        expect(node.properties.getProperty('latitude'), 20.0);
        expect(node.properties.getProperty('longitude'), 10.0);
      });
    });

    /// Tests for parsing different KML geometry types.
    group('Geometry Parsing', () {
      late KMLStyleManager manager;
      late KMLPlacemarkNode node;

      setUp(() {
        manager = KMLStyleManager();
        node = KMLPlacemarkNode(id: 'test', name: 'test', styleManager: manager);
      });

      /// Verifies extraction of valid point coordinates.
      test('parsePointGeometry extracts valid coordinates', () {
        final xml =
            XmlDocument.parse('<Placemark><Point><coordinates>10,20</coordinates></Point></Placemark>');
        KMLParserUtils.parsePointGeometry(xml.rootElement, node);
        expect(node.properties.getProperty('latitude'), 20.0);
        expect(node.properties.getProperty('longitude'), 10.0);
      });

      /// Verifies graceful handling of point elements with missing coordinates.
      test('parsePointGeometry handles missing coordinates', () {
        final xml = XmlDocument.parse('<Placemark><Point></Point></Placemark>');
        KMLParserUtils.parsePointGeometry(xml.rootElement, node);
        expect(node.properties.getProperty('latitude'), isNull);
      });

      /// Verifies extraction of a valid line string path.
      test('parseLineStringGeometry extracts valid outline', () {
        final xml = XmlDocument.parse(
            '<Placemark><LineString><coordinates>10,20 30,40</coordinates></LineString></Placemark>');
        KMLParserUtils.parseLineStringGeometry(xml.rootElement, node);
        final outline = node.properties.getProperty('outline') as List;
        expect(outline.length, 2);
        expect(outline[0]['latitude'], 20.0);
        expect(outline[1]['latitude'], 40.0);
      });

      /// Verifies graceful handling of empty coordinate lists in line strings.
      test('parseLineStringGeometry handles empty coordinates', () {
        final xml = XmlDocument.parse(
            '<Placemark><LineString><coordinates></coordinates></LineString></Placemark>');
        KMLParserUtils.parseLineStringGeometry(xml.rootElement, node);
        expect(node.properties.getProperty('outline'), isNull);
      });

      /// Verifies extraction of a polygon's outer boundary.
      test('parsePolygonGeometry extracts valid outer boundary', () {
        final xml = XmlDocument.parse('''
          <Placemark>
            <Polygon>
              <outerBoundaryIs>
                <LinearRing>
                  <coordinates>10,20 30,40 10,20</coordinates>
                </LinearRing>
              </outerBoundaryIs>
            </Polygon>
          </Placemark>
        ''');
        KMLParserUtils.parsePolygonGeometry(xml.rootElement, node);
        final outline = node.properties.getProperty('outline') as List;
        expect(outline.length, 3);
        expect(outline[0]['latitude'], 20.0);
      });

      /// Verifies graceful handling of malformed polygon structures.
      test('parsePolygonGeometry handles missing nested elements', () {
        final xml = XmlDocument.parse('<Placemark><Polygon></Polygon></Placemark>');
        KMLParserUtils.parsePolygonGeometry(xml.rootElement, node);
        expect(node.properties.getProperty('outline'), isNull);
      });
    });

    /// Tests for low-level coordinate string parsing.
    group('Coordinate Utilities', () {
      /// Verifies that Lon,Lat strings are correctly swapped to Lat,Lon LatLng objects.
      test('parseCoordinate swaps lon/lat', () {
        final point = KMLParserUtils.parseCoordinate('-122.0,37.0');
        expect(point?.latitude, 37.0);
        expect(point?.longitude, -122.0);
      });

      /// Verifies parsing of space-separated coordinate lists.
      test('parseCoordinateList handles multiple tuples', () {
        final points = KMLParserUtils.parseCoordinateList('10,20 30,40');
        expect(points.length, 2);
        expect(points[0].latitude, 20.0);
        expect(points[1].latitude, 40.0);
      });
    });
  });
}
