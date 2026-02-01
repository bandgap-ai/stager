// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/kml_parser.dart';
import 'package:stager_platform/mapping/nodes/kml_tree_root_node.dart';
import 'package:stager_platform/mapping/nodes/kml_folder_node.dart';
import 'package:stager_platform/mapping/nodes/kml_placemark_node.dart';

/// Integration tests for the [KMLParser] class.
///
/// These tests verify that the parser can correctly transform full KML 
/// documents into Stager node trees, handling nesting, coordinate systems, 
/// and style resolution.
void main() {
  group('KMLParser Tests', () {
    late KMLParser parser;

    setUp(() {
      // Initialize a fresh parser for each test to ensure isolation.
      parser = KMLParser();
    });

    /// Verifies that a minimal KML document with a <Document> root is correctly 
    /// parsed into a [KMLTreeRootNode].
    test('Parses minimal KML with default settings', () {
      // Arrange: A valid KML string with a name.
      const kml = '''
        <kml xmlns="http://www.opengis.net/kml/2.2">
          <Document>
            <name>Test Document</name>
          </Document>
        </kml>
      ''';

      // Act: Parse the document.
      final root = parser.parse(kml);

      // Assert: Verify the root node type and its properties.
      expect(root, isA<KMLTreeRootNode>());
      expect(root.properties.getProperty("name"), 'Test Document');
      expect(root.children, isEmpty);
    });

    /// Verifies that nested <Folder> and <Placemark> elements are correctly 
    /// mapped to the Stager tree hierarchy.
    test('Parses nested Folders and Placemarks', () {
      // Arrange: A KML document with a nested folder structure.
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

      // Act: Parse the nested structure.
      final root = parser.parse(kml);

      // Assert: Verify the hierarchy and child counts.
      expect(root.children.length, 1);
      
      final folder = root.children.first as KMLFolderNode;
      expect(folder.properties.getProperty("name"), 'Folder 1');
      expect(folder.children.length, 1);

      final placemark = folder.children.first as KMLPlacemarkNode;
      expect(placemark.properties.getProperty("name"), 'Placemark 1');
    });

    /// Verifies that <Point> geometries are correctly extracted and that 
    /// Lon,Lat coordinates are swapped to Stager's Lat,Lon format.
    test('Parses Point Geometry and swaps coordinates', () {
      // Arrange: A Placemark with a specific Lon,Lat coordinate.
      const kml = '''
        <kml>
          <Placemark>
            <Point>
              <coordinates> -122.0,37.0 </coordinates>
            </Point>
          </Placemark>
        </kml>
      ''';

      // Act: Parse the point feature.
      final root = parser.parse(kml);
      
      // Assert: Verify the coordinate swap logic.
      final placemark = root.children.first as KMLPlacemarkNode;
      
      final lat = placemark.properties.getProperty('latitude') as double;
      final lon = placemark.properties.getProperty('longitude') as double;

      // KML spec uses Lon,Lat order. Stager uses Lat,Lon.
      expect(lat, closeTo(37.0, 0.0001));
      expect(lon, closeTo(-122.0, 0.0001));
    });

    /// Verifies that styles defined *after* their usage in the XML document 
    /// are correctly resolved via the [KMLStyleManager].
    test('Resolves forward-referenced styles', () {
      // Arrange: Placemark references 'myStyle' before it is defined.
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

      // Act: Parse the document containing forward references.
      final root = parser.parse(kml);
      final placemark = root.children.first as KMLPlacemarkNode;
      
      // Assert: Verify that the style component was correctly populated.
      final style = placemark.kmlStyle;
      expect(style.id, 'myStyle');
      expect(style.iconStyle.scale, 1.5);
    });
  });
}
