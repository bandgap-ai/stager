import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/kml_parser.dart';
import 'package:stager_platform/mapping/nodes/kml_tree_root_node.dart';
import 'package:stager_platform/mapping/nodes/kml_folder_node.dart';
import 'package:stager_platform/mapping/nodes/kml_placemark_node.dart';

void main() {
  group('KmlParser Tests', () {
    late KmlParser parser;

    setUp(() {
      parser = KmlParser();
    });

    test('Parses minimal KML with default settings', () {
      const kml = '''
        <kml xmlns="http://www.opengis.net/kml/2.2">
          <Document>
            <name>Test Document</name>
          </Document>
        </kml>
      ''';

      final root = parser.parse(kml);
      expect(root, isA<KmlTreeRootNode>());
      expect(root.properties.getProperty("name"), 'Test Document');
      expect(root.children, isEmpty);
    });

    test('Parses nested Folders and Placemarks', () {
      const kml = '''
        <kml>
          <Document>
            <Folder>
              <name>Folder 1</name>
              <Placemark>
                <name>Placemark 1</name>
              </Placemark>
            </Folder>
          </Document>
        </kml>
      ''';

      final root = parser.parse(kml);
      expect(root.children.length, 1);
      
      final folder = root.children.first as KmlFolderNode;
      expect(folder.properties.getProperty("name"), 'Folder 1');
      expect(folder.children.length, 1);

      final placemark = folder.children.first as KmlPlacemarkNode;
      expect(placemark.properties.getProperty("name"), 'Placemark 1');
    });

    test('Parses Point Geometry and swaps coordinates', () {
      const kml = '''
        <kml>
          <Placemark>
            <Point>
              <coordinates> -122.0,37.0 </coordinates>
            </Point>
          </Placemark>
        </kml>
      ''';

      final root = parser.parse(kml);
      // Since no <Document>, root adds children directly
      final placemark = root.children.first as KmlPlacemarkNode;
      
      final lat = placemark.properties.getProperty('latitude') as double;
      final lon = placemark.properties.getProperty('longitude') as double;

      expect(lat, closeTo(37.0, 0.0001));
      expect(lon, closeTo(-122.0, 0.0001));
    });

    test('Resolves forward-referenced styles', () {
      const kml = '''
        <kml>
          <Document>
            <Placemark>
              <styleUrl>#myStyle</styleUrl>
            </Placemark>
            <Style id="myStyle">
              <IconStyle>
                <scale>1.5</scale>
              </IconStyle>
            </Style>
          </Document>
        </kml>
      ''';

      final root = parser.parse(kml);
      final placemark = root.children.first as KmlPlacemarkNode;
      
      final style = placemark.kmlStyle;
      expect(style, isNotNull);
      expect(style?.id, 'myStyle');
      expect(style?.iconScale, 1.5);
    });
  });
}
