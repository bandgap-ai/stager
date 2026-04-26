import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:stager_platform/mapping/nodes/map_selection_visitor_handler.dart';
import 'package:stager_platform/system/selection.dart';
import 'package:stager_platform/system/point.dart';
import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/tree/concrete_composite_node.dart';
import 'package:stager_platform/tree/concrete_leaf_node.dart';
import 'package:stager_platform/tree/concrete_tree_node.dart';

void main() {
  group('MapSelectionVisitorHandler Tests', () {
    late MapSelectionVisitorHandler handler;

    setUp(() {
      handler = MapSelectionVisitorHandler();
    });

    test('should initialize with default location (0.0, 0.0)', () {
      expect(handler.location, const LatLng(0.0, 0.0));
    });

    test('should update location when visiting a ConcreteLeafNode with coordinates', () {
      // Arrange
      final node = ConcreteLeafNode(
        name: 'Test Leaf',
        initialProperties: {
          'latitude': TypedValue<double>(38.0),
          'longitude': TypedValue<double>(-77.0),
        },
      );
      final selection = Selection<ConcreteLeafNode>(node);

      // Act
      handler.visit(selection);

      // Assert
      expect(handler.location, const LatLng(38.0, -77.0));
    });

    test('should update location when visiting a ConcreteCompositeNode with coordinates', () {
      // Arrange
      final node = ConcreteCompositeNode(
        name: 'Test Composite',
        initialProperties: {
          'latitude': TypedValue<double>(40.0),
          'longitude': TypedValue<double>(-74.0),
        },
      );
      final selection = Selection<ConcreteCompositeNode>(node);

      // Act
      handler.visit(selection);

      // Assert
      expect(handler.location, const LatLng(40.0, -74.0));
    });

    test('should update location when visiting a ConcreteTreeNode with coordinates', () {
      // Arrange
      final node = ConcreteTreeNode(
        name: 'Test Tree',
        initialProperties: {
          'latitude': TypedValue<double>(39.0),
          'longitude': TypedValue<double>(-76.0),
        },
      );
      final selection = Selection<ConcreteTreeNode>(node);

      // Act
      handler.visit(selection);

      // Assert
      expect(handler.location, const LatLng(39.0, -76.0));
    });

    test('should reset location to (0.0, 0.0) when coordinates are missing in properties', () {
      // Arrange
      // First set it to something else to verify it actually changes back to 0,0
      handler.location = Point(coords: [10.0, 10.0]);
      
      final node = ConcreteLeafNode(
        name: 'No Location Leaf',
        initialProperties: {
          'name': TypedValue<String>('Just a name'),
        },
      );
      final selection = Selection<ConcreteLeafNode>(node);

      // Act
      handler.visit(selection);

      // Assert
      expect(handler.location, const LatLng(0.0, 0.0));
    });

    test('should throw exception when visiting an unregistered type', () {
      // Arrange
      final selection = Selection<String>('I am not a node');

      // Act & Assert
      expect(() => handler.visit(selection), throwsException);
    });

    test('should handle partially missing coordinates (only latitude)', () {
       // Arrange
      final node = ConcreteLeafNode(
        name: 'Partial Location',
        initialProperties: {
          'latitude': TypedValue<double>(38.0),
          // longitude missing
        },
      );
      final selection = Selection<ConcreteLeafNode>(node);

      // Act
      handler.visit(selection);

      // Assert
      expect(handler.location, const LatLng(0.0, 0.0));
    });
  });
}
