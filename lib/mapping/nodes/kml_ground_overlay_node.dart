import '../../system/typed_value.dart';
import '../kml_icon.dart';
import '../lat_lon_box.dart';
import 'kml_geometry_node.dart';

/// A concrete [KMLGeometryNode] representing a KML GroundOverlay.
///
/// This class behaves like a Record, encapsulating a terminal geographic 
/// data node that anchors a fixed image (icon) to a specific geographic 
/// bounding box (LatLonBox) defined at instantiation.
class KMLGroundOverlayNode extends KMLGeometryNode {

  /// The icon (image) to be overlaid on the map.
  KMLIcon _icon;

  /// The geographic bounding box where the icon is rendered.
  LatLonBox _latLonBox;

  /// Creates a [KMLGroundOverlayNode] instance.
  ///
  /// [name]: The display name of the overlay.
  /// [styleManager]: The manager used to resolve shared styles.
  /// [icon]: The fixed image to be overlaid.
  /// [latLonBox]: The fixed geographic bounding box for the icon.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional initial metadata for the node.
  KMLGroundOverlayNode({
    required super.name,
    required super.styleManager,
    required KMLIcon icon,
    required LatLonBox latLonBox,
    super.styleUrl = 'default',
    super.initialProperties,
  }) : _icon = icon, _latLonBox = latLonBox;

  /// The icon (image) to be overlaid on the map.
  KMLIcon get icon => _icon;

  /// Sets the icon (image) to be overlaid on the map.
  set icon(KMLIcon value) {
    _icon = value;
    notify();
  }

  /// The geographic bounding box where the icon is rendered.
  LatLonBox get latLonBox => _latLonBox;

  /// Sets the geographic bounding box where the icon is rendered.
  set latLonBox(LatLonBox value) {
    _latLonBox = value;
    notify();
  }

  @override
  Map<String, Object> toMap() {
    // Start with the base node export.
    final map = super.toMap();

    // Harvest overlay-specific members and add them to the tagged record set.
    map.addAll({
      'kml_icon': _icon.toMap(),
      'kml_latlonbox': _latLonBox.toMap(),
    });

    return map;
  }

  @override
  void fromMap(Map<String, Object> inputMap) {
    // Create a mutable copy to pluck overlay attributes.
    final map = Map<String, TypedValue<Object>>.from(inputMap);

    // Rehydrate icon member.
    if (map.containsKey('kml_icon')) {
      _icon = KMLIcon.fromMap(map['kml_icon']!.value as Map<String, Object>);
      map.remove('kml_icon');
    }

    // Rehydrate latLonBox member.
    if (map.containsKey('kml_latlonbox')) {
      final boxData = map['kml_latlonbox']!.value as Map<String, Object>;
      _latLonBox = LatLonBox.fromMap(boxData.cast<String, TypedValue<Object>>());
      map.remove('kml_latlonbox');
    }

    // Delegate the remaining data to the base class.
    super.fromMap(map);
  }
}
