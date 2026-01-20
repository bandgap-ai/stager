import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/kml_file.dart';
import '../helpers/kml_mock.dart';

void main() {
  // Ensure we can get to the Flutter assets
  TestWidgetsFlutterBinding.ensureInitialized();

  // Register the mock MethodChannel before any tests run.
  setUpAll(() async {
    await registerKmlMock();
  });

  group('Validation', () {
    final String tmpDirectoryName = 'kml_file_test';
    final String tmpKMLFile = 'kml_wiki_example.xml';
    late Directory tmpDir;
    final String sep = Platform.pathSeparator;

    // Create a temporary KML file that can be used by all the tests.
    setUpAll(() async {
      // Register the mock MethodChannel (no native plugin needed).
      // The mock is already installed in the top‑level setUpAll.
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

    tearDownAll(() async {
      // If the test ran long enough to create the temp directory, delete it.
      if (await tmpDir.exists()) {
        tmpDir.delete(recursive: true);
      }
    });

    /// This test validates that the KML schema can be loaded into a temporary
    /// directory. Note that the KMLFile classes uses a separate temporary
    /// directory than the test class.
    test('Confirm KML Schema Loaded', () {
      File kmlFile = File('${tmpDir.path}/$tmpKMLFile');
      String kmlPath = kmlFile.path;
      // Probably could create a second constructor to handle this very likely
      // scenario.
      KMLFile kml = KMLFile(kmlXMLLocation: kmlPath);
      kml.load();
      expect(kml.schemaExists, true);
    });

    /// This test validates that a legitimate KML file is... legitimate? I don't
    /// know, man, I just work here...
    test('Validate Correct KML File', () async {
      File kmlFile = File('${tmpDir.path}/$tmpKMLFile');
      String kmlPath = kmlFile.path;
      KMLFile kml = KMLFile(kmlXMLLocation: kmlPath);
      kml.load();
      expect(await kml.validate(), 0);
    });

    /// Make sure that the KMLFIle class knows when a file isn't KML.
    test('Validate Incorrect KML File', () async {
      File kmlFile = File('');
      String kmlPath = kmlFile.path;
      KMLFile kml = KMLFile(kmlXMLLocation: kmlPath);
      kml.load();
      expect(await kml.validate(), 1);
    });
  });
}
