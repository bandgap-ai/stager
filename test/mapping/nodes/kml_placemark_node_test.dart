import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/nodes/kml_placemark_node.dart';
import 'package:stager_platform/mapping/style/kml_style.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

void main() {
  group('KMLPlacemarkNode', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('Constructor correctly initializes with default styleUrl', () {
      final placemark = KMLPlacemarkNode(
        id: 'pm1',
        name: 'Default Placemark',
        styleManager: manager,
      );

      expect(placemark.styleUrl, 'default');
      expect(placemark.kmlStyle.id, 'default');
    });

    test('Resolves registered style from manager', () {
      const style = KMLStyle(id: 'pmStyle');
      manager.registerStyle(style);

      final placemark = KMLPlacemarkNode(
        id: 'pm2',
        name: 'Styled Placemark',
        styleManager: manager,
        styleUrl: '#pmStyle',
      );

      expect(placemark.kmlStyle, equals(style));
    });

    test('Throws ArgumentError for missing non-default style', () {
      final placemark = KMLPlacemarkNode(
        id: 'pm3',
        name: 'Missing Style Placemark',
        styleManager: manager,
        styleUrl: 'invalid-id',
      );

      expect(() => placemark.kmlStyle, throwsArgumentError);
    });

    test('Can store and retrieve geographic properties', () {
      final placemark = KMLPlacemarkNode(
        id: 'pm4',
        name: 'Geo Placemark',
        styleManager: manager,
      );

      placemark.properties.setProperty('latitude', 45.0);
      placemark.properties.setProperty('longitude', -90.0);

      expect(placemark.properties.getProperty('latitude'), 45.0);
      expect(placemark.properties.getProperty('longitude'), -90.0);
    });
  });
}
