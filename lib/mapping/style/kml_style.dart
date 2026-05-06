import 'kml_icon_style.dart';
import 'kml_line_style.dart';
import 'kml_poly_style.dart';

/// A container class representing a complete KML Style.
///
/// This class uses composition to hold specialized style components for 
/// icons, lines, and polygons. It ensures that every style property has a 
/// valid, non-nullable default value according to the KML specification.
class KMLStyle {
  /// The unique identifier for this style.
  final String id;

  /// The style configuration for icons.
  final KMLIconStyle iconStyle;

  /// The style configuration for lines.
  final KMLLineStyle lineStyle;

  /// The style configuration for polygons.
  final KMLPolyStyle polyStyle;

  /// Creates a [KMLStyle]. 
  /// 
  /// If components are not provided, they default to their respective spec-
  /// compliant default instances.
  const KMLStyle({
    required this.id,
    this.iconStyle = const KMLIconStyle(),
    this.lineStyle = const KMLLineStyle(),
    this.polyStyle = const KMLPolyStyle(),
  });

  @override
  String toString() {
    return 'KMLStyle(id: $id, $iconStyle, $lineStyle, $polyStyle)';
  }
}
