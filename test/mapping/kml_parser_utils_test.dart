// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// External packages
import 'package:xml/xml.dart';

// Project files
import 'package:stager_platform/mapping/kml_parser_utils.dart';
import 'package:stager_platform/mapping/nodes/kml_placemark_node.dart';
import 'package:stager_platform/mapping/nodes/kml_point_node.dart';
import 'package:stager_platform/mapping/nodes/kml_path_node.dart';
import 'package:stager_platform/mapping/nodes/kml_polygon_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';
import 'package:stager_platform/system/point.dart';

/// Unit tests for the [KMLParserUtils] class.
void main() {
  group('KMLParserUtils Tests', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    group('parseGeometries', () {
      late KMLPlacemarkNode placemark;

      setUp(() {
        manager = KMLStyleManager();
        placemark = KMLPlacemarkNode(
          name: 'Test Placemark',
          styleManager: manager,
        );
      });

      test('throws FormatException if a Point geometry is invalid', () {
        // Create an empty Point element to trigger a parsing failure.
        final xml = XmlDocument.parse('''
          <Placemark>
            <Point></Point>
          </Placemark>
        ''');

        // Verify that the parser enforces coordinate presence.
        expect(
          () => KMLParserUtils.parseGeometries(
            xml.rootElement,
            placemark,
            manager,
          ),
          throwsA(isA<FormatException>()),
        );
      });

      test('throws FormatException if a LineString geometry is invalid', () {
        // Create a LineString element with empty coordinates.
        final xml = XmlDocument.parse('''
          <Placemark>
            <LineString><coordinates></coordinates></LineString>
          </Placemark>
        ''');

        // Verify that empty coordinate lists are treated as invalid.
        expect(
          () => KMLParserUtils.parseGeometries(
            xml.rootElement,
            placemark,
            manager,
          ),
          throwsA(isA<FormatException>()),
        );
      });

      test('throws FormatException if a Polygon geometry is invalid', () {
        // Create a Polygon missing its mandatory boundary tags.
        final xml = XmlDocument.parse('''
          <Placemark>
            <Polygon></Polygon>
          </Placemark>
        ''');

        // Verify that structural requirements for polygons are enforced.
        expect(
          () => KMLParserUtils.parseGeometries(
            xml.rootElement,
            placemark,
            manager,
          ),
          throwsA(isA<FormatException>()),
        );
      });

      test('successfully parses valid geometries', () {
        // Construct a placemark containing both a point and a line string.
        final xml = XmlDocument.parse('''
          <Placemark>
            <Point><coordinates>1,2</coordinates></Point>
            <LineString><coordinates>3,4 5,6</coordinates></LineString>
          </Placemark>
        ''');

        // Execute parsing logic.
        KMLParserUtils.parseGeometries(xml.rootElement, placemark, manager);

        // Verify that the child nodes are correctly instantiated and typed.
        expect(placemark.children.length, 2);
        expect(placemark.children[0], isA<KMLPointNode>());
        expect(placemark.children[1], isA<KMLPathNode>());
      });
    });

    group('Geometry Parsing', () {
      test('parsePointGeometry returns KMLPointNode with correct Point', () {
        // Define a coordinate string (lon=10, lat=20).
        final xml =
            XmlDocument.parse('<Point><coordinates>10,20</coordinates></Point>');

        // Rehydrate the node from XML.
        final node = KMLParserUtils.parsePointGeometry(xml.rootElement, manager);

        // Confirm reification to the Point class with correct coordinate mapping.
        expect(node, isA<KMLPointNode>());
        expect(node.position.x, 10.0); // longitude
        expect(node.position.y, 20.0); // latitude
      });

      test('parsePointGeometry throws FormatException for missing coordinates',
          () {
        final xml = XmlDocument.parse('<Point></Point>');

        expect(
          () => KMLParserUtils.parsePointGeometry(xml.rootElement, manager),
          throwsA(isA<FormatException>()),
        );
      });

      test('parseLineStringGeometry returns KMLPathNode with correct Points', () {
        // Define a LineString with multiple coordinate pairs.
        final xml = XmlDocument.parse(
            '<LineString><coordinates>10,20 30,40</coordinates></LineString>');

        // Execute rehydration.
        final node =
            KMLParserUtils.parseLineStringGeometry(xml.rootElement, manager);

        // Verify that the outline member contains the reified points.
        expect(node, isA<KMLPathNode>());
        expect(node.outline.length, 2);
        expect(node.outline[0].x, 10.0);
        expect(node.outline[0].y, 20.0);
      });

      test('parsePolygonGeometry returns KMLPolygonNode with correct geometry', () {
        // Construct a polygon with an outer boundary and one inner hole.
        final xml = XmlDocument.parse('''
          <Polygon>
            <outerBoundaryIs>
              <LinearRing>
                <coordinates>10,20 30,40 10,20</coordinates>
              </LinearRing>
            </outerBoundaryIs>
            <innerBoundaryIs>
              <LinearRing>
                <coordinates>15,25 20,30 15,25</coordinates>
              </LinearRing>
            </innerBoundaryIs>
          </Polygon>
        ''');

        // Execute rehydration.
        final node =
            KMLParserUtils.parsePolygonGeometry(xml.rootElement, manager);

        // Confirm reification of both outer and inner geometric boundaries.
        expect(node, isA<KMLPolygonNode>());
        expect(node.outline.length, 3);
        expect(node.outline[0].x, 10.0);
        expect(node.holes.length, 1);
        expect(node.holes[0].points.length, 3);
        expect(node.holes[0].points[0].x, 15.0);
      });
    });

    group('Coordinate Parsing', () {
      test('parseCoordinate handles 2D and 3D strings', () {
        // Verify parsing for standard 2D coordinates.
        final p2d = KMLParserUtils.parseCoordinate('1.1,2.2');
        expect(p2d.x, 1.1);
        expect(p2d.y, 2.2);
        expect(p2d.z, 0.0);
        
        // Verify parsing for 3D coordinates (with altitude).
        final p3d = KMLParserUtils.parseCoordinate('10,20,30');
        expect(p3d.x, 10.0);
        expect(p3d.y, 20.0);
        expect(p3d.z, 30.0);
      });

      test('parseCoordinateList handles whitespace and newlines', () {
        // Define a list of coordinates with varied spacing.
        const raw = '1,2 3,4\n5,6';

        // Rehydrate the coordinate list.
        final points = KMLParserUtils.parseCoordinateList(raw);

        // Verify count and individual mapping integrity.
        expect(points.length, 3);
        expect(points[2].x, 5.0);
        expect(points[2].y, 6.0);
      });
    });
  });
}
