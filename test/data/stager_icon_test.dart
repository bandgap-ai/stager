import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/data/stager_icon.dart';

/// A simple concrete implementation of [StagerIcon] for testing purposes.
class TestIcon extends StagerIcon {
  const TestIcon({required super.href});
}

void main() {
  group('StagerIcon', () {
    test('should store and retrieve href', () {
      // Arrange
      const href = 'https://example.com/icon.png';
      
      // Act
      const icon = TestIcon(href: href);
      
      // Assert
      expect(icon.href, href);
    });

    test('toString should contain href', () {
      // Arrange
      const href = 'assets/icon.png';
      const icon = TestIcon(href: href);
      
      // Act & Assert
      expect(icon.toString(), contains(href));
    });
  });
}
