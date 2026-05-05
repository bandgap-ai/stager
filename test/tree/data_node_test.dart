// Dart core
import 'dart:io';
import 'dart:typed_data';

// Flutter
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/persistence/local_storage_provider.dart';
import 'package:stager_platform/system/stager_system.dart';
import 'package:stager_platform/tree/data_node.dart';

void main() {
  group("DataNode Configuration Group", () {
    test("Basic DataNode Serialization Test", () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final node = DataNode(
        path: 'nodes/1/image.jpg',
        type: DataNodeType.image,
        mimeType: 'image/jpeg',
        size: 1024,
        timestamp: now,
      );

      final map = node.toMap();
      final decoded = DataNode.fromMap(map);

      expect(decoded.path, 'nodes/1/image.jpg');
      expect(decoded.type, DataNodeType.image);
      expect(decoded.size, 1024);
      expect(decoded.timestamp, now);
      expect(decoded, node);

      // Make sure the hash code is non-zero, positive, and matches node.
      expect(decoded.hashCode, isNot(0));
      expect(decoded.hashCode, isPositive);
      expect(decoded.hashCode, equals(node.hashCode));
    });
  });

  group("DataNode Active IO Group", () {
    late Directory tempDir;
    late LocalStorageProvider testProvider;

    setUp(() async {
      // Create a temporary directory for the active IO tests.
      tempDir = await Directory.systemTemp.createTemp('data_node_active_test');
      testProvider = LocalStorageProvider(tempDir.path);
      
      // Inject the test provider into the system.
      StagerSystem.storage = testProvider;
    });

    tearDown(() async {
      // Clean up the temporary directory.
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test("readBytes should retrieve data from the storage provider", () async {
      // Create and store dummy data.
      final data = Uint8List.fromList([10, 20, 30]);
      final path = await StagerSystem.storage.store(
        data,
        category: 'io_test',
        fileName: 'bytes.bin',
      );

      final node = DataNode(
        path: path,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // Act: Read bytes directly from the node.
      final result = await node.readBytes();

      // Assert: Data should match the stored bytes.
      expect(result, equals(data));
    });

    test("openStream should provide a data stream from the storage provider", () async {
      // Create and store dummy data.
      final data = Uint8List.fromList([40, 50, 60]);
      final path = await StagerSystem.storage.store(
        data,
        category: 'io_test',
        fileName: 'stream.bin',
      );

      final node = DataNode(
        path: path,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // Act: Open a stream from the node.
      final stream = await node.openStream();
      final result = await stream.expand((chunk) => chunk).toList();

      // Assert: Streamed data should match the stored bytes.
      expect(result, equals(data));
    });

    test("remove should delete from storage only when confirmed", () async {
      // Create and store dummy data.
      final data = Uint8List.fromList([1, 1, 1]);
      final path = await StagerSystem.storage.store(
        data,
        category: 'io_test',
        fileName: 'removal.bin',
      );

      final node = DataNode(
        path: path,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // Act/Assert: Unconfirmed removal should do nothing.
      await node.remove(false);
      expect(await StagerSystem.storage.exists(path), isTrue);

      // Act/Assert: Confirmed removal should delete the file.
      await node.remove(true);
      expect(await StagerSystem.storage.exists(path), isFalse);
    });

    test("export should delegate to the storage provider", () async {
      final node = DataNode(
        path: 'dummy/path',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // Export is currently a stub in LocalStorageProvider, so we verify 
      // it doesn't throw.
      expect(node.export('file.jpg'), completes);
    });
  });
}
