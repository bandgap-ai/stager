import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/kml_icon.dart';
import 'package:stager_platform/data/stager_icon.dart';
import 'package:stager_platform/system/typed_value.dart';

void main() {
  group('KMLIcon Tests', () {
    test('should inherit from StagerIcon', () {
      const icon = KMLIcon(href: 'icon.png');
      expect(icon, isA<StagerIcon>());
    });

    test('should correctly store href', () {
      const href = 'http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png';
      const icon = KMLIcon(href: href);
      expect(icon.href, href);
    });

    test('should support value-based equality', () {
      const icon1 = KMLIcon(href: 'a.png');
      const icon2 = KMLIcon(href: 'a.png');
      const icon3 = KMLIcon(href: 'b.png');

      expect(icon1, equals(icon2));
      expect(icon1.hashCode, equals(icon2.hashCode));
      expect(icon1, isNot(equals(icon3)));
    });

    test('should export and rehydrate correctly via toMap and fromMap', () {
      const icon = KMLIcon(href: 'path/to/icon.png');
      final map = icon.toMap();

      // Verify it is in the dumped map.
      expect(map['href'], 'path/to/icon.png');

      // Rehydrate.
      final newIcon = KMLIcon.fromMap(map);
      expect(newIcon, equals(icon));
    });
  });
}
