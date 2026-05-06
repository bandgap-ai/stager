import '../../system/stager_context.dart';
import '../../system/point.dart';
import '../kml_hole.dart';
import '../style/kml_style_manager.dart';
import 'kml_geometry_node.dart';
import '../../builders/basic_builder.dart';

/// This is a builder for KML Polygon nodes.
///
/// [context]: The context for building the node.
/// Returns a [KMLPolygonNode] instance.
@BasicBuilder(name: 'KMLPolygonNode')
KMLPolygonNode buildKMLPolygonNode(StagerContext context) {
  final manager = KMLStyleManager();
  KMLPolygonNode node = KMLPolygonNode(name: 'Polygon',
      styleManager: manager, outline: []);
  node.fromMap(context.toMap());
  return node;
}

/// A concrete [KMLGeometryNode] representing a KML Polygon.
///
/// This class behaves like a Record, encapsulating a geographic polygon 
/// feature consisting of a fixed outer boundary (outline) and zero or more 
/// inner boundaries (holes) defined at instantiation.
/// 
/// Once created, the geographic coordinates cannot be modified.
class KMLPolygonNode extends KMLGeometryNode {

  /// The list of coordinates defining the outer boundary.
  List<Point> _outline = [];

  /// The list of [KMLHole] objects defining inner cutout regions.
  List<KMLHole> _holes = [];

  /// Creates a [KMLPolygonNode] instance.
  ///
  /// [name]: The display name of the polygon.
  /// [styleManager]: The manager used to resolve shared styles.
  /// [outline]: The fixed list of coordinates defining the outer boundary.
  /// [holes]: An optional list of [KMLHole] objects defining inner cutouts. 
  /// Defaults to an empty list.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional initial metadata.
  KMLPolygonNode({
    required super.name,
    required super.styleManager,
    required List<Point> outline,
    List<KMLHole> holes = const [],
    super.styleUrl = 'default',
    super.initialProperties,
  }) : _outline = outline, _holes = holes;

  /// The list of geographic coordinates defining the outer boundary.
  List<Point> get outline {
    return List<Point>.from(_outline);
  }

  /// Sets the list of geographic coordinates defining the outer boundary.
  set outline(List<Point> newOutline) {
    _outline = newOutline;
    notify();
  }

  /// The list of [KMLHole] objects defining inner cutout regions.
  List<KMLHole> get holes {
    return List<KMLHole>.from(_holes);
  }

  /// Sets the list of [KMLHole] objects defining inner cutout regions.
  set holes(List<KMLHole> newHoles) {
    _holes = newHoles;
    notify();
  }

  @override
  Map<String, Object> toMap() {
    // Start with the base node state.
    final map = super.toMap();

    // Harvest polygon-specific members.
    map.addAll({
      // Map the elements from lists of objects to lists of maps created by
      // object.toMap().
      'outline' :  _outline.map((p) => p.toMap()).toList(),
      'holes' : _holes.map((h) => h.toMap()).toList(),
    });

    return map;
  }

  @override
  void fromMap(Map<String, Object> inputMap) {
    final map = Map<String, Object>.from(inputMap);

    // Rehydrate outline member.
    if (map.containsKey('outline')) {
      final List<Object> rawList = map['outline']! as List<Object>;
      // FIXME - We could clean this up with the registry when it is complete.
      _outline = rawList.map((e) => buildPoint(
          StagerContext(e as Map<String, Object>))).toList();
      map.remove('outline');
    }

    // Rehydrate holes member.
    if (map.containsKey('holes')) {
      final List<Object> rawList = map['holes']! as List<Object>;
      _holes = rawList.map((e) => KMLHole.fromMap(
          e as Map<String, Object>)).toList();
      map.remove('holes');
    }

    // Delegate the remaining data to the base class.
    super.fromMap(map);
  }
}
