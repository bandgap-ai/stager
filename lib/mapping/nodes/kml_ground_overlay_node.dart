import '../kml_icon.dart';
import '../lat_lon_box.dart';
import 'kml_geometry_node.dart';

/// A concrete [KMLGeometryNode] representing a KML GroundOverlay.
///
/// This class behaves like a Record, encapsulating a terminal geographic 
/// data node that anchors a fixed image (icon) to a specific geographic 
/// bounding box (LatLonBox) defined at instantiation.
/// 
/// Once created, the icon and bounding box cannot be modified.
class KMLGroundOverlayNode extends KMLGeometryNode {
  /// Internal key for storing the icon property.
  static const String iconKey = 'kml_icon';

  /// Internal key for storing the LatLonBox property.
  static const String latLonBoxKey = 'kml_latlonbox';

  /// Creates a [KMLGroundOverlayNode] instance.
  ///
  /// [id]: The unique identifier for the node.
  /// [name]: The display name of the overlay.
  /// [styleManager]: The manager used to resolve shared styles.
  /// [icon]: The fixed image to be overlaid.
  /// [latLonBox]: The fixed geographic bounding box for the icon.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional initial metadata for the node.
  KMLGroundOverlayNode({
    required super.id,
    required super.name,
    required super.styleManager,
    required KMLIcon icon,
    required LatLonBox latLonBox,
    super.styleUrl = 'default',
    super.initialProperties,
  }) {
    // Storing the provided overlay data directly in the property map.
    properties.setProperty(iconKey, icon);
    properties.setProperty(latLonBoxKey, latLonBox);
  }

  /// The icon (image) to be overlaid on the map.
  /// 
  /// Returns a non-nullable [KMLIcon].
  /// 
  /// Throws a [StateError] if [hasIcon] is false.
  KMLIcon get icon {
    return properties.getProperty(iconKey) as KMLIcon;
  }

  /// The geographic bounding box where the icon is rendered.
  /// 
  /// Returns a non-nullable [LatLonBox].
  /// 
  /// Throws a [StateError] if [hasLatLonBox] is false.
  LatLonBox get latLonBox {
    return properties.getProperty(latLonBoxKey) as LatLonBox;
  }
}
