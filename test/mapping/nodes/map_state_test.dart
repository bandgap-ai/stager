import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/map_state.dart';
import 'package:stager_platform/site_state.dart';

void main() {
  group('MapState Tests', () {
    test('should initialize with SiteState', () {
      // Arrange
      final siteState = SiteState();
      
      // Act
      final mapState = MapState(siteState);

      // Assert
      expect(mapState, isNotNull);
      expect(mapState.tileLayerAdapter, isNotNull);
      expect(mapState.markerLayerAdapter, isNotNull);
      expect(mapState.polygonLayerAdapter, isNotNull);
    });

    test('should load nodes from siteState during initialization', () {
      // Arrange
      final siteState = SiteState();
      // Add a site to ensure there's data to process
      siteState.addSite('Test Site');
      
      // Act
      final mapState = MapState(siteState);

      // Assert
      // Currently, MapState just prints the nodeTypeMap in the constructor.
      // This test ensures the constructor completes without errors when data is present.
      expect(mapState, isNotNull);
    });
  });
}
