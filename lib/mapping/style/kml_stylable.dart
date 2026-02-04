import 'kml_style.dart';
import 'kml_style_manager.dart';

/// A mixin that provides KML style resolution capabilities to Stager nodes.
///
/// This mixin centralizes both the storage and the logic for lazily resolving 
/// [KMLStyle] objects from a [KMLStyleManager]. It ensures that nodes 
/// always have access to a valid, non-nullable style, falling back to 
/// spec-compliant defaults when necessary.
mixin KMLStylable {
  /// The manager used to resolve shared styles. 
  /// 
  /// This must be initialized in the constructor body of the class using 
  /// this mixin.
  late final KMLStyleManager styleManager;

  /// The ID or URL of the style to apply to this node.
  /// 
  /// This must be initialized in the constructor body of the class using 
  /// this mixin.
  late final String styleUrl;

  /// Lazily resolves and returns the [KMLStyle] for this node.
  ///
  /// This getter adheres to the Single Return Principle. It first checks if 
  /// the requested style exists in the [styleManager]. If the [styleUrl] is 
  /// the reserved 'default' ID and no such style is registered, it returns 
  /// a default [KMLStyle] instance. Otherwise, it retrieves the style from 
  /// the manager, which will throw an exception if the ID is missing.
  ///
  /// Returns a non-nullable [KMLStyle].
  KMLStyle get kmlStyle {
    late KMLStyle resolved;

    // Adhering to the Single Return Principle and optimized branch order.
    // Check the manager first, as registered styles are the most likely path.
    if (styleManager.contains(styleUrl)) {
      resolved = styleManager.getStyle(styleUrl);
    } else if (styleUrl == 'default') {
      // Fallback to the KML specification's default values if 'default' 
      // is not explicitly overridden in the manager.
      resolved = const KMLStyle(id: 'default');
    } else {
      // This will trigger the manager's internal logging and exception logic
      // for missing styles.
      resolved = styleManager.getStyle(styleUrl);
    }

    return resolved;
  }
}
