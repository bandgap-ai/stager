/// Represents the visual style of a polygon's interior in a KML Placemark.
///
/// This class provides spec-compliant defaults for fill color and visibility.
class KMLPolyStyle {
  /// Hex color string in 'aabbggrr' format. Default is opaque white (ffffffff).
  final String color;

  /// Indicates whether to fill the polygon. Default is true.
  final bool fill;

  /// Indicates whether to outline the polygon boundary. Default is true.
  final bool outline;

  /// Creates a [KMLPolyStyle] with required or default values.
  const KMLPolyStyle({
    this.color = 'ffffffff',
    this.fill = true,
    this.outline = true,
  });

  @override
  String toString() {
    return 'KMLPolyStyle(color: $color, fill: $fill, outline: $outline)';
  }
}
