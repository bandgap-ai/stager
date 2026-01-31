/// A data class representing a KML Style.
///
/// This class encapsulates the style attributes defined in KML, such as
/// IconStyle, LineStyle, and PolyStyle. It serves as a strongly-typed
/// intermediate representation before mapping to Stager [NodeProperties].
class KmlStyle {
  /// The unique identifier for this style.
  final String id;

  /// Hex color string for lines (aabbggrr).
  final String? lineColor;

  /// Width of the line in pixels.
  final double? lineWidth;

  /// Hex color string for polygons (aabbggrr).
  final String? polyColor;

  /// Boolean indicating whether to fill the polygon.
  final bool? polyFill;

  /// Boolean indicating whether to outline the polygon.
  final bool? polyOutline;

  /// Scale of the icon.
  final double? iconScale;

  /// HTTP address or local path to the icon image.
  final String? iconHref;

  const KmlStyle({
    required this.id,
    this.lineColor,
    this.lineWidth,
    this.polyColor,
    this.polyFill,
    this.polyOutline,
    this.iconScale,
    this.iconHref,
  });

  @override
  String toString() {
    return 'KmlStyle(id: $id, lineColor: $lineColor, lineWidth: $lineWidth, '
        'polyColor: $polyColor, polyFill: $polyFill, polyOutline: $polyOutline, '
        'iconScale: $iconScale, iconHref: $iconHref)';
  }
}
