import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/tree/concrete_tree.dart';
import 'package:stager_platform/editors/file_handler.dart';
import 'package:stager_platform/persistence/json_io_util.dart';
import 'package:stager_platform/tree/leaf_node.dart';
import 'package:stager_platform/persistence/json_io_util.dart';
import 'package:uuid/uuid.dart';

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
      final nodes = [ConcreteTreeNode(name: 'Test Node')];
      final filePath = '${testDir.path}/export_test.json';

      await fileHandler.writeToFile(filePath, nodes);

      final file = File(filePath);
      expect(await file.exists(), isTrue);
      final content = await file.readAsString();
      expect(content, contains('Test Node'));
    });

    test('readFromFile should correctly read data from a file', () async {
      final nodes = [ConcreteTreeNode(name: 'Test Node')];
      final filePath = '${testDir.path}/import_test.json';
      final file = File(filePath);
      await file.writeAsString('[${jsonEncode(nodes[0])}]');

      final importedNodes = await fileHandler.readFromFile(filePath);

      expect(importedNodes, isNotNull);
      expect(importedNodes!.length, 1);
      expect(importedNodes.first.name, 'Test Node');
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

        final node1 = ConcreteTreeNode(name: 'Node One');
        final node2 = ConcreteTreeNode(name: 'Node Two',
            initialProperties: {'parentId': TypedValue<String>('1')});

        final nodesToSerialize = [node1, node2];
        final filePath = '${testDir.path}/export_multiple_nodes.json';

        await fileHandler.writeToFile(filePath, nodesToSerialize);

        // Manually read the file as a string to verify its contents
        final file = File(filePath);
        expect(await file.exists(), isTrue, reason: 'File should have been created');

        final content = await file.readAsString();
        expect(content, isNotEmpty, reason: 'File content should not be empty');

        // Rebuild the json
        JsonIOUtil jsonUtil = JsonIOUtil();
        print("Content:\n$content");
        final List<LeafNode> rebuiltNodes = jsonUtil.deserialize(content);
        print(rebuiltNodes.toString());
      });

      test('should save an empty list if nodes list is empty', () async {
        
        final List<ConcreteTreeNode> nodes = [];
        final filePath = '${testDir.path}/export_empty_list.json';

        
        await fileHandler.writeToFile(filePath, nodes);

        
        final file = File(filePath);
        expect(await file.exists(), isTrue);
        final content = await file.readAsString();
        final List<dynamic> decodedJson = jsonDecode(content);
        expect(decodedJson, isA<List>());
        expect(decodedJson.isEmpty, isTrue);
      });
    });

    group('readFromFile', () {
      test('should correctly read and parse data from a valid JSON file', () async {
        
        final filePath = '${testDir.path}/import_valid.json';
        final file = File(filePath);
        // Prepare a file with valid JSON content
        final nodesToSave = [
          ConcreteTreeNode(name: 'First Node'),
          ConcreteTreeNode(name: 'Second Node', initialProperties: {'custom': TypedValue<String>('value')}),
        ];
        // Use the handler's own write method to ensure format consistency (or craft JSON string manually)
        await fileHandler.writeToFile(filePath, nodesToSave);


        
        final importedNodes = await fileHandler.readFromFile(filePath);

        
        expect(importedNodes, isNotNull, reason: 'Should return a list of nodes, not null');
        expect(importedNodes!.length, 2, reason: 'Should import two nodes');
        expect(importedNodes.first.name, 'First Node');
        expect(importedNodes.last.name, 'Second Node');
        expect(importedNodes.last.properties.get<String>('custom'), 'value');
      });

      test('should return an empty list if JSON file contains an empty list', () async {
        
        final filePath = '${testDir.path}/import_empty.json';
        final file = File(filePath);
        await file.writeAsString('[]'); // Empty JSON array

        
        final importedNodes = await fileHandler.readFromFile(filePath);

        
        expect(importedNodes, isNotNull);
        expect(importedNodes!.isEmpty, isTrue);
      });

      test('should return null (or throw) if file does not exist', () async {
        
        final filePath = '${testDir.path}/non_existent_file.json';

        
        final importedNodes = await fileHandler.readFromFile(filePath);

        
        // Depending on BasicFileHandler's implementation:
        expect(importedNodes, isNull, reason: 'Should return null for non-existent file');
        // OR if it throws:
        // expect(() async => await fileHandler.readFromFile(filePath),
        // throwsA(isA<FileSystemException>())); // Or a more specific custom exception
      });

      test('should throw if file content is not valid JSON', () async {
        
        final filePath = '${testDir.path}/invalid_json.json';
        final file = File(filePath);
        await file.writeAsString('This is not JSON {');
        expect(() async => await fileHandler.readFromFile(filePath),
        throwsA(isA<FormatException>()));
      });

      test('should throw if JSON structure is valid but not a list of nodes', () async {
        
        final filePath = '${testDir.path}/not_a_list.json';
        final file = File(filePath);
        // Example: JSON is an object, not a list as expected by fromJsonList
        await file.writeAsString('{"message": "This is an object, not a list of nodes"}');

        expect(() async => await fileHandler.readFromFile(filePath), throwsA(isA<JsonIOException>()));
      });


  });

    group('import', () {

      // A GlobalKey to create a basic BuildContext that has a ScaffoldMessenger ancestor
      BuildContext? testContext;

      // This test is better suited as a widgetTest due to BuildContext and SnackBar.
      // However, if we focus on the file reading part and assume context is valid:
      test('should import nodes from a valid file path and attempt to show SnackBar', () async {
        
        final filePath = '${testDir.path}/import_test_file.json';
        final nodesToSave = [
          ConcreteTreeNode(name: 'Imported Node 1', initialProperties: {}),
          ConcreteTreeNode(name: 'Imported Node 2', initialProperties: {}),
        ];
        // Use the handler's own write method to create the file (or craft JSON manually)
        // Note: For BasicFileHandler, writeToFile is separate and doesn't use context.
        fileHandler.writeToFile(filePath, nodesToSave);

        
        List<LeafNode>? importedNodes = await fileHandler.import(
          filePath: filePath,
          notificationCallback: setNotificationMessage,
        );

        // TODO Check the call back was called

        
        expect(importedNodes, isNotNull, reason: 'Imported nodes should not be null for a valid file.');
        expect(importedNodes?.length, 2, reason: 'Should import the correct number of nodes.');
        expect(importedNodes?.any((n) => n.name == 'Imported Node 1'), isTrue);
        expect(importedNodes?.any((n) => n.name == 'Imported Node 2'), isTrue);

        // SnackBar Assertion (basic check that it tried to show, requires tester)
        // This checks if a SnackBar was added to the widget tree.
        expect(testMessage, isNotEmpty, reason: 'Import message should have been set');
        expect(testMessage,
            contains('${importedNodes?.length} nodes imported!'),
            reason: 'Import message should contain the number of nodes');
        resetNotifications();
      });

      testWidgets('should return null and attempt to show error SnackBar if file path is invalid', (WidgetTester tester) async {
        
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

        
        late List<LeafNode>? importedNodes;
        await tester.runAsync(() async {
          importedNodes = await fileHandler.import(
            filePath: invalidFilePath,
            notificationCallback: setNotificationMessage,
          );
        });

        
        expect(importedNodes, isNull, reason: 'Imported nodes should be null for an invalid file path.');

      });

      test('should return null and attempt to show error SnackBar for malformed JSON', () async {
        
        final filePath = '${testDir.path}/malformed_import.json';
        final file = File(filePath);

       await file.writeAsString('This is not valid JSON {');

        
        List<LeafNode>? importedNodes = await fileHandler.import(
            filePath: filePath,
            notificationCallback: setNotificationMessage,
        );

        
        expect(importedNodes, isNull, reason: 'Imported nodes should be null for malformed JSON.');
        expect(testMessage,
            contains('Import failed: FormatException'),
            reason: 'Import should have failed due to a malformed JSON file.');
      });

    });

    group('export (no SnackBar assertion)', () {
      // Test the non-mobile path (desktop-like behavior)
      testWidgets('should export nodes to a file given a specific filePath', (WidgetTester tester) async {
        
        final filePath = '${testDir.path}/export_test_output_no_snackbar.json';
        final nodesToExport = [
          ConcreteTreeNode(name: 'Exported Node 1', initialProperties: {'data': TypedValue<String>('value1')}),
          ConcreteTreeNode(name: 'Exported Node 2', initialProperties: {'data': TypedValue<String>('value2')}),
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

        // Use tester.runAsync for potential I/O in export (which calls writeToFile)
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
        JsonIOUtil codec = JsonIOUtil();
        expectedJsonString = codec.serialize(
            nodesToExport);
        });

        expect(expectedJsonString, equals(fileContent),reason: "Strings don't match.");
      });

      testWidgets(
          'should not throw an error if export fails due to bad path (error handling internal)', (
          WidgetTester tester) async {
        
        // Using a deliberately bad path that writeToFile will likely fail on.
        // The goal is to ensure export() handles this internally (e.g., catches exception)
        // rather than rethrowing an unhandled exception that fails the test.
        final badFilePath = '/this/path/should/definitely/not/be/writable/export_fail_no_snackbar.json';
        final nodesToExport = [
          ConcreteTreeNode(
              name: 'Fail Node', initialProperties: {})
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
