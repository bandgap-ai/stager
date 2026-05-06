import 'package:logger/logger.dart';
import 'kml_style.dart';

/// Manages the registration and resolution of KML styles.
///
/// In the KML specification, styles can be defined at the top of a document 
/// and referenced by multiple features throughout the tree. KML also permits 
/// "forward references," where a feature uses a style ID that is defined 
/// later in the same file.
///
/// This manager supports a robust, single-pass parsing strategy by:
/// 1. Acting as a central registry for all `<Style>` elements discovered 
///    during parsing.
/// 2. Enabling deferred resolution: Nodes (like [KMLPlacemarkNode]) store the 
///    style ID string and only query this manager for the actual [KMLStyle] 
///    object when it is needed for rendering or inspection.
class KMLStyleManager {
  /// Logger for capturing style resolution errors.
  final Logger _logger = Logger();

  /// Internal map of registered styles, keyed by their 'id' attribute.
  final Map<String, KMLStyle> _styles = {};

  /// Registers a [style] within the manager's registry.
  ///
  /// If a style with the same ID has already been registered, it will be 
  /// overwritten.
  ///
  /// [style]: The [KMLStyle] object to register.
  void registerStyle(KMLStyle style) {
    if (style.id.isNotEmpty) {
      _styles[style.id] = style;
    }
  }

  /// Checks if a style with the given [id] is registered in the manager.
  ///
  /// This method handles KML style references that start with the '#' 
  /// symbol (e.g., "#myStyle").
  ///
  /// [id]: The ID string of the style to check.
  ///
  /// Returns `true` if the style exists, `false` otherwise.
  bool contains(String id) {
    late bool result;
    // Adhering to the Single Return Principle.
    final cleanId = id.startsWith('#') ? id.substring(1) : id;
    result = _styles.containsKey(cleanId);
    return result;
  }

  /// Retrieves a registered [KMLStyle] by its [id].
  ///
  /// This method is typically called by nodes during lazy style resolution. 
  /// It automatically handles KML style references that start with the '#' 
  /// symbol (e.g., "#myStyle").
  ///
  /// [id]: The ID string of the style to look up.
  ///
  /// Returns the matching [KMLStyle].
  /// 
  /// Throws an [ArgumentError] if the style ID is not found in the registry.
  KMLStyle getStyle(String id) {
    late KMLStyle foundStyle;
    // Adhering to the Single Return Principle.
    final cleanId = id.startsWith('#') ? id.substring(1) : id;
    
    if (_styles.containsKey(cleanId)) {
      foundStyle = _styles[cleanId]!;
    } else {
      final message = 'KML Style not found: $id';
      _logger.e(message);
      throw ArgumentError(message);
    }
    
    return foundStyle;
  }

  /// Removes all registered styles from the manager.
  void clear() {
    _styles.clear();
  }

  /// Returns the current number of styles registered in the manager.
  int get limit => _styles.length;
}
