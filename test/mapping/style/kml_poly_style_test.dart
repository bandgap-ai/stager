import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/style/kml_poly_style.dart';

void main() {
  group('KMLPolyStyle', () {
    test('has correct KML spec-compliant defaults', () {
      const polyStyle = KMLPolyStyle();
      expect(polyStyle.color, 'ffffffff');
      expect(polyStyle.fill, true);
      expect(polyStyle.outline, true);
    });

    test('correctly initializes with custom values', () {
      const polyStyle = KMLPolyStyle(color: '00ffffff', fill: false, outline: false);
      expect(polyStyle.color, '00ffffff');
      expect(polyStyle.fill, false);
      expect(polyStyle.outline, false);
    });

    test('toString() contains property information', () {
      const polyStyle = KMLPolyStyle(fill: false);
      expect(polyStyle.toString(), contains('fill: false'));
    });
  });
}
