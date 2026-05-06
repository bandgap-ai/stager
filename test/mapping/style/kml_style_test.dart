import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/style/kml_style.dart';
import 'package:stager_platform/mapping/style/kml_icon_style.dart';
import 'package:stager_platform/mapping/style/kml_line_style.dart';
import 'package:stager_platform/mapping/style/kml_poly_style.dart';

void main() {
  group('KMLStyle', () {
    test('Constructor uses defaults when components are omitted', () {
      // Arrange & Act
      const style = KMLStyle(id: 'default-test');

      // Assert
      expect(style.id, 'default-test');
      
      // Verify IconStyle defaults are present via the component
      expect(style.iconStyle.scale, 1.0);
      expect(style.iconStyle.href, '');

      // Verify LineStyle defaults are present via the component
      expect(style.lineStyle.color, 'ffffffff');
      expect(style.lineStyle.width, 1.0);

      // Verify PolyStyle defaults are present via the component
      expect(style.polyStyle.color, 'ffffffff');
      expect(style.polyStyle.fill, true);
      expect(style.polyStyle.outline, true);
    });

    test('Constructor correctly initializes with custom components', () {
      // Arrange
      const customIcon = KMLIconStyle(scale: 2.0, href: 'custom.png');
      const customLine = KMLLineStyle(color: 'ff0000ff', width: 5.0);
      const customPoly = KMLPolyStyle(color: '7f00ff00', fill: false, outline: false);

      // Act
      const style = KMLStyle(
        id: 'custom-test',
        iconStyle: customIcon,
        lineStyle: customLine,
        polyStyle: customPoly,
      );

      // Assert
      expect(style.id, 'custom-test');
      expect(style.iconStyle.scale, 2.0);
      expect(style.iconStyle.href, 'custom.png');
      expect(style.lineStyle.color, 'ff0000ff');
      expect(style.lineStyle.width, 5.0);
      expect(style.polyStyle.color, '7f00ff00');
      expect(style.polyStyle.fill, false);
      expect(style.polyStyle.outline, false);
    });

    test('toString() output contains nested component info', () {
      // Arrange
      const style = KMLStyle(id: 'string-test');

      // Act
      final output = style.toString();

      // Assert
      expect(output, contains('id: string-test'));
      expect(output, contains('KMLIconStyle'));
      expect(output, contains('KMLLineStyle'));
      expect(output, contains('KMLPolyStyle'));
    });
  });
}
