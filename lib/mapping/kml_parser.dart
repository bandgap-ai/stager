// Dart core
import 'dart:collection';

// External packages
import 'package:logger/logger.dart';
import 'package:xml/xml.dart';

// Project files
import '../tree/tree.dart';
import 'kml_parser_utils.dart';
import 'nodes/kml_tree_root_node.dart';
import 'style/kml_style.dart';
import 'style/kml_style_manager.dart';

/// Parses KML (Keyhole Markup Language) content into a Stager node tree.
///
/// This parser is designed to be:
/// *   **Iterative**: It uses a stack-based approach for tree traversal to avoid 
///     recursion, preventing stack overflow on deep KML hierarchies and 
///     adhering to project guidelines.
/// *   **Single-Pass**: It efficiently collects styles and builds the tree in 
///     a single traversal of the XML DOM.
/// *   **Robust**: It handles missing or optional KML elements and correctly 
///     manages the KML-standard 'longitude, latitude' coordinate ordering.
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
  ///
  /// [xmlContent]: The raw XML string of the KML file.
  ///
  /// Returns a [KMLTreeRootNode] representing the root of the parsed tree.
  ///
  /// Throws [XmlException] if the string is not valid XML, or [FormatException] 
  /// if the KML structure is invalid.
  KMLTreeRootNode parse(String xmlContent) {
    late KMLTreeRootNode root;
    try {
      // Parse the raw XML string into a navigable DOM.
      final document = XmlDocument.parse(xmlContent);
      
      // Step 1: Register all shared <Style> elements found in the document.
      // This must happen before building the tree to support style references.
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
  ///
  /// [document]: The XML document to search for style definitions.
  void _registerStyles(XmlDocument document) {
    // Clear any existing styles from previous parses.
    _styleManager.clear();

    // Iterate through all <Style> tags in the document.
    final styles = document.findAllElements('Style');
    for (final styleElement in styles) {
      // KML styles must have an 'id' attribute to be shared.
      final id = styleElement.getAttribute('id') ?? '';
      if (id.isEmpty) continue;

      // Create the composite KMLStyle and register it.
      // Delegation: Individual components are parsed by KMLParserUtils.
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
  ///
  /// [document]: The XML document to parse into a tree.
  ///
  /// Returns the [KMLTreeRootNode] of the newly created tree.
  KMLTreeRootNode _buildTree(XmlDocument document) {
    late KMLTreeRootNode treeRoot;

    // Find the logical root of the KML file. It's usually a <Document> 
    // inside a <kml> tag, but we handle variations.
    final kmlElement = document.getElement('kml');
    XmlElement? rootContainer = kmlElement?.getElement('Document');
    
    String rootId = 'root';
    String rootName = 'KML Document';
    String rootStyleUrl = 'default';
    
    // If a <Document> is present, extract its metadata.
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

    // Use a queue as a stack for an iterative Depth-First Search (DFS) 
    // traversal of the XML tree.
    final stack = Queue<MapEntry<XmlElement, ConcreteCompositeNode>>();
    
    // Seed the stack with the top-level XML element and our tree root.
    if (rootContainer != null) {
       stack.add(MapEntry(rootContainer, treeRoot));
    } else if (kmlElement != null) {
       stack.add(MapEntry(kmlElement, treeRoot));
    }

    // Iterate until the stack is empty, processing one XML element at a time.
    while (stack.isNotEmpty) {
      final entry = stack.removeLast();
      final currentXml = entry.key;
      final parentNode = entry.value;

      // Process all direct child elements of the current XML tag.
      for (final child in currentXml.children) {
        if (child is! XmlElement) continue;

        final tagName = child.name.local;

        // Optimized Branch Order: Placemarks and Folders are the most common.
        if (tagName == 'Placemark') {
           // Delegation: KMLParserUtils handles placemark node creation.
           parentNode.addChild(KMLParserUtils.createPlacemarkNode(child, _styleManager));
        } else if (tagName == 'Folder' || tagName == 'Document') {
           // Delegation: KMLParserUtils handles folder node creation.
           final folderNode = KMLParserUtils.createFolderNode(child, _styleManager);
           parentNode.addChild(folderNode);
           stack.add(MapEntry(child, folderNode));
        }
      }
    }

    return treeRoot;
  }
}
