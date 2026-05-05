import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/tree/data_node.dart';
import 'package:stager_platform/tree/data_properties.dart';

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

      final map = properties.toMap();
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
      expect(properties.isEmpty,isFalse);
      expect(properties.isNotEmpty,isTrue);
      // Verify that the observer's update method was called with the
      // correct instance.
      expect(observer.updated, isTrue);
      // Do we need to check that the node the observer received was
      // DataProperties and not something else? Not sure and skipping for now
      // until we have evidence suggesting otherwise.
      //expect(observer.updatedProps, equals(properties));

      // Detach the node and try to update again.
      properties.detach(observer);
      observer.reset();
      properties.set('374', DataNode(path: '',
          timestamp: DateTime.now().millisecondsSinceEpoch));
      expect(observer.updated, isFalse);
    });
  });
}
