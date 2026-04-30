/// Concrete implementation of [TreeNode].
///
/// This class represents the root of a tree structure, providing concrete
/// implementations for tree traversal (depth-first and breadth-first) and
/// node searching.
library;

import 'dart:math' as math;
import 'tree.dart';
import 'iterators.dart';
import 'node_summary.dart';
import '../system/point.dart';
import '../system/stager_context.dart';
import '../builders/basic_builder.dart';

/// This is a builder for concrete tree nodes.
///
/// [context]: The context for building the leaf node.
/// Returns a [ConcreteTreeNode] instance.
@BasicBuilder(name: 'ConcreteLeafNode')
ConcreteTreeNode buildConcreteTreeNode(StagerContext context) {
  ConcreteTreeNode node = ConcreteTreeNode(name: 'Tree');
  node.fromMap(context.toMap());
  return node;
}

class ConcreteTreeNode extends ConcreteCompositeNode implements TreeNode {
  /// Creates a [ConcreteTreeNode] instance.
  ///
  /// [id]: The unique identifier for the tree node.
  /// [name]: The display name of the tree node.
  /// [initialProperties]: Optional initial properties for the node.
  ConcreteTreeNode({
    required super.name,
    super.initialProperties,
  });

  @override
  Iterator<LeafNode> createIterator() {
    // Default to depth-first for createIterator as specified.
    return depthFirstIterator;
  }

  @override
  Iterator<LeafNode> get breadthFirstIterator => BreadthFirstIterator(this);

  @override
  Iterator<LeafNode> get depthFirstIterator => DepthFirstIterator(this);

  @override
  List<LeafNode> find(bool Function(LeafNode) predicate) {
    final List<LeafNode> results = [];
    // Use the default iterator (depth-first) to traverse and find nodes.
    final iterator = createIterator();
    while (iterator.moveNext()) {
      if (predicate(iterator.current)) {
        results.add(iterator.current);
      }
    }
    return results;
  }

  @override
  NodeSummary summarize() {
    final nodeCountsByLevel = <int, int>{};
    final validCoordinates = <Point>[];
    final allNodes = <LeafNode>[];
    double totalOutlineArea = 0.0;
    bool hasOutlineAreas = false;

    // The iterator includes this root node and all children
    final iterator = depthFirstIterator;
    while (iterator.moveNext()) {
      allNodes.add(iterator.current);
    }

    // Process each node
    for (final node in allNodes) {
      // Calculate node level in tree hierarchy
      final level = _calculateNodeLevel(node);
      nodeCountsByLevel[level] = (nodeCountsByLevel[level] ?? 0) + 1;

      // Extract coordinates if available
      validCoordinates.add(node.position);

      // Calculate outline area for Level 1 nodes (direct children of root)
      if (level == 2) { // Level 1 nodes are at level 2 (root is level 1)
        final outlineArea = _calculateOutlineArea(node);
        if (outlineArea != null) {
          totalOutlineArea += outlineArea;
          hasOutlineAreas = true;
        }
      }
    }

    // Compute geographic bounds and center
    final boundingPolygon = _computeConvexHull(validCoordinates);
    final centerPoint = _computeCenterPoint(validCoordinates);

    return NodeSummary(
      totalNodes: allNodes.length,
      nodeCountsByLevel: nodeCountsByLevel,
      boundingPolygon: boundingPolygon,
      centerPoint: centerPoint,
      totalOutlineArea: hasOutlineAreas ? totalOutlineArea : null,
      additionalStats: {
        'nodesWithCoordinates': validCoordinates.length,
        'nodesWithoutCoordinates': allNodes.length - validCoordinates.length,
      },
    );
  }

  /// Calculates the hierarchical level of a node relative to this tree.
  int _calculateNodeLevel(LeafNode node) {
    if (node == this) return 1; // Root level
    
    int level = 1;
    LeafNode? current = node;
    
    while (current?.parent != null && current?.parent != this) {
      level++;
      current = current?.parent;
    }
    
    // Add 1 because we want level relative to this tree (direct children = level 2)
    return level + 1;
  }

  /// Calculates the area of an outline polygon for a node.
  double? _calculateOutlineArea(LeafNode node) {
    double? retArea;
    try {
      if (containsProperty('outline')) {
        final points = property('outline') as List<Point>;

        if (points.length < 3) return null;

        // Calculate area using shoelace formula (approximation for small areas)
        double area = 0.0;
        for (int i = 0; i < points.length; i++) {
          final j = (i + 1) % points.length;
          area += points[i].x * points[j].y;
          area -= points[j].x * points[i].y;
        }
        area = (area / 2.0).abs();

        // Convert from degrees squared to approximate square meters
        // This is a rough approximation - for precise calculations,
        // proper geographic projections should be used
        const double degreesToMeters = 111320.0; // Approximate meters per degree
        retArea = area * degreesToMeters * degreesToMeters;

      } else {
        retArea = null;
      }
    } catch (e) {
      retArea = null;
    }
    return retArea;
  }

  /// Computes the convex hull of a set of points using Graham scan algorithm.
  List<Point> _computeConvexHull(List<Point> points) {
    if (points.length < 3) return points;

    // Find the bottom-most point (or left most in case of tie)
    Point start = points[0];
    for (final point in points) {
      if (point.y < start.y || 
          (point.y == start.y && point.x < start.x)) {
        start = point;
      }
    }

    // Sort points by polar angle with respect to start point
    final sorted = List<Point>.from(points);
    sorted.remove(start);
    sorted.sort((a, b) {
      final angleA = math.atan2(a.y - start.y, a.x - start.x);
      final angleB = math.atan2(b.y - start.y, b.x - start.x);
      return angleA.compareTo(angleB);
    });

    // Graham scan
    final hull = <Point>[start];
    for (final point in sorted) {
      while (hull.length > 1 && 
             _crossProduct(hull[hull.length - 2], hull[hull.length - 1], point) <= 0) {
        hull.removeLast();
      }
      hull.add(point);
    }

    return hull;
  }

  /// Calculates the cross product for three points (used in convex hull).
  double _crossProduct(Point p1, Point p2, Point p3) {
    return (p2.x - p1.x) * (p3.y - p1.y) - 
           (p2.y - p1.y) * (p3.x - p1.x);
  }

  /// Computes the geographic center point (centroid) of a set of coordinates.
  Point? _computeCenterPoint(List<Point> points) {
    if (points.isEmpty) return null;

    double sumLat = 0.0;
    double sumLng = 0.0;

    for (final point in points) {
      sumLat += point.y;
      sumLng += point.x;
    }

    return Point(coords: [sumLng / points.length, sumLat / points.length]);
  }
}
