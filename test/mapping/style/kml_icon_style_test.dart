import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/style/kml_icon_style.dart';

void main() {
  group('KMLIconStyle', () {
    test('has correct KML spec-compliant defaults', () {
      const iconStyle = KMLIconStyle();
      expect(iconStyle.scale, 1.0);
      expect(iconStyle.href, '');
    });

    test('correctly initializes with custom values', () {
      const iconStyle = KMLIconStyle(scale: 2.5, href: 'http://example.com/icon.png');
      expect(iconStyle.scale, 2.5);
      expect(iconStyle.href, 'http://example.com/icon.png');
    });

    test('toString() contains property information', () {
      const iconStyle = KMLIconStyle(scale: 1.2);
      expect(iconStyle.toString(), contains('scale: 1.2'));
    });
  });
}
