/// Represents the visual style of a line (or boundary) in a KML Placemark.
///
/// This class provides spec-compliant defaults for line color and width.
class KMLLineStyle {
  /// Hex color string in 'aabbggrr' format. Default is opaque white (ffffffff).
  final String color;

  /// The width of the line in pixels. Default is 1.0.
  final double width;

  /// Creates a [KMLLineStyle] with required or default values.
  const KMLLineStyle({
    this.color = 'ffffffff',
    this.width = 1.0,
  });

  @override
  String toString() => 'KMLLineStyle(color: $color, width: $width)';
}
