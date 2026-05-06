import '../../system/stager_context.dart';
import '../../system/point.dart';
import '../../system/typed_value.dart';
import 'kml_geometry_node.dart';

/// A concrete [KMLGeometryNode] representing a KML LineString (Path).
///
/// This class behaves like a Record, encapsulating a fixed geographic path 
/// defined at instantiation. It provides a strongly-typed, non-nullable 
/// accessor for the 'outline' property.
/// 
/// Once created, the geographic coordinates cannot be modified.
class KMLPathNode extends KMLGeometryNode {

  /// The list of coordinates defining the path.
  List<Point> _outline = [];

  /// Creates a [KMLPathNode] instance.
  ///
  /// [name]: The display name of the path.
  /// [styleManager]: The manager used to resolve shared styles.
  /// [outline]: The fixed list of coordinates defining the path.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional initial metadata.
  KMLPathNode({
    required super.name,
    required super.styleManager,
    required List<Point> outline,
    super.styleUrl = 'default',
    super.initialProperties,
  }) : _outline = outline;

  /// The list of geographic coordinates defining the path.
  List<Point> get outline {
    return List<Point>.from(_outline);
  }

  /// Sets the list of geographic coordinates defining the path.
  set outline(List<Point> newOutline) {
    _outline = newOutline;
    notify();
  }

  @override
  Map<String, Object> toMap() {
    // Add the outline to the map.
    final map = super.toMap();
    map.addAll({'outline' : _outline.map((e) => e.toMap()).toList()});
    return map;
  }

  @override
  void fromMap(Map<String, Object> inputMap) {
    var map = Map.of(inputMap);

    // Pull the outline from the map.
    if (map.containsKey('outline')) {
      final List<Object> rawList = map['outline']! as List<Object>;
      _outline = rawList.map((e) => buildPoint(
          StagerContext(e as Map<String, Object>))).toList();
      map.remove('outline');
    }

    // Let the base class handle the rest.
    super.fromMap(map);

    return;
  }
}
