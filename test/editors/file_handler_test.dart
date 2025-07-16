import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stager/tree/concrete_tree.dart';
import 'package:stager/editors/file_handler.dart';

void main() {
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

    test('export should be tested with a mock file picker in a separate test file', () {
      // This test is a placeholder to remind us to test the export UI flow.
    }, skip: true);

    test('import should be tested in a future implementation', () {
      // This test is a placeholder and will be implemented once export is confirmed.
    }, skip: true);

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
}

