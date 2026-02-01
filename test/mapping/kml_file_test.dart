// Dart core
import 'dart:io';

// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/kml_file.dart';
import 'package:stager_platform/mapping/nodes/kml_tree_root_node.dart';
import '../helpers/kml_mock.dart';

/// Integration tests for the [KMLFile] class.
///
/// These tests verify the end-to-end flow of KML data ingestion, including:
/// 1. Externalizing XSD schemas to a temporary directory.
/// 2. Validating KML files against those schemas via a native plugin.
/// 3. Parsing the validated KML content into a Stager node tree.
void main() {
  // Ensure the test environment can access Flutter's asset bundle mechanisms.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Register the mock MethodChannel to simulate the native KML validation 
  // plugin across all tests.
  setUpAll(() async {
    await registerKmlMock();
  });

  group('Validation', () {
    final String tmpDirectoryName = 'kml_file_test';
    final String tmpKMLFile = 'kml_wiki_example.xml';
    late Directory tmpDir;
    final String sep = Platform.pathSeparator;

    // Create a temporary, valid KML file on the local file system to be 
    // used as a test target for validation and parsing.
    setUpAll(() async {
      tmpDir = await Directory.systemTemp.createTemp(tmpDirectoryName);
      final file = File('${tmpDir.path}$sep$tmpKMLFile');
      await file.writeAsString('''
<?xml version="1.0" encoding="UTF-8"?>
<!-- Wikipedia KML example document -->
<kml xmlns="http://www.opengis.net/kml/2.2">
    <Document>
        <Placemark>
            <name>New York City</name>
            <description>New York City</description>
            <Point>
                <coordinates>-74.006393,40.714172,0</coordinates>
            </Point>
        </Placemark>
    </Document>
</kml>
''');
      return;
    });

    // Cleanup: Ensure temporary test files are removed after the group finishes.
    tearDownAll(() async {
      if (await tmpDir.exists()) {
        tmpDir.delete(recursive: true);
      }
    });

    /// Verifies that the KMLFile class correctly copies XSD schema assets 
    /// from the Flutter bundle to a temporary directory accessible by 
    /// native code.
    test('Confirm KML Schema Loaded', () async {
      File kmlFile = File('${tmpDir.path}/$tmpKMLFile');
      String kmlPath = kmlFile.path;
      
      KMLFile kml = KMLFile(kmlXMLLocation: kmlPath);
      // load() must be awaited to ensure the copy operation completes.
      await kml.load();
      
      expect(kml.schemaExists, true);
    });

    /// Verifies that a structurally correct KML file is successfully 
    /// validated (result 0) against the official schema.
    test('Validate Correct KML File', () async {
      File kmlFile = File('${tmpDir.path}/$tmpKMLFile');
      String kmlPath = kmlFile.path;
      
      KMLFile kml = KMLFile(kmlXMLLocation: kmlPath);
      await kml.load();
      
      // Act & Assert: result 0 indicates success.
      expect(await kml.validate(), 0);
    });

    /// Verifies that the validation mechanism correctly identifies and 
    /// rejects non-KML or malformed files.
    test('Validate Incorrect KML File', () async {
      // Use an empty path to trigger a validation failure.
      KMLFile kml = KMLFile(kmlXMLLocation: '');
      await kml.load();
      
      // Act & Assert: non-zero result indicates failure.
      expect(await kml.validate(), 1);
    });
  });

  group('Parsing', () {
    /// Verifies that KMLFile.parse() correctly coordinates the full 
    /// transformation from a file on disk to a functional Stager node tree.
    test('Integration: KMLFile.parse() handles full KML document structure', () async {
      // Arrange: Create a KML file with a shared style and a point feature.
      final tempDir = Directory.systemTemp.createTempSync('kml_parse_test_');
      final kmlFileObj = File('${tempDir.path}/test.kml');
      
      const kmlContent = '''
        <kml xmlns="http://www.opengis.net/kml/2.2">
          <Document>
             <name>Integration Doc</name>
             <Style id="redLine">
               <LineStyle><color>ff0000ff</color></LineStyle>
             </Style>
             <Placemark>
               <name>P1</name>
               <styleUrl>#redLine</styleUrl>
               <Point><coordinates>10,10</coordinates></Point>
             </Placemark>
          </Document>
        </kml>
      ''';
      
      await kmlFileObj.writeAsString(kmlContent);

      // Act: Load and parse the file.
      final kmlFile = KMLFile(kmlXMLLocation: kmlFileObj.path);
      final root = await kmlFile.parse();
      
      // Assert: Verify the root node and its hierarchical children.
      expect(root, isA<KMLTreeRootNode>());
      expect(root.properties.getProperty('name'), 'Integration Doc');
      expect(root.children.length, 1); 
      
      // Cleanup
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
