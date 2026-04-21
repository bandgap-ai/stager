// Dart core
import 'dart:io';

// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/kml_file.dart';
import 'package:stager_platform/mapping/nodes/kml_tree_root_node.dart';
import 'package:stager_platform/mapping/nodes/kml_placemark_node.dart';
import 'package:stager_platform/mapping/nodes/kml_point_node.dart';
import 'package:stager_platform/tree/node_visitor.dart';
import 'kml_mock.dart';

/// A simple visitor to verify tree traversal during integration testing.
class IntegrationTestVisitor extends NodeVisitor {
  /// The total number of nodes visited.
  int visitCount = 0;

  /// The names of the nodes encountered during traversal.
  final List<String> nodeNames = [];

  @override
  void visit(Object node) {
    visitCount++;
    // Capture names from KML-specific nodes to verify identity.
    if (node is KMLTreeRootNode) {
      nodeNames.add(node.properties.get<String>('name'));
    } else if (node is KMLPlacemarkNode) {
      nodeNames.add(node.properties.get<String>('name'));
    } else if (node is KMLPointNode) {
      nodeNames.add(node.properties.get<String>('name'));
    }
  }
}

void main() {
  // Ensure Flutter binding is initialized for rootBundle usage in KMLFile.prepareSchemas()
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KML Integration Plan Example', () {
    late Directory tempDir;
    late File kmlFileObj;

    setUpAll(() async {
      // Mock the native plugin for validation to satisfy the KMLFile dependency.
      await registerKmlMock();
      
      // Create a temporary directory and KML file containing the Wikipedia example.
      tempDir = await Directory.systemTemp.createTemp('kml_integration_example_');
      kmlFileObj = File('${tempDir.path}/wikipedia_example.kml');
      
      const wikipediaKml = '''
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
''';
      await kmlFileObj.writeAsString(wikipediaKml);
    });

    tearDownAll(() async {
      // Cleanup: Remove temporary test files.
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Executes the integration example from the design plan', () async {
      // This test follows the Short Example in kml_integration_plan.md.
      
      // Arrange
      final kmlFile = KMLFile(kmlXMLLocation: kmlFileObj.path);

      try {
        // 1. Act: Prepare schemas and await completion.
        await kmlFile.prepareSchemas();

        // 2. Act: Parse into a Stager tree root. Automatic validation occurs.
        final KMLTreeRootNode root = await kmlFile.parse();

        // 3. Assert: Basic verification of the parsed root.
        expect(root, isA<KMLTreeRootNode>());
        expect(root.properties.get<String>('name'), 'KML Document');
        
        // Refactored: Root contains 1 child (Placemark).
        expect(root.children.length, 1);

        // 4. Act: Traverse the GIS data using a visitor.
        final visitor = IntegrationTestVisitor();
        
        // Manual recursive traversal for verification since our simple visitor
        // is non-recursive.
        void traverse(dynamic node) {
          node.accept(visitor);
          if (node is KMLTreeRootNode || node is KMLPlacemarkNode) {
            for (final child in node.children) {
              traverse(child);
            }
          }
        }
        
        traverse(root);

        // Assert: Visitor should have seen 3 nodes: Root, Placemark, and Point.
        expect(visitor.visitCount, 3);
        expect(visitor.nodeNames, contains('KML Document'));
        expect(visitor.nodeNames, contains('New York City'));
        expect(visitor.nodeNames, contains('Point'));

        // 5. Act: Use ConcreteTreeNode's built-in summarization.
        final summary = root.summarize();

        // 6. Assert: Verify the summarization results.
        // Total nodes: Root (1) + Placemark (1) + Point (1) = 3.
        expect(summary.totalNodes, 3);
        expect(summary.centerPoint, isNotNull);
        
        // Verify that the coordinates (Lat, Lon) match the Wikipedia 
        // example's input (Lon, Lat), proving the swap logic.
        expect(summary.centerPoint?.latitude, closeTo(40.714172, 0.000001));
        expect(summary.centerPoint?.longitude, closeTo(-74.006393, 0.000001));
        
        // Print results to console, as indicated in the plan's example.
        print('Map center: ${summary.centerPoint}');
        print('Total nodes: ${summary.totalNodes}');

      } on KMLValidationException catch (e) {
        fail('Invalid KML: ${e.message}');
      } catch (e) {
        // If another error occurs, the test fails.
        fail('Failed to parse KML file: $e');
      }
    });
  });
}
