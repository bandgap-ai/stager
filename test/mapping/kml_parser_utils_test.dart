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

/// Unit tests for the [KMLParserUtils] class.
void main() {
  group('KMLParserUtils', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    group('parseGeometries', () {
      late KMLPlacemarkNode placemark;

      setUp(() {
        manager = KMLStyleManager();
        placemark = KMLPlacemarkNode(
          id: 'pm1',
          name: 'Test Placemark',
          styleManager: manager,
        );
      });

      test('throws FormatException if a Point geometry is invalid', () {
        // Arrange
        final xml = XmlDocument.parse('''
          <Placemark>
            <Point></Point>
          </Placemark>
        ''');

        // Act & Assert
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
        // Arrange
        final xml = XmlDocument.parse('''
          <Placemark>
            <LineString><coordinates></coordinates></LineString>
          </Placemark>
        ''');

        // Act & Assert
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
        // Arrange
        final xml = XmlDocument.parse('''
          <Placemark>
            <Polygon></Polygon>
          </Placemark>
        ''');

        // Act & Assert
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
        // Arrange
        final xml = XmlDocument.parse('''
          <Placemark>
            <Point><coordinates>1,2</coordinates></Point>
            <LineString><coordinates>3,4 5,6</coordinates></LineString>
          </Placemark>
        ''');

        // Act
        KMLParserUtils.parseGeometries(xml.rootElement, placemark, manager);

        // Assert
        expect(placemark.children.length, 2);
        expect(placemark.children[0], isA<KMLPointNode>());
        expect(placemark.children[1], isA<KMLPathNode>());
      });
    });

    group('Geometry Parsing', () {
      test('parsePointGeometry returns KMLPointNode for valid XML', () {
        // Arrange
        final xml =
            XmlDocument.parse('<Point><coordinates>10,20</coordinates></Point>');

        // Act
        final node = KMLParserUtils.parsePointGeometry(xml.rootElement, manager);

        // Assert
        expect(node, isA<KMLPointNode>());
        final location = node.location;
        expect(location.latitude, 20.0);
        expect(location.longitude, 10.0);
      });

      test('parsePointGeometry throws FormatException for missing coordinates',
          () {
        // Arrange
        final xml = XmlDocument.parse('<Point></Point>');

        // Act & Assert
        expect(
          () => KMLParserUtils.parsePointGeometry(xml.rootElement, manager),
          throwsA(isA<FormatException>()),
        );
      });

      test('parseLineStringGeometry returns KMLPathNode for valid XML', () {
        // Arrange
        final xml = XmlDocument.parse(
            '<LineString><coordinates>10,20 30,40</coordinates></LineString>');

        // Act
        final node =
            KMLParserUtils.parseLineStringGeometry(xml.rootElement, manager);

        // Assert
        expect(node, isA<KMLPathNode>());
        expect(node.outline.length, 2);
        expect(node.outline[0].latitude, 20.0);
      });

      test(
          'parseLineStringGeometry throws FormatException for empty coordinates',
          () {
        // Arrange
        final xml = XmlDocument.parse(
            '<LineString><coordinates></coordinates></LineString>');

        // Act & Assert
        expect(
          () =>
              KMLParserUtils.parseLineStringGeometry(xml.rootElement, manager),
          throwsA(isA<FormatException>()),
        );
      });

      test('parsePolygonGeometry returns KMLPolygonNode for valid XML', () {
        // Arrange
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

        // Act
        final node =
            KMLParserUtils.parsePolygonGeometry(xml.rootElement, manager);

        // Assert
        expect(node, isA<KMLPolygonNode>());
        expect(node.outline.length, 3);
        expect(node.holes.length, 1);
        expect(node.holes[0].points.length, 3);
      });

      test(
          'parsePolygonGeometry throws FormatException for missing outer boundary',
          () {
        // Arrange
        final xml = XmlDocument.parse('<Polygon></Polygon>');

        // Act & Assert
        expect(
          () => KMLParserUtils.parsePolygonGeometry(xml.rootElement, manager),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}
