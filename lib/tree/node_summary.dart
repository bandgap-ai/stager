import 'package:latlong2/latlong.dart';

/// A comprehensive summary of a node and its subtree containing node counts,
/// geographic bounds, and statistical information.
///
/// This class provides a snapshot of node data useful for analysis,
/// reporting, and visualization purposes in forestry applications.
/// Can be used to summarize any node and all its children.
@Deprecated("This class violates several Stager policies and is deprecated.")
class NodeSummary {
  /// Total number of nodes in the tree.
  final int totalNodes;

  /// Count of nodes organized by their level in the tree hierarchy.
  /// Key: level number (1, 2, 3, etc.), Value: count of nodes at that level.
  final Map<int, int> nodeCountsByLevel;

  /// Polygon representing the convex hull of all node positions.
  /// Empty list if no valid coordinates are found.
  final List<LatLng> boundingPolygon;

  /// Geographic center point (centroid) of all node positions.
  /// Null if no valid coordinates are found.
  final LatLng? centerPoint;

  /// Total area covered by Level 1 outline polygons in square meters.
  /// Null if no outline areas are defined.
  final double? totalOutlineArea;

  /// Additional statistics and metadata.
  /// Can include custom metrics relevant to forestry applications.
  final Map<String, dynamic> additionalStats;

  /// Creates a new NodeSummary instance.
  const NodeSummary({
    required this.totalNodes,
    required this.nodeCountsByLevel,
    required this.boundingPolygon,
    this.centerPoint,
    this.totalOutlineArea,
    this.additionalStats = const {},
  });

  /// Creates an empty NodeSummary for nodes with no children.
  const NodeSummary.empty()
      : totalNodes = 0,
        nodeCountsByLevel = const {},
        boundingPolygon = const [],
        centerPoint = null,
        totalOutlineArea = null,
        additionalStats = const {};

  /// Converts this NodeSummary to a JSON-serializable map.
  Map<String, dynamic> toJson() {
    return {
      'totalNodes': totalNodes,
      'nodeCountsByLevel': nodeCountsByLevel,
      'boundingPolygon': boundingPolygon
          .map((point) => {
                'latitude': point.latitude,
                'longitude': point.longitude,
              })
          .toList(),
      'centerPoint': centerPoint != null
          ? {
              'latitude': centerPoint!.latitude,
              'longitude': centerPoint!.longitude,
            }
          : null,
      'totalOutlineArea': totalOutlineArea,
      'additionalStats': additionalStats,
    };
  }

  /// Creates a NodeSummary from a JSON map.
  factory NodeSummary.fromJson(Map<String, dynamic> json) {
    return NodeSummary(
      totalNodes: json['totalNodes'] as int,
      nodeCountsByLevel: Map<int, int>.from(json['nodeCountsByLevel'] as Map),
      boundingPolygon: (json['boundingPolygon'] as List)
          .map((point) => LatLng(
                point['latitude'] as double,
                point['longitude'] as double,
              ))
          .toList(),
      centerPoint: json['centerPoint'] != null
          ? LatLng(
              json['centerPoint']['latitude'] as double,
              json['centerPoint']['longitude'] as double,
            )
          : null,
      totalOutlineArea: json['totalOutlineArea'] as double?,
      additionalStats: Map<String, dynamic>.from(
          json['additionalStats'] as Map? ?? {}),
    );
  }

  @override
  String toString() {
    return 'NodeSummary(totalNodes: $totalNodes, '
        'levels: ${nodeCountsByLevel.keys.length}, '
        'boundingPoints: ${boundingPolygon.length}, '
        'center: $centerPoint, '
        'totalArea: ${totalOutlineArea?.toStringAsFixed(2)}m²)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NodeSummary &&
        other.totalNodes == totalNodes &&
        _mapEquals(other.nodeCountsByLevel, nodeCountsByLevel) &&
        _listEquals(other.boundingPolygon, boundingPolygon) &&
        other.centerPoint == centerPoint &&
        other.totalOutlineArea == totalOutlineArea &&
        _mapEquals(other.additionalStats, additionalStats);
  }

  @override
  int get hashCode {
    return Object.hash(
      totalNodes,
      nodeCountsByLevel,
      boundingPolygon,
      centerPoint,
      totalOutlineArea,
      additionalStats,
    );
  }

  /// Helper method to compare maps for equality.
  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  /// Helper method to compare lists for equality.
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
