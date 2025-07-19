import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager/tree/concrete_tree.dart';
import 'package:stager/editors/file_handler.dart';
import 'package:stager/persistence/json_codec.dart';
import 'package:stager/tree/leaf_node.dart';

void main() {

  // Test message for notification callback
  String testMessage = '';
  // Test bool for error dialog callback
  bool errorDialogWasCalled = false;

  // Utility function for testing notification callback
  void setNotificationMessage(String message) {
    testMessage = message;
  }

  // Utility function for testing error callback. Note that this needs to be
  // manually reset after each expected call!
  void setErrorDialogWasCalled() {
    errorDialogWasCalled = true;
  }

  // Utility function that resets the values of the notification watchers.
  void resetNotifications() {
    testMessage = '';
    errorDialogWasCalled = false;
  }

  group('BasicFileHandler', () {
    late BasicFileHandler fileHandler;
    final testDir = Directory('test/temp');

    setUp(() {
      fileHandler = BasicFileHandler();
      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
      testDir.createSync(recursive: true);
    });

    tearDown(() {
      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
    });

    test('writeToFile should save a file with the correct content', () async {
      // Arrange
      final nodes = [ConcreteTreeNode(id: '1', name: 'Test Node')];
      final filePath = '${testDir.path}/export_test.json';

      // Act
      await fileHandler.writeToFile(filePath, nodes);

      // Assert
      final file = File(filePath);
      expect(await file.exists(), isTrue);
      final content = await file.readAsString();
      expect(content, contains('Test Node'));
    });

    test('readFromFile should correctly read data from a file', () async {
      // Arrange
      final filePath = '${testDir.path}/import_test.json';
      final file = File(filePath);
      await file.writeAsString('[{"type":"tree","properties":{"id":"1","name":"Test Node"},"children":[]}]');

      // Act
      final importedNodes = await fileHandler.readFromFile(filePath);

      // Assert
      expect(importedNodes, isNotNull);
      expect(importedNodes!.length, 1);
      expect(importedNodes.first.properties.getProperty('name'), 'Test Node');
    });
  });

  group('BasicFileHandler with actual File I/O', () {
    late BasicFileHandler fileHandler;
    late Directory testDir; // Make it non-final if you recreate it per test
    const String tempDirName = 'test/temp_file_handler_tests';

    setUpAll(() {
      // Create the temp directory once for all tests in this group
      testDir = Directory(tempDirName);
      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
      testDir.createSync(recursive: true);
    });

    setUp(() {
      fileHandler = BasicFileHandler();
      // Clean up specific files before each test if needed,
      // or ensure unique filenames per test.
      // For simplicity, we'll use unique filenames for now.
    });

    tearDownAll(() {
      // Delete the temp directory once after all tests in this group
      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
    });

    group('writeToFile', () {
      test('should save a file with the correct JSON content for multiple nodes', () async {
        // Arrange
        // Correct way to think about nodes for serialization:
        // We create them individually. If they were part of a tree,
        // their 'parentId' property would be set internally when added.
        // For testing writeToFile, we are testing the serialization of
        // a list of nodes as they might be provided, potentially already
        // having parentId set if extracted from a tree.

        // Scenario 1: Nodes are already structured (e.g., extracted from a tree)
        // In this case, 'parentId' would be part of their 'properties' or a dedicated field
        // that your toJson/fromJson logic handles.
        // For ConcreteTreeNode, if parentId is managed via properties:
        final node1 = ConcreteTreeNode(id: '1', name: 'Node One', initialProperties: {'type': 'root'});
        final node2 = ConcreteTreeNode(id: '2', name: 'Node Two', initialProperties: {'type': 'child', 'parentId': '1'});

        // For this test, let's assume 'parentId' is a property that gets serialized if present.
        // The toJson() method of ConcreteTreeNode is responsible for what gets written.
        final nodesToSerialize = [node1, node2];
        final filePath = '${testDir.path}/export_multiple_nodes.json';

        // Act
        await fileHandler.writeToFile(filePath, nodesToSerialize);

        // Assert
        final file = File(filePath);
        expect(await file.exists(), isTrue, reason: 'File should have been created');

        final content = await file.readAsString();
        expect(content, isNotEmpty, reason: 'File content should not be empty');

        final List<dynamic> decodedJson = jsonDecode(content);
        expect(decodedJson, isA<List>());
        expect(decodedJson.length, 2, reason: 'Should contain two nodes');

        // ---- DEBUGGING ----
        print('Decoded JSON for inspection:');
        for (var item in decodedJson) {
          print(item);
          if (item is Map) { // Check if it's a map before trying to access keys
            print('  Keys in this map item: ${item.keys}');
            if (item.containsKey('id')) {
              print('  Value of "id": ${item['id']} (Type: ${item['id'].runtimeType})');
            } else {
              print('  This map item does NOT contain an "id" key.');
            }
          } else {
            print('  This item is not a Map. It is: ${item.runtimeType}');
          }
        }
        // ---- END DEBUGGING ----


        // Find node1 data by looking into its 'properties' map
        final Map<String, dynamic> node1Json = decodedJson.firstWhere(
              (n) => n is Map &&
              n.containsKey('properties') &&
              n['properties'] is Map &&
              n['properties']['id'] == '1', // ID is a string '1' in your node setup
          orElse: () => throw StateError('Node with properties.id "1" not found or structure incorrect'),
        );

        // All relevant data for node1 is within its 'properties' map in the JSON
        final Map<String, dynamic> node1Properties = node1Json['properties'];
        expect(node1Json['type'], 'tree'); // Top-level type
        expect(node1Properties['name'], 'Node One');
        expect(node1Properties['type'], 'root');
        expect(node1Json['children'], isEmpty); // Assuming it has no children in this basic setup

        // Find node2 data
        final Map<String, dynamic> node2Json = decodedJson.firstWhere(
              (n) => n is Map &&
              n.containsKey('properties') &&
              n['properties'] is Map &&
              n['properties']['id'] == '2', // ID is a string '2'
          orElse: () => throw StateError('Node with properties.id "2" not found or structure incorrect'),
        );

        final Map<String, dynamic> node2Properties = node2Json['properties'];
        expect(node2Json['type'], 'tree'); // Top-level type
        expect(node2Properties['name'], 'Node Two');
        expect(node2Properties['type'], 'child');
        expect(node2Properties['parentId'], '1'); // parentId is also in properties
        expect(node2Json['children'], isEmpty);
      });

      test('should save an empty list if nodes list is empty', () async {
        // Arrange
        final List<ConcreteTreeNode> nodes = [];
        final filePath = '${testDir.path}/export_empty_list.json';

        // Act
        await fileHandler.writeToFile(filePath, nodes);

        // Assert
        final file = File(filePath);
        expect(await file.exists(), isTrue);
        final content = await file.readAsString();
        final List<dynamic> decodedJson = jsonDecode(content);
        expect(decodedJson, isA<List>());
        expect(decodedJson.isEmpty, isTrue);
      });

      // It's harder to test "invalid path" or "permission denied"
      // with real file I/O in a reliable, cross-platform way in unit tests.
      // This is where mocking shines.
    });

    group('readFromFile', () {
      test('should correctly read and parse data from a valid JSON file', () async {
        // Arrange
        final filePath = '${testDir.path}/import_valid.json';
        final file = File(filePath);
        // Prepare a file with valid JSON content
        final nodesToSave = [
          ConcreteTreeNode(id: 'node1', name: 'First Node'),
          ConcreteTreeNode(id: 'node2', name: 'Second Node', initialProperties: {'custom': 'value'}),
        ];
        // Use the handler's own write method to ensure format consistency (or craft JSON string manually)
        await fileHandler.writeToFile(filePath, nodesToSave);


        // Act
        final importedNodes = await fileHandler.readFromFile(filePath);

        // Assert
        expect(importedNodes, isNotNull, reason: 'Should return a list of nodes, not null');
        expect(importedNodes!.length, 2, reason: 'Should import two nodes');
        expect(importedNodes.first.properties.getProperty('name'), 'First Node');
        expect(importedNodes.first.properties.getProperty('id'), 'node1');
        expect(importedNodes.last.properties.getProperty('name'), 'Second Node');
        expect(importedNodes.last.properties.getProperty('custom'), 'value');
      });

      test('should return an empty list if JSON file contains an empty list', () async {
        // Arrange
        final filePath = '${testDir.path}/import_empty.json';
        final file = File(filePath);
        await file.writeAsString('[]'); // Empty JSON array

        // Act
        final importedNodes = await fileHandler.readFromFile(filePath);

        // Assert
        expect(importedNodes, isNotNull);
        expect(importedNodes!.isEmpty, isTrue);
      });

      test('should return null (or throw) if file does not exist', () async {
        // Arrange
        final filePath = '${testDir.path}/non_existent_file.json';

        // Act
        final importedNodes = await fileHandler.readFromFile(filePath);

        // Assert
        // Depending on BasicFileHandler's implementation:
        expect(importedNodes, isNull, reason: 'Should return null for non-existent file');
        // OR if it throws:
        // expect(() async => await fileHandler.readFromFile(filePath),
        // throwsA(isA<FileSystemException>())); // Or a more specific custom exception
      });

      test('should throw if file content is not valid JSON', () async {
        // Arrange
        final filePath = '${testDir.path}/invalid_json.json';
        final file = File(filePath);
        await file.writeAsString('This is not JSON {');
        expect(() async => await fileHandler.readFromFile(filePath),
        throwsA(isA<FormatException>()));
      });

      test('should throw if JSON structure is valid but not a list of nodes', () async {
        // Arrange
        final filePath = '${testDir.path}/not_a_list.json';
        final file = File(filePath);
        // Example: JSON is an object, not a list as expected by fromJsonList
        await file.writeAsString('{"message": "This is an object, not a list of nodes"}');

        expect(() async => await fileHandler.readFromFile(filePath), throwsA(isA<FormatException>()));
      });


  });

    group('import', () {

      // A GlobalKey to create a basic BuildContext that has a ScaffoldMessenger ancestor
      BuildContext? testContext;

      // This test is better suited as a widgetTest due to BuildContext and SnackBar.
      // However, if we focus on the file reading part and assume context is valid:
      test('should import nodes from a valid file path and attempt to show SnackBar', () async {
        // Arrange
        final filePath = '${testDir.path}/import_test_file.json';
        final nodesToSave = [
          ConcreteTreeNode(id: 'nodeImport1', name: 'Imported Node 1', initialProperties: {}),
          ConcreteTreeNode(id: 'nodeImport2', name: 'Imported Node 2', initialProperties: {}),
        ];
        // Use the handler's own write method to create the file (or craft JSON manually)
        // Note: For BasicFileHandler, writeToFile is separate and doesn't use context.
        fileHandler.writeToFile(filePath, nodesToSave);

        // Act
        List<LeafNode>? importedNodes = await fileHandler.import(
          filePath: filePath,
          notificationCallback: setNotificationMessage,
        );

        // TODO Check the call back was called

        // Assert
        expect(importedNodes, isNotNull, reason: 'Imported nodes should not be null for a valid file.');
        expect(importedNodes?.length, 2, reason: 'Should import the correct number of nodes.');
        expect(importedNodes?.any((n) => n.properties.getProperty('id') == 'nodeImport1' && n.properties.getProperty('name') == 'Imported Node 1'), isTrue);
        expect(importedNodes?.any((n) => n.properties.getProperty('id') == 'nodeImport2' && n.properties.getProperty('name') == 'Imported Node 2'), isTrue);

        // SnackBar Assertion (basic check that it tried to show, requires tester)
        // This checks if a SnackBar was added to the widget tree.
        expect(testMessage, isNotEmpty, reason: 'Import message should have been set');
        expect(testMessage,
            contains('${importedNodes?.length} nodes imported!'),
            reason: 'Import message should contain the number of nodes');
        resetNotifications();
      });

      testWidgets('should return null and attempt to show error SnackBar if file path is invalid', (WidgetTester tester) async {
        // Arrange
        final invalidFilePath = '${testDir.path}/non_existent_import_file.json';

        await tester.pumpWidget(MaterialApp(
          home: ScaffoldMessenger(
            child: Scaffold(
              body: Builder(
                builder: (BuildContext context) {
                  testContext = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ));
        expect(testContext, isNotNull);

        // Act
        late List<LeafNode>? importedNodes;
        await tester.runAsync(() async {
          importedNodes = await fileHandler.import(
            filePath: invalidFilePath,
            notificationCallback: setNotificationMessage,
          );
        });

        // Assert
        expect(importedNodes, isNull, reason: 'Imported nodes should be null for an invalid file path.');

      });

      test('should return null and attempt to show error SnackBar for malformed JSON', () async {
        // Arrange
        final filePath = '${testDir.path}/malformed_import.json';
        final file = File(filePath);

       await file.writeAsString('This is not valid JSON {');

        // Act
        List<LeafNode>? importedNodes = await fileHandler.import(
            filePath: filePath,
            notificationCallback: setNotificationMessage,
        );

        // Assert
        expect(importedNodes, isNull, reason: 'Imported nodes should be null for malformed JSON.');
        expect(testMessage,
            contains('Import failed: FormatException'),
            reason: 'Import should have failed due to a malformed JSON file.');
      });

    });

    group('export (no SnackBar assertion)', () {
      // Test the non-mobile path (desktop-like behavior)
      testWidgets('should export nodes to a file given a specific filePath', (WidgetTester tester) async {
        // Arrange
        final filePath = '${testDir.path}/export_test_output_no_snackbar.json';
        final nodesToExport = [
          ConcreteTreeNode(id: 'nodeExport1', name: 'Exported Node 1', initialProperties: {'data': 'value1'}),
          ConcreteTreeNode(id: 'nodeExport2', name: 'Exported Node 2', initialProperties: {'data': 'value2'}),
        ];

        // Create a BuildContext (needed for the method signature, but UI interaction ignored)
        late BuildContext capturedContext;
        await tester.pumpWidget(MaterialApp(
          home: ScaffoldMessenger(
            child: Scaffold(
              body: Builder(
                builder: (BuildContext context) {
                  capturedContext = context;
                  return const SizedBox.shrink(); // Minimal widget to build the context
                },
              ),
            ),
          ),
        ));

        expect(capturedContext, isNotNull);

        // Act: Use tester.runAsync for potential I/O in export (which calls writeToFile)
        // We are assuming this test runs on a non-mobile platform environment
        // so it takes the path that calls writeToFile.
        await tester.runAsync(() async => fileHandler.export(
          nodes: nodesToExport,
          filePath: filePath, // Providing filePath bypasses file picker
          errorDialogCallback: setErrorDialogWasCalled,
          notificationCallback: setNotificationMessage,
          suggestedFileName: 'irrelevant_for_this_test_path.json',
        ));

        // TODO Check callbacks

        // Assert
        // 1. Check if the file was created
        late File exportedFile;
        await tester.runAsync( () async {
          exportedFile = File(filePath);
          expect(await exportedFile.exists(), isTrue,
              reason: 'Exported file should exist at the specified path.');
        });

        // 2. Check if the content is correct
        late List<dynamic> decodedJsonFromFile;
        late String fileContent;
        await tester.runAsync(() async {
          fileContent = await exportedFile.readAsString();
        });

        // For comparison, serialize the input nodes using the same codec if possible,
        // or manually construct the expected JSON structure.
        // This makes the test less brittle to internal _codec.serialize changes.
        late List<dynamic> expectedDecodedJson;
        late String expectedJsonString;
        await tester.runAsync( () async {
        JsonCodec codec = JsonCodec();
        expectedJsonString = codec.serialize(
            nodesToExport);
        });

        expect(expectedJsonString, equals(fileContent),reason: "Strings don't match.");
      });

      testWidgets(
          'should not throw an error if export fails due to bad path (error handling internal)', (
          WidgetTester tester) async {
        // Arrange
        // Using a deliberately bad path that writeToFile will likely fail on.
        // The goal is to ensure export() handles this internally (e.g., catches exception)
        // rather than rethrowing an unhandled exception that fails the test.
        final badFilePath = '/this/path/should/definitely/not/be/writable/export_fail_no_snackbar.json';
        final nodesToExport = [
          ConcreteTreeNode(
              id: 'nodeFail', name: 'Fail Node', initialProperties: {})
        ];

        late BuildContext capturedContext;
        await tester.pumpWidget(MaterialApp(
          home: ScaffoldMessenger(
            child: Scaffold(
              body: Builder(
                builder: (BuildContext context) {
                  capturedContext = context;
                  return const SizedBox.shrink(); // Minimal widget to build the context
                },
              ),
            ),
          ),
        ));

        // Act & Assert
        // We expect the export method to handle the error gracefully (e.g., log it, try to show SnackBar - which we ignore)
        // but NOT to throw an unhandled exception that would fail the test here.
        // The `export` method has a try-catch, so it should not rethrow.
        await expectLater(
          tester.runAsync(() async =>
              fileHandler.export(
                nodes: nodesToExport,
                filePath: badFilePath,
                errorDialogCallback: setErrorDialogWasCalled,
                notificationCallback: setNotificationMessage,
              )),
          completes,
          // Asserts that the Future completes without throwing an error.
          reason: 'Export method should handle internal errors gracefully and not throw unhandled exceptions.',
        );

        // Optionally, verify that the bad file was NOT created (if that's the expected side-effect of failure)
        await tester.runAsync(() async {
          final nonExistentFile = File(badFilePath);
          expect(await nonExistentFile.exists(), isFalse,
              reason: 'File should not be created at an unwritable path.');
        });
      });
    });
  });
}
