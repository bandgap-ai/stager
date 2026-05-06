import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';
import 'package:stager_platform/mapping/style/kml_style.dart';

void main() {
  group('KMLStyleManager', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('registerStyle should add a style to the registry', () {
      const style = KMLStyle(id: 'test-style');
      manager.registerStyle(style);
      
      expect(manager.contains('test-style'), isTrue);
      expect(manager.limit, 1);
    });

    test('contains should handle IDs with and without # prefix', () {
      const style = KMLStyle(id: 'my-style');
      manager.registerStyle(style);
      
      expect(manager.contains('my-style'), isTrue);
      expect(manager.contains('#my-style'), isTrue);
      expect(manager.contains('non-existent'), isFalse);
    });

    test('getStyle should retrieve a registered style', () {
      const style = KMLStyle(id: 'fetch-me');
      manager.registerStyle(style);
      
      final fetched = manager.getStyle('fetch-me');
      expect(fetched.id, 'fetch-me');
      
      final fetchedWithHash = manager.getStyle('#fetch-me');
      expect(fetchedWithHash.id, 'fetch-me');
    });

    test('getStyle should throw ArgumentError and log when style is missing', () {
      expect(() => manager.getStyle('missing-style'), throwsArgumentError);
    });

    test('clear should remove all styles', () {
      manager.registerStyle(const KMLStyle(id: 's1'));
      manager.registerStyle(const KMLStyle(id: 's2'));
      expect(manager.limit, 2);
      
      manager.clear();
      expect(manager.limit, 0);
      expect(manager.contains('s1'), isFalse);
    });

    test('registerStyle should overwrite existing styles with same ID', () {
      const style1 = KMLStyle(id: 'same-id');
      manager.registerStyle(style1);
      
      const style2 = KMLStyle(id: 'same-id');
      manager.registerStyle(style2);
      
      expect(manager.limit, 1);
    });
  });
}
