/// This file provides sample data for the tree structure in the Tracee application.
/// This data is used for development and testing purposes.
library;
import 'package:stager_platform/tree/concrete_tree.dart';
import 'package:stager_platform/tree/tree.dart';

/// A list of [TreeNode]s representing sample sites for testing and development.
///
/// Each site simulates a farm or park with various site locations,
/// features, and objects, including chestnut trees.
/// Each node includes an ID, name, and optional geographical position.
final List<TreeNode> sampleSites = _buildSampleSites();

List<TreeNode> _buildSampleSites() {
  final meadowview = ConcreteTreeNode(
    id: 'meadowview',
    name: 'Meadowview Research Farm',
    initialProperties: {
      // Approximate center of Meadowview Research Farm
      'latitude': 36.73444,
      'longitude': -81.86052,
    },
  );

  final planting2025 = ConcreteTreeNode(
    id: 'planting_2025',
    name: '2025 Planting',
    initialProperties: {
      // Location of the 2025 planting area
      'latitude': 36.73442,
      'longitude': -81.86052,
      // Location of the 2025 planting area
      'outline': [
        // Define a rectangular outline around the planting area
        {'latitude': 36.73445, 'longitude': -81.86050}, // Top-left
        {'latitude': 36.73445, 'longitude': -81.86060}, // Top-right
        {'latitude': 36.73438, 'longitude': -81.86060}, // Bottom-right
        {'latitude': 36.73438, 'longitude': -81.86050}, // Bottom-left
      ],
    },
  );

  final row1 = ConcreteTreeNode(
    id: 'row_1',
    name: 'Row 1',
    initialProperties: {
      // Start of Row 1
      'latitude': 36.73441,
      'longitude': -81.86052,
    },
  );
  row1.addChild(ConcreteLeafNode(id: 'tree_1', name: 'Tree 1', initialProperties: {'latitude': 36.73441, 'longitude': -81.86053, 'species': 'American Chestnut', 'age': 1, 'health': 'Good'}));
  row1.addChild(ConcreteLeafNode(id: 'tree_2', name: 'Tree 2', initialProperties: {'latitude': 36.73441, 'longitude': -81.86054, 'species': 'American Chestnut', 'age': 1, 'health': 'Good'}));
  row1.addChild(ConcreteLeafNode(id: 'tree_3', name: 'Tree 3', initialProperties: {'latitude': 36.73441, 'longitude': -81.86055, 'species': 'American Chestnut', 'age': 1, 'health': 'Fair'}));

  final row2 = ConcreteTreeNode(
    id: 'row_2',
    name: 'Row 2',
    initialProperties: {
      // Start of Row 2
      'latitude': 36.73440,
      'longitude': -81.86052,
    },
  );
  row2.addChild(ConcreteLeafNode(id: 'tree_4', name: 'Tree 4', initialProperties: {'latitude': 36.73440, 'longitude': -81.86056, 'species': 'American Chestnut', 'age': 1, 'health': 'Good'}));
  row2.addChild(ConcreteLeafNode(id: 'tree_5', name: 'Tree 5', initialProperties: {'latitude': 36.73440, 'longitude': -81.86057, 'species': 'American Chestnut', 'age': 1, 'health': 'Poor'}));
  row2.addChild(ConcreteLeafNode(id: 'tree_6', name: 'Tree 6', initialProperties: {'latitude': 36.73440, 'longitude': -81.86059, 'species': 'American Chestnut', 'age': 1, 'health': 'Good'}));

  planting2025.addChild(row1);
  planting2025.addChild(row2);

  final accessRoad = ConcreteLeafNode(
    id: 'access_road',
    name: 'Access Road',
    initialProperties: {
      // Location of an access road
      'latitude': 36.73408,
      'longitude': -81.86114,
      'type': 'gravel',
      'length_m': 500,
    },
  );

  meadowview.addChild(planting2025);
  meadowview.addChild(accessRoad);

  final urbanPark = ConcreteTreeNode(
    id: 'urban_park',
    name: 'Urban Chestnut Park',
    initialProperties: {
      // Approximate center of a park in Philadelphia
      'latitude': 39.95,
      'longitude': -75.16,
    },
  );

  final sectionA = ConcreteTreeNode(
    id: 'section_a',
    name: 'Section A',
    initialProperties: {
      'latitude': 39.951,
      'longitude': -75.161,
      'outline': [
        // Define a triangular outline for Section A
        {'latitude': 39.9512, 'longitude': -75.1608}, // Top
        {'latitude': 39.9508, 'longitude': -75.1615}, // Bottom-right
        {'latitude': 39.9508, 'longitude': -75.1605}, // Bottom-left
      ],
    },
  );
  sectionA.addChild(ConcreteLeafNode(id: 'tree_urban_1', name: 'Urban Tree 1', initialProperties: {'latitude': 39.951, 'longitude': -75.161, 'species': 'Hybrid Chestnut', 'planted_year': 2010}));
  sectionA.addChild(ConcreteLeafNode(id: 'tree_urban_2', name: 'Urban Tree 2', initialProperties: {'latitude': 39.951, 'longitude': -75.1615,'species': 'American Chestnut', 'planted_year': 2012}));

  final playground = ConcreteLeafNode(
    id: 'playground',
    name: 'Playground Area',
    initialProperties: {
      'latitude': 39.949,
      'longitude': -75.162,
      'amenity': 'playground',
      'surface': 'wood_chips',
    },
  );

  urbanPark.addChild(sectionA);
  urbanPark.addChild(playground);

  return [meadowview, urbanPark];
}
