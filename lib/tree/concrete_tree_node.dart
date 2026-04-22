/// Concrete implementation of [TreeNode].
///
/// This class represents the root of a tree structure, providing concrete
/// implementations for tree traversal (depth-first and breadth-first) and
/// node searching.
library;
import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/tree/iterators.dart';
import 'package:stager_platform/tree/node_summary.dart';

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
    final validCoordinates = <LatLng>[];
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
      final coordinates = _extractCoordinates(node);
      if (coordinates != null) {
        validCoordinates.add(coordinates);
      }

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

  /// Extracts valid coordinates from a node's properties.
  LatLng? _extractCoordinates(LeafNode node) {
    LatLng? pos;
    try {
      if (containsProperty('latitude') && containsProperty('longitude')) {
        // Leaving this AS-IS for now because I need to fix positions differently.
        final lat = typedProperty('latitude').value as double;
        final lng = typedProperty('longitude').value as double;
        pos = LatLng(lat,lng);
      }
    } catch (e) {
      pos = null;
    }
    return pos;
  }

  /// Calculates the area of an outline polygon for a node.
  double? _calculateOutlineArea(LeafNode node) {
    double? retArea;
    try {
      if (containsProperty('outline')) {
        final points = property('outline') as List<LatLng>;

        if (points.length < 3) return null;

        // Calculate area using shoelace formula (approximation for small areas)
        double area = 0.0;
        for (int i = 0; i < points.length; i++) {
          final j = (i + 1) % points.length;
          area += points[i].longitude * points[j].latitude;
          area -= points[j].longitude * points[i].latitude;
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
  List<LatLng> _computeConvexHull(List<LatLng> points) {
    if (points.length < 3) return points;

    // Find the bottom-most point (or left most in case of tie)
    LatLng start = points[0];
    for (final point in points) {
      if (point.latitude < start.latitude || 
          (point.latitude == start.latitude && point.longitude < start.longitude)) {
        start = point;
      }
    }

    // Sort points by polar angle with respect to start point
    final sorted = List<LatLng>.from(points);
    sorted.remove(start);
    sorted.sort((a, b) {
      final angleA = math.atan2(a.latitude - start.latitude, a.longitude - start.longitude);
      final angleB = math.atan2(b.latitude - start.latitude, b.longitude - start.longitude);
      return angleA.compareTo(angleB);
    });

    // Graham scan
    final hull = <LatLng>[start];
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
  double _crossProduct(LatLng p1, LatLng p2, LatLng p3) {
    return (p2.longitude - p1.longitude) * (p3.latitude - p1.latitude) - 
           (p2.latitude - p1.latitude) * (p3.longitude - p1.longitude);
  }

  /// Computes the geographic center point (centroid) of a set of coordinates.
  LatLng? _computeCenterPoint(List<LatLng> points) {
    if (points.isEmpty) return null;

    double sumLat = 0.0;
    double sumLng = 0.0;

    for (final point in points) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }

    return LatLng(sumLat / points.length, sumLng / points.length);
  }
}
