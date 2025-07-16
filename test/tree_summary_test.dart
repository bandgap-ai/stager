/// Tests for TreeNode.summarize() method functionality.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:stager/tree/concrete_tree.dart';
import 'package:stager/tree/node_summary.dart';

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
          const LatLng(40.0, -74.0),
          const LatLng(40.1, -74.0),
          const LatLng(40.1, -74.1),
        ],
        centerPoint: const LatLng(40.05, -74.05),
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
      final tree = ConcreteTreeNode(id: 'root', name: 'Empty Tree');
      
      final summary = tree.summarize();
      
      expect(summary.totalNodes, 1); // Just the root node
      expect(summary.nodeCountsByLevel, {1: 1});
      expect(summary.boundingPolygon, isEmpty);
      expect(summary.centerPoint, isNull);
      expect(summary.totalOutlineArea, isNull);
    });

    test('should count nodes correctly in simple hierarchy', () {
      final tree = ConcreteTreeNode(id: 'root', name: 'Root');
      final level1Node = ConcreteCompositeNode(id: 'l1', name: 'Level 1');
      final level2Node1 = ConcreteLeafNode(id: 'l2_1', name: 'Level 2 Node 1');
      final level2Node2 = ConcreteLeafNode(id: 'l2_2', name: 'Level 2 Node 2');
      
      tree.addChild(level1Node);
      level1Node.addChild(level2Node1);
      level1Node.addChild(level2Node2);
      
      final summary = tree.summarize();
      
      expect(summary.totalNodes, 4);
      expect(summary.nodeCountsByLevel, {1: 1, 2: 1, 3: 2});
    });

    test('should extract coordinates and compute center point', () {
      final tree = ConcreteTreeNode(id: 'root', name: 'Root');
      
      // Create nodes with specific coordinates
      final node1 = ConcreteLeafNode(id: 'n1', name: 'Node 1');
      node1.properties.setProperty('latitude', 40.0);
      node1.properties.setProperty('longitude', -74.0);
      
      final node2 = ConcreteLeafNode(id: 'n2', name: 'Node 2');
      node2.properties.setProperty('latitude', 40.2);
      node2.properties.setProperty('longitude', -74.2);
      
      final node3 = ConcreteLeafNode(id: 'n3', name: 'Node 3');
      node3.properties.setProperty('latitude', 40.1);
      node3.properties.setProperty('longitude', -74.1);
      
      tree.addChild(node1);
      tree.addChild(node2);
      tree.addChild(node3);
      
      final summary = tree.summarize();
      
      expect(summary.totalNodes, 4);
      expect(summary.centerPoint, isNotNull);
      expect(summary.centerPoint!.latitude, closeTo(40.1, 0.01));
      expect(summary.centerPoint!.longitude, closeTo(-74.1, 0.01));
      expect(summary.boundingPolygon, isNotEmpty);
    });

    test('should handle nodes without coordinates gracefully', () {
      final tree = ConcreteTreeNode(id: 'root', name: 'Root');
      
      // Node with coordinates
      final nodeWithCoords = ConcreteLeafNode(id: 'with_coords', name: 'With Coords');
      nodeWithCoords.properties.setProperty('latitude', 40.0);
      nodeWithCoords.properties.setProperty('longitude', -74.0);
      
      // Node without coordinates
      final nodeWithoutCoords = ConcreteLeafNode(id: 'no_coords', name: 'No Coords');
      
      tree.addChild(nodeWithCoords);
      tree.addChild(nodeWithoutCoords);
      
      final summary = tree.summarize();
      
      expect(summary.totalNodes, 3);
      expect(summary.centerPoint, isNotNull); // Should still compute from valid coordinates
      expect(summary.centerPoint!.latitude, 40.0);
      expect(summary.centerPoint!.longitude, -74.0);
    });

    test('should compute convex hull for multiple points', () {
      final tree = ConcreteTreeNode(id: 'root', name: 'Root');
      
      // Create a square of points
      final coordinates = [
        [39.0, -75.0], // SW
        [39.0, -74.0], // SE
        [40.0, -74.0], // NE
        [40.0, -75.0], // NW
        [39.5, -74.5], // Center point (should not be in convex hull)
      ];
      
      for (int i = 0; i < coordinates.length; i++) {
        final node = ConcreteLeafNode(id: 'n$i', name: 'Node $i');
        node.properties.setProperty('latitude', coordinates[i][0]);
        node.properties.setProperty('longitude', coordinates[i][1]);
        tree.addChild(node);
      }
      
      final summary = tree.summarize();
      
      expect(summary.totalNodes, 6);
      expect(summary.boundingPolygon.length, 4); // Should be a square (4 corners)
      expect(summary.centerPoint, isNotNull);
    });

    test('should calculate outline area for Level 1 nodes', () {
      final tree = ConcreteTreeNode(id: 'root', name: 'Root');
      final level1Node = ConcreteCompositeNode(id: 'l1', name: 'Level 1 with Outline');
      
      // Add outline area to Level 1 node (rectangular area)
      level1Node.properties.setProperty('outline', [
        {'latitude': 40.0, 'longitude': -74.0},
        {'latitude': 40.0, 'longitude': -74.1},
        {'latitude': 40.1, 'longitude': -74.1},
        {'latitude': 40.1, 'longitude': -74.0},
      ]);
      
      tree.addChild(level1Node);
      
      final summary = tree.summarize();
      
      expect(summary.totalNodes, 2);
      expect(summary.totalOutlineArea, greaterThan(0));
    });

    test('should handle complex nested hierarchy', () {
      final tree = ConcreteTreeNode(id: 'root', name: 'Forest');
      
      // Level 1: Sites
      final site1 = ConcreteCompositeNode(id: 'site1', name: 'Site A');
      final site2 = ConcreteCompositeNode(id: 'site2', name: 'Site B');
      
      // Level 2: Plots within sites
      final plot1_1 = ConcreteCompositeNode(id: 'plot1_1', name: 'Plot A1');
      final plot1_2 = ConcreteCompositeNode(id: 'plot1_2', name: 'Plot A2');
      final plot2_1 = ConcreteCompositeNode(id: 'plot2_1', name: 'Plot B1');
      
      // Level 3: Individual trees
      final tree1_1_1 = ConcreteLeafNode(id: 'tree1_1_1', name: 'Tree A1-1');
      final tree1_1_2 = ConcreteLeafNode(id: 'tree1_1_2', name: 'Tree A1-2');
      final tree1_2_1 = ConcreteLeafNode(id: 'tree1_2_1', name: 'Tree A2-1');
      final tree2_1_1 = ConcreteLeafNode(id: 'tree2_1_1', name: 'Tree B1-1');
      
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

    test('should handle invalid coordinate data gracefully', () {
      final tree = ConcreteTreeNode(id: 'root', name: 'Root');
      
      final nodeWithInvalidCoords = ConcreteLeafNode(id: 'invalid', name: 'Invalid');
      nodeWithInvalidCoords.properties.setProperty('latitude', 'not_a_number');
      nodeWithInvalidCoords.properties.setProperty('longitude', null);
      
      final nodeWithValidCoords = ConcreteLeafNode(id: 'valid', name: 'Valid');
      nodeWithValidCoords.properties.setProperty('latitude', 40.0);
      nodeWithValidCoords.properties.setProperty('longitude', -74.0);
      
      tree.addChild(nodeWithInvalidCoords);
      tree.addChild(nodeWithValidCoords);
      
      final summary = tree.summarize();
      
      expect(summary.totalNodes, 3);
      expect(summary.centerPoint, isNotNull); // Should compute from valid coordinates only
      expect(summary.centerPoint!.latitude, 40.0);
    });
  });
}
