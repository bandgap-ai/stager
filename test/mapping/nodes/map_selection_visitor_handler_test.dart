import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:stager_platform/mapping/nodes/map_selection_visitor_handler.dart';
import 'package:stager_platform/system/selection.dart';
import 'package:stager_platform/system/point.dart';
import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/tree/concrete_composite_node.dart';
import 'package:stager_platform/tree/concrete_leaf_node.dart';
import 'package:stager_platform/tree/concrete_tree_node.dart';
import 'package:stager_platform/tree/leaf_node.dart';

void main() {
  group('MapSelectionVisitorHandler Tests', () {
    late MapSelectionVisitorHandler handler;

    setUp(() {
      handler = MapSelectionVisitorHandler();
    });

    test('should initialize with default location (0.0, 0.0)', () {
      expect(handler.location, const Point());
    });

    test('should update location when visiting a ConcreteLeafNode with coordinates', () {
      
      final node = ConcreteLeafNode(name: 'Test Leaf');
      node.position = Point(coords: [-77.0, 38.0]);
      final selection = Selection<ConcreteLeafNode>(node);

      
      handler.visit(selection);

      
      expect(handler.location, Point(coords: [-77.0, 38.0]));
    });

    test('should update location when visiting a ConcreteCompositeNode with coordinates', () {
      
      final node = ConcreteCompositeNode(name: 'Test Composite');
      node.position = Point(coords: [-74.0, 40.0]);
      final selection = Selection<ConcreteCompositeNode>(node);

      
      handler.visit(selection);

      
      expect(handler.location, Point(coords: [-74.0, 40.0]));
    });

    test('should update location when visiting a ConcreteTreeNode with coordinates', () {
      final node = ConcreteTreeNode(name: 'Test Tree');
      node.position = Point(coords: [-76.0, 39.0]);
      final selection = Selection<ConcreteTreeNode>(node);
      
      handler.visit(selection);
      
      expect(handler.location, Point(coords: [-76.0, 39.0]));
    });

    test('should reset location to default node position when coordinates are missing in properties', () {
      // First set it to something else to verify it actually changes back to 0,0
      handler.location = Point(coords: [10.0, 10.0]);
      
      final node = ConcreteLeafNode(name: 'No Location Leaf');
      final selection = Selection<ConcreteLeafNode>(node);

      
      handler.visit(selection);

      expect(handler.location, LeafNode.defaultPosition);
    });

    test('should throw exception when visiting an unregistered type', () {
      
      final selection = Selection<String>('I am not a node');

      expect(() => handler.visit(selection), throwsException);
    });

    test('should handle partially missing coordinates (only latitude)', () {
       
      final node = ConcreteLeafNode(
        name: 'Partial Location',
        initialProperties: {
          'latitude': TypedValue<double>(38.0),
          // longitude missing
        },
      );
      final selection = Selection<ConcreteLeafNode>(node);

      
      handler.visit(selection);

      
      expect(handler.location, LeafNode.defaultPosition);
    });
  });
}
