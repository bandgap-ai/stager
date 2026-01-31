import 'kml_style.dart';

/// Manages KML styles for a document.
///
/// This class is responsible for registering styles found during parsing and
/// resolving style references (IDs). It enables a single-pass parse strategies
/// where style definitions might technically appear after their usage, by allowing
/// resolution to happen lazily or by collecting all styles if a pre-scan is used.
///
/// In the current iterative parser implementation, logical "forward references"
/// are handled by looking up the style from this manager only when the property
/// is actually requested/accessed by the node, rather than at node construction time.
class KmlStyleManager {
  final Map<String, KmlStyle> _styles = {};

  /// Registers a [style] with the manager.
  ///
  /// If a style with the same ID already exists, it is overwritten.
  void registerStyle(KmlStyle style) {
    if (style.id.isNotEmpty) {
      _styles[style.id] = style;
    }
  }

  /// Retrieves a style by its [id].
  ///
  /// Returns `null` if no style with the given [id] is found.
  /// The [id] should typically start with `#` for internal references,
  /// but this method expects the raw ID (or handles normalized IDs depending on usage).
  /// For simplicity, if the lookup ID starts with `#`, it is stripped.
  KmlStyle? getStyle(String id) {
    final cleanId = id.startsWith('#') ? id.substring(1) : id;
    return _styles[cleanId];
  }

  /// Clears all registered styles.
  void clear() {
    _styles.clear();
  }

  /// Returns the number of registered styles.
  int get limit => _styles.length;
}
