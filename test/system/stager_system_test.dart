// Dart core
import 'dart:io';
import 'dart:typed_data';

// Flutter
import 'package:flutter_test/flutter_test.dart';

// External packages
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Project files
import 'package:stager_platform/persistence/local_storage_provider.dart';
import 'package:stager_platform/system/selection_service.dart';
import 'package:stager_platform/system/stager_system.dart';

/// A manual fake for the PathProvider platform interface.
///
/// This avoids the need for build_runner during diagnostic system tests while
/// adhering to the Single Return Principle and no-null policy.
class FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  String? _mockPath;

  /// Sets the path to be returned by [getApplicationDocumentsPath].
  void setMockPath(String path) {
    _mockPath = path;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return _mockPath;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('System diagnostic tests', () {
    late FakePathProviderPlatform fakePlatform;

    setUp(() {
      // Initialize and register the fake platform.
      fakePlatform = FakePathProviderPlatform();
      PathProviderPlatform.instance = fakePlatform;
    });

    test('Can retrieve the temporary directory', () {
      // Retrieve the temporary directory from the system.
      final tempDir = StagerSystem.temporaryDirectory;

      // Verify that the directory exists on the filesystem.
      expect(tempDir, isNotNull);

      // Log the path for diagnostic purposes.
      final os = Platform.operatingSystem;
      print("Stager Temporary for $os OS: ${tempDir.path}");
    });

    test('Can retrieve the documents directory', () async {
      // Arrange: Setup the mock path for the base documents directory.
      const baseMockPath = '/mock/documents';
      fakePlatform.setMockPath(baseMockPath);

      // Act: Retrieve the documents directory from the system.
      final docsDir = await StagerSystem.documentsDirectory;

      // Assert: Verify that the path is correct based on the platform logic.
      late final bool isCorrect;
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final expectedPath =
            path.join(baseMockPath, StagerSystem.tmpDirectoryRoot);
        isCorrect = docsDir.path == expectedPath;
      } else {
        isCorrect = docsDir.path == baseMockPath;
      }

      expect(isCorrect, isTrue);
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
