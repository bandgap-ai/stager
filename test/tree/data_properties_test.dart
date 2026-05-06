// Dart core
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// Flutter
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/persistence/local_storage_provider.dart';
import 'package:stager_platform/system/stager_system.dart';
import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/tree/data_node.dart';
import 'package:stager_platform/tree/data_properties.dart';

import 'json_reviver.dart';
import 'mock_node_observer.dart';

void main() {
  group("DataProperties Configuration Group", () {
    test("DataProperties Management and Serialization Test", () {
      final properties = DataProperties();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final node1 = DataNode(path: 'p1', timestamp: timestamp);
      final node2 = DataNode(path: 'p2', timestamp: timestamp);

      properties.set('attachment_1', node1);
      properties.set('attachment_2', node2);

      expect(properties.size, 2);

      final map = properties.map;
      print(map);
      final newProperties = DataProperties(
        map as Map<String, TypedValue<Object>>,
      );

      expect(newProperties.size, 2);
      expect(newProperties.get('attachment_1'), node1);

      // Get all of the properties as a list.
      final all = newProperties.all;
      expect(all.length, 2);
      expect(all[0].path, 'p1');
      expect(all[1].path, 'p2');
      // Get all the paths and check them directly
      final allPaths = newProperties.allPaths;
      expect(allPaths.length, 2);
      expect(allPaths[0], 'p1');
      expect(allPaths[1], 'p2');
    });

    test('notifications should trigger on property modifications', () {
      // Setup the container and attach a mock observer for reactivity testing.
      final properties = DataProperties();
      final observer = MockNodeObserver();
      properties.attach(observer);

      // Trigger a state change by setting a property.
      properties.set(
        '8675309',
        DataNode(path: '', timestamp: DateTime.now().millisecondsSinceEpoch),
      );

      expect(properties.hasNode('8675309'), isTrue);
      expect(properties.isEmpty, isFalse);
      expect(properties.isNotEmpty, isTrue);
      // Verify that the observer's update method was called with the
      // correct instance.
      expect(observer.updated, isTrue);

      // Detach the node and try to update again.
      properties.detach(observer);
      observer.reset();
      properties.set('374',
          DataNode(path: '', timestamp: DateTime.now().millisecondsSinceEpoch));
      expect(observer.updated, isFalse);
    });
  });

  group("DataProperties Active IO Group", () {
    late Directory tempDir;
    late LocalStorageProvider testProvider;

    setUp(() async {
      // Create a temporary directory for the active IO tests.
      tempDir = await Directory.systemTemp.createTemp('data_props_active_test');
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

    test("Restoration from map should restore data nodes correctly", () {
      // Create two DataNodes and add them to the properties.
      final node1 = DataNode(path: 'p1', timestamp: DateTime.now().millisecondsSinceEpoch);
      final node2 = DataNode(path: 'p2', timestamp: DateTime.now().millisecondsSinceEpoch);
      final properties = DataProperties();
      properties.set('attachment_1', node1);
      properties.set('attachment_2', node2);

      // Check the properties now that the nodes are added
      expect(properties.size, 2);
      expect(properties.get('attachment_1'), node1);
      expect(properties.get('attachment_2'), node2);

      // Write the json
      final jsonString = jsonEncode(properties);
      print(jsonString);

      // Try to convert the back to a map and back to DataNodeProperties.
      final readProperties = DataProperties();
      final Map<String, Object> map = jsonDecode(jsonString, reviver: jsonReviver);
      for (final entry in map.entries) {
        print("${entry.runtimeType} with value type ${entry.value.runtimeType}: ${entry}");
        if (entry.value is List<Object>) {
          final dataMap = (entry.value as List<Object>)[1] as Map<String,Object>;
          print("DataMap: $dataMap");
          final node = DataNode.fromMap(dataMap);
          print("Node: $node");
          readProperties.set(entry.key, node);
        }
      }
      print(map);
      print(readProperties.toMap().toString());

      // Now check the properties
      expect(readProperties.size, 2);
      expect(readProperties.get('attachment_1'), node1);
      expect(readProperties.get('attachment_2'), node2);

    });

    test("addAsset should store data and add a DataNode atomically", () async {
      // Setup the container and attach a mock observer.
      final properties = DataProperties();
      final observer = MockNodeObserver();
      properties.attach(observer);

      final data = Uint8List.fromList([1, 2, 3, 4, 5]);
      const fileName = 'test_asset.bin';
      const category = 'test_category';

      // Act: Add the asset through DataProperties.
      final node = await properties.addAsset(
        data,
        category: category,
        fileName: fileName,
        type: DataNodeType.txt,
        mimeType: 'text/plain',
      );

      // Assert: Verify the node exists in the container and the file is stored.
      expect(properties.size, 1);
      expect(properties.all.first, equals(node));
      expect(node.type, DataNodeType.txt);
      expect(node.mimeType, 'text/plain');
      expect(node.size, data.length);
      
      // Verify the storage actually contains the file.
      expect(await StagerSystem.storage.exists(node.path), isTrue);
      final storedData = await StagerSystem.storage.get(node.path);
      expect(storedData, equals(data));

      // Verify that the observer was notified.
      expect(observer.updated, isTrue);

      // Cleanup: Remove the asset.
      await node.remove(true);
      expect(await StagerSystem.storage.exists(node.path), isFalse);
    });
  });
}
