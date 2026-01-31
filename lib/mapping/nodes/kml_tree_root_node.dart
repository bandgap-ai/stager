import 'package:stager_platform/tree/concrete_tree_node.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';
import 'package:stager_platform/mapping/style/kml_style.dart';

/// A [ConcreteTreeNode] specialized for representing the root of a KML document.
class KmlTreeRootNode extends ConcreteTreeNode {
  /// The manager for resolving styles referenced by this node.
  final KmlStyleManager styleManager;

  /// The raw style URL/ID referenced by this node, if any.
  final String? styleUrl;

  /// Creates a [KmlTreeRootNode].
  ///
  /// [id]: The unique identifier for the node.
  /// [name]: The display name of the node.
  /// [styleManager]: The manager used to resolve styles.
  /// [styleUrl]: Optional style ID referenced by this node.
  /// [initialProperties]: Optional initial properties.
  KmlTreeRootNode({
    required super.id,
    required super.name,
    required this.styleManager,
    this.styleUrl,
    super.initialProperties,
  });

  /// lazily resolves the [KmlStyle] from the [styleManager].
  KmlStyle? get kmlStyle {
    if (styleUrl != null) {
      return styleManager.getStyle(styleUrl!);
    }
    return null;
  }
}
