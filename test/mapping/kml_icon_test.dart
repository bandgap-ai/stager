import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/kml_icon.dart';
import 'package:stager_platform/data/stager_icon.dart';

void main() {
  group('KMLIcon', () {
    test('should inherit from StagerIcon', () {
      // Arrange
      const icon = KMLIcon(href: 'icon.png');
      
      // Act & Assert
      expect(icon, isA<StagerIcon>());
    });

    test('should correctly store href', () {
      // Arrange
      const href = 'http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png';
      
      // Act
      const icon = KMLIcon(href: href);
      
      // Assert
      expect(icon.href, href);
    });

    test('toString should reflect KMLIcon type and href', () {
      // Arrange
      const icon = KMLIcon(href: 'kml_icon.png');
      
      // Act & Assert
      expect(icon.toString(), contains('KMLIcon'));
      expect(icon.toString(), contains('kml_icon.png'));
    });
  });
}
