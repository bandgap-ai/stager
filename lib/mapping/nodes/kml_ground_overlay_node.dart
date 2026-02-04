// Project files
import '../kml_icon.dart';
import '../lat_lon_box.dart';
import '../style/kml_stylable.dart';
import '../style/kml_style_manager.dart';
import 'kml_geometry_node.dart';

/// A concrete [KMLGeometryNode] representing a KML GroundOverlay.
///
/// This class represents a terminal data node that anchors an image (icon) 
/// to a specific geographic bounding box (LatLonBox). Although a Feature 
/// in the KML specification, it is modeled here as a geometry node to 
/// emphasize its status as a leaf within the Stager tree. It leverages the 
/// [KMLStylable] mixin to support visual style attributes.
class KMLGroundOverlayNode extends KMLGeometryNode with KMLStylable {
  /// Internal key for storing the icon property.
  static const String iconKey = 'kml_icon';

  /// Internal key for storing the LatLonBox property.
  static const String latLonBoxKey = 'kml_latlonbox';

  /// Creates a [KMLGroundOverlayNode] instance.
  ///
  /// [id]: The unique identifier for the node.
  /// [name]: The display name of the overlay.
  /// [styleManager]: The manager used to resolve shared styles.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional initial metadata.
  KMLGroundOverlayNode({
    required super.id,
    required super.name,
    required super.styleManager,
    super.styleUrl = 'default',
    super.initialProperties,
  });

  /// The icon (image) to be overlaid on the map.
  KMLIcon? get icon {
    return properties.getProperty(iconKey) as KMLIcon?;
  }

  set icon(KMLIcon? value) {
    properties.setProperty(iconKey, value);
  }

  /// The geographic bounding box where the icon is rendered.
  LatLonBox? get latLonBox {
    return properties.getProperty(latLonBoxKey) as LatLonBox?;
  }

  set latLonBox(LatLonBox? value) {
    properties.setProperty(latLonBoxKey, value);
  }
}
