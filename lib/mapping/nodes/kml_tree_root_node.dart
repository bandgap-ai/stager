// Dart core
import 'dart:math' as math;

// External packages
import 'package:latlong2/latlong.dart';

import '../../tree/node_summary.dart';
import '../../tree/tree.dart';
import '../style/kml_style_manager.dart';
import '../style/kml_stylable.dart';
import 'kml_path_node.dart';
import 'kml_point_node.dart';
import 'kml_polygon_node.dart';

/// A [ConcreteTreeNode] specialized for representing the root of a KML document.
///
/// This class serves as the top-level entry point for a tree derived from a 
/// KML file. In the KML specification, this typically corresponds to the 
/// `<Document>` element or the root `<kml>` tag.
///
/// It provides specialized geographic summarization logic that understands the 
/// redesigned KML node hierarchy and its strongly-typed geographic data.
class KMLTreeRootNode extends ConcreteTreeNode with KMLStylable {
  /// Creates a [KMLTreeRootNode].
  ///
  /// [id]: A unique identifier for this node within the Stager tree.
  /// [name]: The display name of the tree, typically from the KML `<name>` tag.
  /// [styleManager]: The registry where shared styles are stored.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional initial metadata for the node.
  KMLTreeRootNode({
    required super.id,
    required super.name,
    required KMLStyleManager styleManager,
    String styleUrl = 'default',
    super.initialProperties,
  }) {
    // Initializing the late final fields from the KMLStylable mixin.
    this.styleManager = styleManager;
    this.styleUrl = styleUrl;
  }

  @override
  NodeSummary summarize() {
    final nodeCountsByLevel = <int, int>{};
    final validCoordinates = <LatLng>[];
    final allNodes = <LeafNode>[];

    // Iteratively traverse the entire tree starting from this root.
    final iterator = depthFirstIterator;
    while (iterator.moveNext()) {
      final node = iterator.current;
      allNodes.add(node);

      // Track node levels.
      final level = _calculateNodeLevel(node);
      nodeCountsByLevel[level] = (nodeCountsByLevel[level] ?? 0) + 1;

      // Geographic Extraction: Use the new strongly-typed node API.
      // Optimized Branch Order: Check for point geometries first.
      if (node is KMLPointNode) {
        validCoordinates.add(node.location);
      } else if (node is KMLPathNode) {
        validCoordinates.addAll(node.outline);
      } else if (node is KMLPolygonNode) {
        validCoordinates.addAll(node.outline);
        // Include holes in the summary data if present.
        for (final hole in node.holes) {
          validCoordinates.addAll(hole.points);
        }
      }
    }

    // Compute geographic bounds and center. These methods will throw if 
    // validCoordinates is empty, ensuring a hardened summary.
    final centerPoint = _computeCenterPoint(validCoordinates);
    final boundingPolygon = _computeConvexHull(validCoordinates);

    return NodeSummary(
      totalNodes: allNodes.length,
      nodeCountsByLevel: nodeCountsByLevel,
      boundingPolygon: boundingPolygon,
      centerPoint: centerPoint,
      additionalStats: {
        'kml_points': allNodes.whereType<KMLPointNode>().length,
        'kml_paths': allNodes.whereType<KMLPathNode>().length,
        'kml_polygons': allNodes.whereType<KMLPolygonNode>().length,
      },
    );
  }

  /// Calculates the hierarchical level of a node relative to this root.
  int _calculateNodeLevel(LeafNode node) {
    late int level;
    if (node == this) {
      level = 1;
    } else {
      int count = 1;
      LeafNode? current = node;
      // Navigate up the parent chain until the root is reached.
      while (current?.parent != null && current?.parent != this) {
        count++;
        current = current?.parent;
      }
      level = count + 1;
    }
    return level;
  }

  /// Computes the geographic center point (centroid) of a set of coordinates.
  /// 
  /// Returns a non-nullable [LatLng].
  /// 
  /// Throws a [StateError] if the [points] list is empty.
  LatLng _computeCenterPoint(List<LatLng> points) {
    late LatLng result;
    if (points.isEmpty) {
      throw StateError('Cannot compute center point: no coordinates available.');
    } else {
      double sumLat = 0.0;
      double sumLng = 0.0;
      for (final point in points) {
        sumLat += point.latitude;
        sumLng += point.longitude;
      }
      result = LatLng(sumLat / points.length, sumLng / points.length);
    }
    return result;
  }

  /// Computes the convex hull of a set of points using the Graham scan algorithm.
  /// 
  /// The convex hull represents the minimal "bounding polygon" that encloses 
  /// all points in the set.
  /// 
  /// Throws a [StateError] if the [points] list is empty.
  List<LatLng> _computeConvexHull(List<LatLng> points) {
    late List<LatLng> result;
    if (points.isEmpty) {
      throw StateError('Cannot compute convex hull: no coordinates available.');
    } else if (points.length < 3) {
      result = List<LatLng>.from(points);
    } else {
      // Find the bottom-most point (lowest latitude).
      LatLng start = points[0];
      for (final point in points) {
        if (point.latitude < start.latitude || 
            (point.latitude == start.latitude && point.longitude < start.longitude)) {
          start = point;
        }
      }

      // Sort points by polar angle relative to the start point.
      final sorted = List<LatLng>.from(points);
      sorted.remove(start);
      sorted.sort((a, b) {
        final angleA = math.atan2(a.latitude - start.latitude, a.longitude - start.longitude);
        final angleB = math.atan2(b.latitude - start.latitude, b.longitude - start.longitude);
        return angleA.compareTo(angleB);
      });

      // Perform the scan to build the hull.
      final hull = <LatLng>[start];
      for (final point in sorted) {
        while (hull.length > 1 && 
               _crossProduct(hull[hull.length - 2], hull[hull.length - 1], point) <= 0) {
          hull.removeLast();
        }
        hull.add(point);
      }
      result = hull;
    }
    return result;
  }

  /// Calculates the 2D cross product for three points.
  /// 
  /// Returns a positive value for a counter-clockwise turn, negative for a 
  /// clockwise turn, and zero for collinear points.
  double _crossProduct(LatLng p1, LatLng p2, LatLng p3) {
    return (p2.longitude - p1.longitude) * (p3.latitude - p1.latitude) - 
           (p2.latitude - p1.latitude) * (p3.longitude - p1.longitude);
  }
}
