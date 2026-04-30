/// Tests for TreeNode.summarize() method functionality.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/system/point.dart';
import 'package:stager_platform/tree/concrete_tree.dart';
import 'package:stager_platform/tree/node_summary.dart';

void main() {
  group('NodeSummary', () {
    test('should create empty summary correctly', () {
      const summary = NodeSummary.empty();
      
      expect(summary.totalNodes, 0);
      expect(summary.nodeCountsByLevel, isEmpty);
      expect(summary.boundingPolygon, isEmpty);
      expect(summary.centerPoint, isNull);
      expect(summary.totalOutlineArea, isNull);
      expect(summary.additionalStats, isEmpty);
    });

    test('should serialize to and from JSON correctly', () {
      final summary = NodeSummary(
        totalNodes: 5,
        nodeCountsByLevel: {1: 2, 2: 3},
        boundingPolygon: [
          Point(coords: [-74.0,40.0]),
          Point(coords: [-74.0,40.1]),
          Point(coords: [-74.1,40.1]),
        ],
        centerPoint: Point(coords: [-74.05,40.05]),
        totalOutlineArea: 1500.0,
        additionalStats: {'averageSpacing': 25.5},
      );

      final json = summary.toJson();
      final reconstructed = NodeSummary.fromJson(json);

      expect(reconstructed.totalNodes, summary.totalNodes);
      expect(reconstructed.nodeCountsByLevel, summary.nodeCountsByLevel);
      expect(reconstructed.boundingPolygon.length, summary.boundingPolygon.length);
      expect(reconstructed.centerPoint, summary.centerPoint);
      expect(reconstructed.totalOutlineArea, summary.totalOutlineArea);
      expect(reconstructed.additionalStats, summary.additionalStats);
    });

    test('should compare NodeSummary instances correctly', () {
      const summary1 = NodeSummary(
        totalNodes: 3,
        nodeCountsByLevel: {1: 1, 2: 2},
        boundingPolygon: [],
      );
      
      const summary2 = NodeSummary(
        totalNodes: 3,
        nodeCountsByLevel: {1: 1, 2: 2},
        boundingPolygon: [],
      );

      const summary3 = NodeSummary(
        totalNodes: 4,
        nodeCountsByLevel: {1: 1, 2: 3},
        boundingPolygon: [],
      );

      expect(summary1, equals(summary2));
      expect(summary1, isNot(equals(summary3)));
    });
  });

  group('TreeNode.summarize()', () {
    test('should return empty summary for empty tree', () {
      final tree = ConcreteTreeNode(name: 'Empty Tree');
      
      final summary = tree.summarize();
      
      expect(summary.totalNodes, 1); // Just the root node
      expect(summary.nodeCountsByLevel, {1: 1});
      expect(summary.boundingPolygon, isEmpty);
      expect(summary.centerPoint, isNull);
      expect(summary.totalOutlineArea, isNull);
    });

    test('should count nodes correctly in simple hierarchy', () {
      final tree = ConcreteTreeNode(name: 'Root');
      final level1Node = ConcreteCompositeNode(name: 'Level 1');
      final level2Node1 = ConcreteLeafNode(name: 'Level 2 Node 1');
      final level2Node2 = ConcreteLeafNode(name: 'Level 2 Node 2');
      
      tree.addChild(level1Node);
      level1Node.addChild(level2Node1);
      level1Node.addChild(level2Node2);
      
      final summary = tree.summarize();
      
      expect(summary.totalNodes, 4);
      expect(summary.nodeCountsByLevel, {1: 1, 2: 1, 3: 2});
    });

    test('should extract coordinates and compute center point', () {
      final tree = ConcreteTreeNode(name: 'Root');
      
      // Create nodes with specific coordinates
      final node1 = ConcreteLeafNode(name: 'Node 1');
      node1.position = Point(coords: [-74.0, 40.0]);
      
      final node2 = ConcreteLeafNode(name: 'Node 2');
      node1.position = Point(coords: [-74.2, 40.2]);
      
      final node3 = ConcreteLeafNode(name: 'Node 3');
      node1.position = Point(coords: [-74.1, 40.1]);
      
      tree.addChild(node1);
      tree.addChild(node2);
      tree.addChild(node3);
      
      final summary = tree.summarize();
      
      expect(summary.totalNodes, 4);
      expect(summary.centerPoint, isNotNull);
      expect(summary.centerPoint!.y, closeTo(40.1, 0.01));
      expect(summary.centerPoint!.x, closeTo(-74.1, 0.01));
      expect(summary.boundingPolygon, isNotEmpty);
    });

    test('should handle nodes without coordinates gracefully', () {
      final tree = ConcreteTreeNode(name: 'Root');
      
      // Node with coordinates
      final nodeWithCoords = ConcreteLeafNode(name: 'With Coords');
      nodeWithCoords.position = Point(coords: [-74.0,40.0]);
      
      // Node without coordinates
      final nodeWithoutCoords = ConcreteLeafNode(name: 'No Coords');
      
      tree.addChild(nodeWithCoords);
      tree.addChild(nodeWithoutCoords);
      
      final summary = tree.summarize();
      
      expect(summary.totalNodes, 3);
      expect(summary.centerPoint, isNotNull); // Should still compute from valid coordinates
      expect(summary.centerPoint!.y, 40.0);
      expect(summary.centerPoint!.x, -74.0);
    });

    test('should compute convex hull for multiple points', () {
      final tree = ConcreteTreeNode(name: 'Root');
      
      // Create a square of points
      final coordinates = [
        [39.0, -75.0], // SW
        [39.0, -74.0], // SE
        [40.0, -74.0], // NE
        [40.0, -75.0], // NW
        [39.5, -74.5], // Center point (should not be in convex hull)
      ];
      
      for (int i = 0; i < coordinates.length; i++) {
        final node = ConcreteLeafNode(name: 'Node $i');
        node.position = Point(coords: [coordinates[i][1],coordinates[i][0]]);
        tree.addChild(node);
      }
      
      final summary = tree.summarize();
      
      expect(summary.totalNodes, 6);
      expect(summary.boundingPolygon.length, 4); // Should be a square (4 corners)
      expect(summary.centerPoint, isNotNull);
    });

    test('should calculate outline area for Level 1 nodes', () {
      final tree = ConcreteTreeNode(name: 'Root');
      final level1Node = ConcreteCompositeNode(name: 'Level 1 with Outline');
      
      // Add outline area to Level 1 node (rectangular area)
      level1Node.properties.set<List<Point>>('outline', [
        Point(coords: [-74.0,40.0]),
        Point(coords: [-74.0,40.1]),
        Point(coords: [-74.1,40.1]),
        Point(coords: [-74.1,40.0]),
      ]);
      
      tree.addChild(level1Node);
      
      final summary = tree.summarize();
      
      expect(summary.totalNodes, 2);
      expect(summary.totalOutlineArea, greaterThan(0));
    });

    test('should handle complex nested hierarchy', () {
      final tree = ConcreteTreeNode(name: 'Forest');
      
      // Level 1: Sites
      final site1 = ConcreteCompositeNode(name: 'Site A');
      final site2 = ConcreteCompositeNode(name: 'Site B');
      
      // Level 2: Plots within sites
      final plot1_1 = ConcreteCompositeNode(name: 'Plot A1');
      final plot1_2 = ConcreteCompositeNode(name: 'Plot A2');
      final plot2_1 = ConcreteCompositeNode(name: 'Plot B1');
      
      // Level 3: Individual trees
      final tree1_1_1 = ConcreteLeafNode(name: 'Tree A1-1');
      final tree1_1_2 = ConcreteLeafNode(name: 'Tree A1-2');
      final tree1_2_1 = ConcreteLeafNode(name: 'Tree A2-1');
      final tree2_1_1 = ConcreteLeafNode(name: 'Tree B1-1');
      
      // Build hierarchy
      tree.addChild(site1);
      tree.addChild(site2);
      
      site1.addChild(plot1_1);
      site1.addChild(plot1_2);
      site2.addChild(plot2_1);
      
      plot1_1.addChild(tree1_1_1);
      plot1_1.addChild(tree1_1_2);
      plot1_2.addChild(tree1_2_1);
      plot2_1.addChild(tree2_1_1);
      
      final summary = tree.summarize();
      
      expect(summary.totalNodes, 10);
      expect(summary.nodeCountsByLevel, {
        1: 1, // Root
        2: 2, // Sites
        3: 3, // Plots
        4: 4, // Trees
      });
    });

    test('toString() should produce a meaningful string representation', () {
      final summaryWithAllFields = NodeSummary(
        totalNodes: 15,
        nodeCountsByLevel: {1: 1, 2: 5, 3: 9},
        boundingPolygon: [
          Point(coords: [-74.0,40.0]),
          Point(coords: [-74.0,40.1]),
          Point(coords: [-74.1,40.1]),
        ],
        centerPoint: Point(coords: [-74.05,40.05]),
        totalOutlineArea: 1234.56,
        additionalStats: {'averageHeight': 25.5, 'speciesCount': 3},
      );

      final summaryString = summaryWithAllFields.toString();

      // Basic checks: ensure key information is present.
      // Avoid checking for exact formatting unless it's critical.
      expect(summaryString, startsWith('NodeSummary('));
      expect(summaryString, endsWith(')'));
      expect(summaryString, contains('totalNodes: 15'));
      expect(summaryString, contains('center: Point(coords: [longitude:-74.05,latitude:40.05])'));
    });

    // Helper to create a fully populated NodeSummary instance for tests
    NodeSummary createPopulatedSummary({
      int totalNodes = 10,
      Map<int, int> nodeCountsByLevel = const {1: 1, 2: 3, 3: 6},
      List<Point> boundingPolygon = const [
        Point(coords: [20.0,10.0]),
        Point(coords: [20.0,10.1])
      ],
      Point? centerPoint = const Point(coords: [20.05,10.05]),
      double? totalOutlineArea = 100.5,
      Map<String, dynamic> additionalStats = const {'avg_height': 15.5},
    }) {
      return NodeSummary(
        totalNodes: totalNodes,
        nodeCountsByLevel: nodeCountsByLevel,
        boundingPolygon: boundingPolygon,
        centerPoint: centerPoint,
        totalOutlineArea: totalOutlineArea,
        additionalStats: additionalStats,
      );
    }

    // ... existing tests for empty, toJson/fromJson, toString ...

    group('Equality (==) and HashCode', () {
      test('instances with identical fields should be equal and have same hashCode', () {
        final summary1 = createPopulatedSummary();
        final summary2 = createPopulatedSummary(); // Identical data, different instance

        expect(summary1, equals(summary2));
        expect(summary1.hashCode, equals(summary2.hashCode));
      });

      test('instances with different totalNodes should not be equal', () {
        final summary1 = createPopulatedSummary(totalNodes: 10);
        final summary2 = createPopulatedSummary(totalNodes: 11);

        expect(summary1, isNot(equals(summary2)));
        // Not strictly required for hashCodes to be different, but good if they are.
        // The main test is that if they WERE equal, hashCodes would BE equal.
      });

      test('instances with different nodeCountsByLevel should not be equal', () {
        final summary1 = createPopulatedSummary(nodeCountsByLevel: {1: 1, 2: 2});
        final summary2 = createPopulatedSummary(nodeCountsByLevel: {1: 1, 2: 3});

        expect(summary1, isNot(equals(summary2)));
      });

      test('instances with different boundingPolygon should not be equal', () {
        final summary1 = createPopulatedSummary(boundingPolygon: [Point(coords: [0,0])]);
        final summary2 = createPopulatedSummary(boundingPolygon: [Point(coords: [1,1])]);

        expect(summary1, isNot(equals(summary2)));
      });

      test('instances with different centerPoint should not be equal', () {
        final summary1 = createPopulatedSummary(centerPoint: Point(coords: [0,0]));
        final summary2 = createPopulatedSummary(centerPoint: Point(coords: [1,1]));
        final summary3 = createPopulatedSummary(centerPoint: null);


        expect(summary1, isNot(equals(summary2)));
        expect(summary1, isNot(equals(summary3)));
        expect(summary3, isNot(equals(summary1)));
      });

      test('instances with different totalOutlineArea should not be equal', () {
        final summary1 = createPopulatedSummary(totalOutlineArea: 100.0);
        final summary2 = createPopulatedSummary(totalOutlineArea: 101.0);
        final summary3 = createPopulatedSummary(totalOutlineArea: null);

        expect(summary1, isNot(equals(summary2)));
        expect(summary1, isNot(equals(summary3)));
        expect(summary3, isNot(equals(summary1)));
      });

      test('instances with different additionalStats should not be equal', () {
        final summary1 = createPopulatedSummary(additionalStats: {'a': 1});
        final summary2 = createPopulatedSummary(additionalStats: {'a': 2});
        final summary3 = createPopulatedSummary(additionalStats: {'b': 1});

        expect(summary1, isNot(equals(summary2)));
        expect(summary1, isNot(equals(summary3)));
      });

      test('equality holds for NodeSummary.empty()', () {
        const summary1 = NodeSummary.empty();
        const summary2 = NodeSummary.empty();
        final summary3 = createPopulatedSummary(
            totalNodes: 0,
            nodeCountsByLevel: const {},
            boundingPolygon: const [],
            centerPoint: null,
            totalOutlineArea: null,
            additionalStats: const {});

        expect(summary1, equals(summary2));
        expect(summary1.hashCode, equals(summary2.hashCode));
        expect(summary1, equals(summary3)); // summary3 is effectively empty
        expect(summary1.hashCode, equals(summary3.hashCode));
      });

      test('reflexivity: an instance is equal to itself', () {
        final summary = createPopulatedSummary();
        expect(summary, equals(summary));
        expect(summary.hashCode, equals(summary.hashCode));
      });

      // Symmetry is implicitly tested by `equals()` matcher.
      // Transitivity is also generally covered if individual field comparisons are correct.

    });

  });
}
