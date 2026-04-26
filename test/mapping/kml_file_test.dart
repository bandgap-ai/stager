// Dart core
import 'dart:io';

// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/kml_file.dart';
import 'package:stager_platform/mapping/nodes/kml_tree_root_node.dart';
import 'kml_mock.dart';

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
    });

    // Cleanup: Ensure temporary test files are removed after the group finishes.
    tearDownAll(() async {
      if (await tmpDir.exists()) {
        await tmpDir.delete(recursive: true);
      }
    });

    /// Verifies that prepareSchemas() correctly copies XSD schema assets 
    /// from the Flutter bundle to a temporary directory.
    test('Confirm KML Schema Prepared', () async {
      final File kmlFile = File('${tmpDir.path}/$tmpKMLFile');
      
      final KMLFile kml = KMLFile(kmlXMLLocation: kmlFile.path);
      // prepareSchemas() must be awaited to ensure the copy operation completes.
      await kml.prepareSchemas();
      
      expect(kml.schemaExists, true);
    });

    /// Verifies that validate() throws a StateError if it is called before 
    /// prepareSchemas().
    test('Validate throws StateError if schemas not prepared', () async {
      final kml = KMLFile(kmlXMLLocation: 'some_path.kml');
      
      // Act & Assert
      expect(() => kml.validate(), throwsStateError);
    });

    /// Verifies that a structurally correct KML file passes validation 
    /// without throwing an exception.
    test('Validate Correct KML File', () async {
      final File kmlFile = File('${tmpDir.path}/$tmpKMLFile');
      
      final KMLFile kml = KMLFile(kmlXMLLocation: kmlFile.path);
      await kml.prepareSchemas();
      
      // Act & Assert: Completing without throwing indicates success.
      await expectLater(kml.validate(), completes);
    });

    /// Verifies that validate() throws a KMLValidationException when the 
    /// native plugin reports a failure.
    test('Validate Incorrect KML File throws KMLValidationException', () async {
      // Use an empty path to trigger a validation failure in the mock.
      final KMLFile kml = KMLFile(kmlXMLLocation: '');
      await kml.prepareSchemas();
      
      // Act & Assert: result != 0 in mock triggers the exception.
      expect(() => kml.validate(), throwsA(isA<KMLValidationException>()));
    });
  });

  group('Parsing', () {
    /// Verifies that KMLFile.parse() correctly coordinates validation and 
    /// transformation into a functional Stager node tree.
    test('Integration: KMLFile.parse() handles full KML document structure', () async {
      // Arrange: Create a temporary KML file with a shared style.
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

      // Act: Prepare, then parse (which triggers automatic validation).
      final kmlFile = KMLFile(kmlXMLLocation: kmlFileObj.path);
      await kmlFile.prepareSchemas();
      final root = await kmlFile.parse();
      
      // Assert: Verify the root node and its hierarchical children.
      expect(root, isA<KMLTreeRootNode>());
      expect(root.name, 'Integration Doc');
      expect(root.children.length, 1); 
      
      // Cleanup
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
