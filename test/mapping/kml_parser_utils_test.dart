// External packages
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

// Project files
import 'package:stager_platform/mapping/kml_parser_utils.dart';
import 'package:stager_platform/mapping/nodes/kml_placemark_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

void main() {
  group('KMLParserUtils', () {
    group('Style Parsing', () {
      test('parseLineStyle extracts color and width', () {
        final xml = XmlDocument.parse(
            '<Style><LineStyle><color>ff0000ff</color><width>2.5</width></LineStyle></Style>');
        final style = KMLParserUtils.parseLineStyle(xml.rootElement);
        expect(style.color, 'ff0000ff');
        expect(style.width, 2.5);
      });

      test('parsePolyStyle extracts fill and outline', () {
        final xml = XmlDocument.parse(
            '<Style><PolyStyle><fill>0</fill><outline>1</outline></PolyStyle></Style>');
        final style = KMLParserUtils.parsePolyStyle(xml.rootElement);
        expect(style.fill, isFalse);
        expect(style.outline, isTrue);
      });

      test('parseIconStyle extracts href and scale', () {
        final xml = XmlDocument.parse(
            '<Style><IconStyle><scale>1.5</scale><Icon><href>test.png</href></Icon></IconStyle></Style>');
        final style = KMLParserUtils.parseIconStyle(xml.rootElement);
        expect(style.scale, 1.5);
        expect(style.href, 'test.png');
      });
    });

    group('Node Creation', () {
      late KMLStyleManager manager;

      setUp(() {
        manager = KMLStyleManager();
      });

      test('createFolderNode sets basic properties', () {
        final xml = XmlDocument.parse(
            '<Folder id="f1"><name>My Folder</name></Folder>');
        final node = KMLParserUtils.createFolderNode(xml.rootElement, manager);
        // Correctly accessing properties via the underlying source of truth.
        expect(node.properties.getProperty('id'), 'f1');
        expect(node.properties.getProperty('name'), 'My Folder');
      });

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

    group('Geometry Parsing', () {
      late KMLStyleManager manager;
      late KMLPlacemarkNode node;

      setUp(() {
        manager = KMLStyleManager();
        node = KMLPlacemarkNode(id: 'test', name: 'test', styleManager: manager);
      });

      test('parsePointGeometry extracts valid coordinates', () {
        final xml =
            XmlDocument.parse('<Placemark><Point><coordinates>10,20</coordinates></Point></Placemark>');
        KMLParserUtils.parsePointGeometry(xml.rootElement, node);
        expect(node.properties.getProperty('latitude'), 20.0);
        expect(node.properties.getProperty('longitude'), 10.0);
      });

      test('parsePointGeometry handles missing coordinates', () {
        final xml = XmlDocument.parse('<Placemark><Point></Point></Placemark>');
        KMLParserUtils.parsePointGeometry(xml.rootElement, node);
        expect(node.properties.getProperty('latitude'), isNull);
      });

      test('parseLineStringGeometry extracts valid outline', () {
        final xml = XmlDocument.parse(
            '<Placemark><LineString><coordinates>10,20 30,40</coordinates></LineString></Placemark>');
        KMLParserUtils.parseLineStringGeometry(xml.rootElement, node);
        final outline = node.properties.getProperty('outline') as List;
        expect(outline.length, 2);
        expect(outline[0]['latitude'], 20.0);
        expect(outline[1]['latitude'], 40.0);
      });

      test('parseLineStringGeometry handles empty coordinates', () {
        final xml = XmlDocument.parse(
            '<Placemark><LineString><coordinates></coordinates></LineString></Placemark>');
        KMLParserUtils.parseLineStringGeometry(xml.rootElement, node);
        expect(node.properties.getProperty('outline'), isNull);
      });

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

      test('parsePolygonGeometry handles missing nested elements', () {
        final xml = XmlDocument.parse('<Placemark><Polygon></Polygon></Placemark>');
        KMLParserUtils.parsePolygonGeometry(xml.rootElement, node);
        expect(node.properties.getProperty('outline'), isNull);
      });
    });

    group('Coordinate Utilities', () {
      test('parseCoordinate swaps lon/lat', () {
        final point = KMLParserUtils.parseCoordinate('-122.0,37.0');
        expect(point?.latitude, 37.0);
        expect(point?.longitude, -122.0);
      });

      test('parseCoordinateList handles multiple tuples', () {
        final points = KMLParserUtils.parseCoordinateList('10,20 30,40');
        expect(points.length, 2);
        expect(points[0].latitude, 20.0);
        expect(points[1].latitude, 40.0);
      });
    });
  });
}
