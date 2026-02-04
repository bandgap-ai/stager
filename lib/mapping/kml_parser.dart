// Dart core
import 'dart:collection';

// External packages
import 'package:logger/logger.dart';
import 'package:xml/xml.dart';

// Project files
import '../tree/concrete_composite_node.dart';
import 'kml_parser_utils.dart';
import 'nodes/kml_tree_root_node.dart';
import 'style/kml_style.dart';
import 'style/kml_style_manager.dart';

/// Parses KML (Keyhole Markup Language) content into a Stager node tree following 
/// the redesigned composite hierarchy.
///
/// This parser is designed to be:
/// *   **Iterative**: It uses a stack-based approach for tree traversal to avoid 
///     recursion, adhering to project guidelines.
/// *   **Single-Pass**: It collects styles and builds the tree in a single 
///     traversal of the XML DOM.
/// *   **Robust**: It handles nested Documents, Folders, and multi-geometry 
///     Placemarks.
class KMLParser {
  /// Logger for capturing parsing errors and warnings.
  final Logger _logger = Logger();

  /// Manager for registering and resolving KML styles.
  final KMLStyleManager _styleManager = KMLStyleManager();

  /// Parses the given [xmlContent] string and returns the root of the node tree.
  ///
  /// This is the primary entry point for parsing. It first parses the raw 
  /// string into an [XmlDocument], then extracts shared styles, and finally 
  /// constructs the Stager node hierarchy.
  KMLTreeRootNode parse(String xmlContent) {
    late KMLTreeRootNode root;
    try {
      // Parse the raw XML string into a navigable DOM.
      final document = XmlDocument.parse(xmlContent);
      
      // Step 1: Register all shared <Style> elements.
      _registerStyles(document);

      // Step 2: Build the hierarchical Stager tree from the XML DOM.
      root = _buildTree(document);
    } catch (e) {
      _logger.e('Failed to parse KML content', error: e);
      rethrow;
    }
    return root;
  }

  /// Finds and registers all shared `<Style>` elements in the [document].
  void _registerStyles(XmlDocument document) {
    _styleManager.clear();

    final styles = document.findAllElements('Style');
    for (final styleElement in styles) {
      final id = styleElement.getAttribute('id') ?? '';
      if (id.isEmpty) continue;

      // Delegation: Components are parsed by KMLParserUtils.
      final kmlStyle = KMLStyle(
        id: id,
        lineStyle: KMLParserUtils.parseLineStyle(styleElement),
        polyStyle: KMLParserUtils.parsePolyStyle(styleElement),
        iconStyle: KMLParserUtils.parseIconStyle(styleElement),
      );

      _styleManager.registerStyle(kmlStyle);
    }
  }

  /// Constructs the Stager tree hierarchy from the [document] using a 
  /// non-recursive, stack-based traversal.
  KMLTreeRootNode _buildTree(XmlDocument document) {
    late KMLTreeRootNode treeRoot;

    // Find the logical root of the KML file.
    final kmlElement = document.getElement('kml');
    final rootContainer = kmlElement?.getElement('Document') ?? kmlElement;
    
    String rootId = 'root';
    String rootName = 'KML Document';
    String rootStyleUrl = 'default';
    
    if (rootContainer != null) {
        rootId = rootContainer.getAttribute('id') ?? rootId;
        rootName = rootContainer.getElement('name')?.innerText ?? rootName;
        rootStyleUrl = rootContainer.getElement('styleUrl')?.innerText ?? 'default';
    }

    // Instantiate the root of our Stager tree.
    treeRoot = KMLTreeRootNode(
      id: rootId,
      name: rootName,
      styleManager: _styleManager,
      styleUrl: rootStyleUrl,
    );

    // Stack for iterative traversal: (XmlElement currentXml, ConcreteCompositeNode parentNode)
    final stack = Queue<MapEntry<XmlElement, ConcreteCompositeNode>>();
    
    // Seed the stack.
    if (rootContainer != null) {
       stack.add(MapEntry(rootContainer, treeRoot));
    }

    // Iterate until the stack is empty.
    while (stack.isNotEmpty) {
      final entry = stack.removeLast();
      final currentXml = entry.key;
      final parentNode = entry.value;

      // Process all direct child elements.
      for (final child in currentXml.children) {
        if (child is! XmlElement) continue;

        final tagName = child.name.local;

        // Optimized Branch Order: Feature containers are processed first.
        if (tagName == 'Placemark') {
           // Refactored: Placemark is now a composite container for geometries.
           final placemarkNode = KMLParserUtils.createPlacemarkNode(child, _styleManager);
           parentNode.addChild(placemarkNode);
           
           // Delegate geometry extraction to the utils. 
           // Geometries are added as children to the placemarkNode.
           KMLParserUtils.parseGeometries(child, placemarkNode, _styleManager);

        } else if (tagName == 'Folder') {
           final folderNode = KMLParserUtils.createFolderNode(child, _styleManager);
           parentNode.addChild(folderNode);
           stack.add(MapEntry(child, folderNode));

        } else if (tagName == 'Document' && child != rootContainer) {
           // Handle nested Documents similarly to Folders.
           final docNode = KMLParserUtils.createDocumentNode(child, _styleManager);
           parentNode.addChild(docNode);
           stack.add(MapEntry(child, docNode));
        }
      }
    }

    return treeRoot;
  }
}
