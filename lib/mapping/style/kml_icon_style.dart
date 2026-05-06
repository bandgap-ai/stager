/// Represents the visual style of an icon in a KML Placemark.
///
/// This class provides spec-compliant defaults for icon scaling and location.
class KMLIconStyle {
  /// The scale factor for the icon. Default is 1.0.
  final double scale;

  /// The URL or local path to the icon image. Default is an empty string.
  final String href;

  /// Creates a [KMLIconStyle] with required or default values.
  const KMLIconStyle({
    this.scale = 1.0,
    this.href = '',
  });

  @override
  String toString() => 'KMLIconStyle(scale: $scale, href: $href)';
}
