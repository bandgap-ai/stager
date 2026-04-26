import '../builders/basic_builder.dart';
import '../builders/stager_context.dart';
import '../data/stager_icon.dart';
import '../system/typed_value.dart';

/// A specialized builder for rehydrating [KMLIcon] instances.
@BasicBuilder(name: 'KMLIcon')
KMLIcon buildKMLIcon(StagerContext context) {
  // A specialized builder should ingest the specific properties of the 
  // object. For KMLIcon, that is the 'href' defined in its toMap() method.
  final hrefTyped = context.getOrDefault<String>(
      'href', '');
  
  return KMLIcon(href: hrefTyped);
}

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

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is KMLIcon && other.href == href);
  }

  @override
  int get hashCode => href.hashCode;

  /// Exports the icon state to a map structure for persistence.
  Map<String, Object> toMap() {
    return {
      'href': href,
    };
  }

  /// Rehydrates a [KMLIcon] from a reified map.
  static KMLIcon fromMap(Map<String, Object> inputMap) {
    return KMLIcon(href: inputMap['href']! as String);
  }
}
