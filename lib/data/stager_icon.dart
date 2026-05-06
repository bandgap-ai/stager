/// An abstract base class for icons used in the Stager Platform.
///
/// This class provides a common interface for icons that can be stored
/// within [NodeProperties] and rendered by various UI components.
abstract class StagerIcon {
  /// The URL or local file path to the icon image.
  final String href;

  /// Creates a [StagerIcon] instance.
  ///
  /// [href]: The location of the icon asset.
  const StagerIcon({required this.href});

  @override
  String toString() => 'StagerIcon(href: $href)';
}
