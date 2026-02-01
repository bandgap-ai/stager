import 'package:stager_platform/tree/concrete_leaf_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';
import 'package:stager_platform/mapping/style/kml_stylable.dart';

/// A [ConcreteLeafNode] specialized for representing KML Placemarks.
///
/// In the KML specification, a `<Placemark>` is a feature that represents a 
/// specific geographic object on the map. This class maps that concept to the 
/// Stager [LeafNode]. It typically contains geometry data (latitude, 
/// longitude, or an outline) and other descriptive metadata stored in its 
/// [properties]. Robust, non-nullable style resolution is provided via the 
/// [KMLStylable] mixin.
class KMLPlacemarkNode extends ConcreteLeafNode with KMLStylable {
  @override
  final KMLStyleManager styleManager;

  @override
  final String styleUrl;

  /// Creates a [KMLPlacemarkNode].
  ///
  /// [id]: A unique identifier for this node within the Stager tree.
  /// [name]: The display name of the placemark, typically from the KML `<name>` tag.
  /// [styleManager]: The registry where shared styles are stored.
  /// [styleUrl]: The ID of a shared style to apply. Defaults to 'default'.
  /// [initialProperties]: Optional map of initial metadata for the node.
  KMLPlacemarkNode({
    required super.id,
    required super.name,
    required this.styleManager,
    this.styleUrl = 'default',
    super.initialProperties,
  });
}
