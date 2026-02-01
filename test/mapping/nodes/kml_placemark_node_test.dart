// Flutter packages
import 'package:flutter_test/flutter_test.dart';

// Project files
import 'package:stager_platform/mapping/nodes/kml_placemark_node.dart';
import 'package:stager_platform/mapping/style/kml_style.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

/// Unit tests for the [KMLPlacemarkNode] class.
///
/// These tests verify that placemark nodes correctly initialize their 
/// geographic data and leverage the [KMLStylable] mixin for style resolution.
void main() {
  group('KMLPlacemarkNode', () {
    late KMLStyleManager manager;

    setUp(() {
      // Initialize a fresh style manager for each test to ensure isolation.
      manager = KMLStyleManager();
    });

    /// Verifies that the constructor correctly applies the 'default' styleUrl 
    /// when none is provided, and that the mixin resolves it correctly.
    test('Constructor correctly initializes with default styleUrl', () {
      // Arrange & Act
      final placemark = KMLPlacemarkNode(
        id: 'pm1',
        name: 'Default Placemark',
        styleManager: manager,
      );

      // Assert
      expect(placemark.styleUrl, 'default');
      expect(placemark.kmlStyle.id, 'default');
    });

    /// Verifies that a placemark node correctly resolves a style that has 
    /// been explicitly registered in the manager.
    test('Resolves registered style from manager', () {
      // Arrange
      const style = KMLStyle(id: 'pmStyle');
      manager.registerStyle(style);

      // Act
      final placemark = KMLPlacemarkNode(
        id: 'pm2',
        name: 'Styled Placemark',
        styleManager: manager,
        styleUrl: '#pmStyle',
      );

      // Assert
      expect(placemark.kmlStyle, equals(style));
    });

    /// Verifies that accessing the style throws an ArgumentError if the 
    /// styleUrl references a non-existent style ID.
    test('Throws ArgumentError for missing non-default style', () {
      // Arrange
      final placemark = KMLPlacemarkNode(
        id: 'pm3',
        name: 'Missing Style Placemark',
        styleManager: manager,
        styleUrl: 'invalid-id',
      );

      // Assert: The mixin delegates to the manager, which enforces valid lookups.
      expect(() => placemark.kmlStyle, throwsArgumentError);
    });

    /// Verifies that the node correctly stores and retrieves geographic 
    /// properties within its underlying properties object.
    test('Can store and retrieve geographic properties', () {
      // Arrange
      final placemark = KMLPlacemarkNode(
        id: 'pm4',
        name: 'Geo Placemark',
        styleManager: manager,
      );

      // Act
      placemark.properties.setProperty('latitude', 45.0);
      placemark.properties.setProperty('longitude', -90.0);

      // Assert: Verify retrieval from the source of truth.
      expect(placemark.properties.getProperty('latitude'), 45.0);
      expect(placemark.properties.getProperty('longitude'), -90.0);
    });
  });
}
