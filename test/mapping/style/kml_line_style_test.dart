import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/style/kml_line_style.dart';

void main() {
  group('KMLLineStyle', () {
    test('has correct KML spec-compliant defaults', () {
      const lineStyle = KMLLineStyle();
      expect(lineStyle.color, 'ffffffff');
      expect(lineStyle.width, 1.0);
    });

    test('correctly initializes with custom values', () {
      const lineStyle = KMLLineStyle(color: '7fff0000', width: 3.5);
      expect(lineStyle.color, '7fff0000');
      expect(lineStyle.width, 3.5);
    });

    test('toString() contains property information', () {
      const lineStyle = KMLLineStyle(width: 4.2);
      expect(lineStyle.toString(), contains('width: 4.2'));
    });
  });
}
