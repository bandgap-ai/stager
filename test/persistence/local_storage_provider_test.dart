import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/persistence/local_storage_provider.dart';

void main() {
  group('LocalStorageProvider', () {
    late Directory tempDir;
    late LocalStorageProvider provider;

    setUp(() async {
      // Create a temporary directory for each test to ensure isolation.
      tempDir = await Directory.systemTemp.createTemp('stager_storage_test');
      provider = LocalStorageProvider(tempDir.path);
    });

    tearDown(() async {
      // Clean up the temporary directory after each test.
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('store and get should work correctly', () async {
      // Create some test data.
      final data = Uint8List.fromList([1, 2, 3, 4]);
      const category = 'test_category';
      const fileName = 'test_file.bin';

      // Store the data.
      final path = await provider.store(
        data,
        category: category,
        fileName: fileName,
      );

      // Verify the path is returned correctly.
      expect(path, contains(tempDir.path));
      expect(path, contains(category));
      expect(path, contains(fileName));

      // Retrieve the data.
      final retrievedData = await provider.get(path);

      // Verify the data is identical.
      expect(retrievedData, equals(data));
    });

    test('exists should return true for existing files and false otherwise', () async {
      // Create and store a file.
      final data = Uint8List.fromList([5, 6, 7, 8]);
      final path = await provider.store(
        data,
        category: 'status_check',
        fileName: 'exists_test.bin',
      );

      // Verify that exists returns true.
      final doesExist = await provider.exists(path);
      expect(doesExist, isTrue);

      // Verify that exists returns false for a non-existent file.
      final doesNotExist = await provider.exists('${path}_fake');
      expect(doesNotExist, isFalse);
    });

    test('delete should remove the file from the filesystem', () async {
      // Create and store a file.
      final data = Uint8List.fromList([9, 10]);
      final path = await provider.store(
        data,
        category: 'cleanup',
        fileName: 'delete_test.bin',
      );

      // Ensure it exists first.
      expect(await provider.exists(path), isTrue);

      // Delete the file.
      await provider.delete(path);

      // Verify it no longer exists.
      expect(await provider.exists(path), isFalse);
    });

    test('get should return empty Uint8List for non-existent files', () async {
      // Attempt to get a non-existent file.
      final data = await provider.get('non_existent_path');

      // Verify it returns an empty list instead of throwing or returning null.
      expect(data, isEmpty);
      expect(data, isA<Uint8List>());
    });

    test('getUri should return a valid file URI', () {
      const path = '/some/path/file.txt';
      final uri = provider.getUri(path);

      expect(uri, startsWith('file://'));
      expect(uri, contains('file.txt'));
    });
  });
}
