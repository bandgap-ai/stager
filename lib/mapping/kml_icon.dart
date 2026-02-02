// Project files
import '../data/stager_icon.dart';

/// A specialized icon class for KML features.
///
/// This class represents the `<Icon>` element within a KML `<IconStyle>` or 
/// `<GroundOverlay>`, providing a strongly-typed way to manage geographic 
/// icon assets.
class KMLIcon extends StagerIcon {
  /// Creates a [KMLIcon] instance.
  ///
  /// [href]: The location of the KML icon asset.
  const KMLIcon({required super.href});

  @override
  String toString() => 'KMLIcon(href: $href)';
}
