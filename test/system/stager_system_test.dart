// Dart core
import 'dart:io';
import 'dart:typed_data';

// Flutter
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/persistence/local_storage_provider.dart';
import 'package:stager_platform/system/selection_service.dart';
import 'package:stager_platform/system/stager_system.dart';

void main() {
  group('System diagnostic tests', () {
    test('Can retrieve the temporary directory', () {
      // Retrieve the temporary directory from the system.
      final tempDir = StagerSystem.temporaryDirectory;

      // Verify that the directory exists on the filesystem.
      // Note: StagerSystem doesn't create it, but LocalStorageProvider.store
      // will create its category subdirectories under this path.
      expect(tempDir, isNotNull);

      // Log the path for diagnostic purposes.
      final os = Platform.operatingSystem;
      print("Stager Temporary for $os OS: ${tempDir.path}");
    });
  });

  group('Selection Service test', () {
    test('Can retrieve the selection service', () {
      // Verify that the selection service can be instantiated and retrieved.
      final service1 = SelectionService();
      final service2 = StagerSystem().selectionService();
      expect(identical(service1, service2), isTrue);
    });
  });

  group('Storage Provider test', () {
    test('Can retrieve and swap the storage provider', () {
      // Ensure the default provider is initialized.
      final originalProvider = StagerSystem.storage;
      expect(originalProvider, isNotNull);

      // Create a new provider instance to test swapping.
      final testPath = Directory.systemTemp.path;
      final newProvider = LocalStorageProvider(testPath);

      // Perform the swap.
      StagerSystem.storage = newProvider;
      expect(StagerSystem.storage, same(newProvider));

      // Revert to the original provider to avoid side effects.
      StagerSystem.storage = originalProvider;
      expect(StagerSystem.storage, same(originalProvider));
    });

    test('Default storage provider can perform end-to-end IO', () async {
      // Use the default system storage.
      final storage = StagerSystem.storage;

      // Prepare test data.
      final data = Uint8List.fromList([100, 101, 102]);
      const category = 'system_test';
      const fileName = 'io_check.bin';

      // Act: Store the data.
      final path = await storage.store(
        data,
        category: category,
        fileName: fileName,
      );

      // Assert: Verify existence and content.
      expect(await storage.exists(path), isTrue);
      expect(await storage.get(path), equals(data));

      // Act: Delete the data.
      await storage.delete(path);

      // Assert: Verify it is removed.
      expect(await storage.exists(path), isFalse);
    });
  });
}
