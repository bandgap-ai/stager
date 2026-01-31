import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/nodes/kml_placemark_node.dart';
import 'package:stager_platform/mapping/style/kml_style.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

void main() {
  group('KmlPlacemarkNode Tests', () {
    test('Resolves style from manager', () {
      final manager = KmlStyleManager();
      const style = KmlStyle(id: 'pmStyle', lineColor: 'ff0000ff');
      manager.registerStyle(style);

      final placemark = KmlPlacemarkNode(
        id: '1',
        name: 'Test Placemark',
        styleManager: manager,
        styleUrl: '#pmStyle',
      );

      expect(placemark.kmlStyle, equals(style));
      expect(placemark.kmlStyle?.lineColor, 'ff0000ff');
    });

    test('Properties are stored correctly', () {
      final manager = KmlStyleManager();
      final placemark = KmlPlacemarkNode(
        id: '1',
        name: 'Test',
        styleManager: manager,
        initialProperties: {'desc': 'A description'},
      );

      expect(placemark.properties.getProperty('desc'), 'A description');
    });
  });
}
