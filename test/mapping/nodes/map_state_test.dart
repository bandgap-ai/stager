import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/map_state.dart';
import 'package:stager_platform/site_state.dart';

void main() {
  group('MapState Tests', () {
    test('should initialize with SiteState', () {
      final siteState = SiteState();

      final mapState = MapState(siteState);

      expect(mapState, isNotNull);
      expect(mapState.tileLayerAdapter, isNotNull);
      expect(mapState.markerLayerAdapter, isNotNull);
      expect(mapState.polygonLayerAdapter, isNotNull);
    });

    test('should load nodes from siteState during initialization', () {
      final siteState = SiteState();
      // Add a site to ensure there's data to process
      siteState.addSite('Test Site');

      final mapState = MapState(siteState);

      // Currently, MapState just prints the nodeTypeMap in the constructor.
      // This test ensures the constructor completes without errors when data is present.
      expect(mapState, isNotNull);

      // All of the test data should be in the app
      expect(mapState.markerLayerAdapter.markers.length, 52);

      // Add an additional site and make sure that the markerLayerAdapter is
      // updated after the change.
      siteState.addSite('Test Site 2');
      expect(mapState.markerLayerAdapter.markers.length, 53);
    });


  });
}
