import 'dart:io';
import 'package:flutter/services.dart';
import 'package:stager_platform_native_plugins/stager_platform_native_plugins.dart';
import '../system/stager_constants.dart';
import 'kml_parser.dart';
import 'nodes/kml_tree_root_node.dart';

/// Represents a KML (Keyhole Markup Language) file and its associated
/// XML schema files. This class is responsible for:
///   * Copying the required XSD schema files from the Flutter asset bundle
///     to a temporary directory that native code can access.
///   * Providing a method to validate the KML file against the copied schema
///     via the native `checkXMLFile` plugin.
///
/// Usage example:
/// ```dart
/// final kml = KMLFile(kmlXMLLocation: '/path/to/file.kml');
/// await kml.load();               // Copies schemas to a temp dir
/// final result = await kml.validate(); // 0 == valid
/// ```
class KMLFile {
  /// Relative path within the Flutter asset bundle where the KML XSD schema
  /// files are stored.
  final String kmlXSDRoot = 'assets/schemas/kml/2.2.0';

  /// XSD file defining the Atom author link schema.
  final String atomAuthorLinkXSD = 'atom-author-link.xsd';

  /// XSD file for the core KML schema.
  final String kmlXSD = 'ogckml22.xsd';

  /// XSD file for the XAL (eXtensible Address Language) schema.
  final String xALXSD = 'xAL.xsd';

  /// Temporary directory where the XSD schema files are copied so that the native
  /// plugin can read them.
  late Directory tmpDirectory;

  /// Absolute or relative file system path to the KML file that will be
  /// validated.
  final String kmlXMLLocation;

  late bool _schemaExists;

  /// Checks if the schema file exists. Note that the schema isn't considered
  /// available and in existence until load() is called.
  /// Returns `true` once `load()` has successfully copied the schema
  /// files to the temporary directory.
  bool get schemaExists => _schemaExists;

  KMLFile({required this.kmlXMLLocation}) : _schemaExists = false;

  /// Copies a single XSD asset file from the Flutter bundle to the temporary
  /// directory.
  ///
  /// * [path] – The asset bundle path (including the `kmlXSDRoot` prefix).
  /// * [newName] – The filename to use when writing the temporary file.
  Future<void> _copyToTmp(String path, String newName) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();
    String sep = Platform.pathSeparator;
    final File tmpFile = File('${tmpDirectory.path}$sep$newName');
    await tmpFile.writeAsBytes(bytes, flush: true);
  }

  /// This function loads the KML file and its schema.
  /// Copies all required XSD schema files from the Flutter asset bundle
  /// into a temporary directory. After calling this method the `schemaExists`
  /// getter will return `true`.
  Future<void> load() async {
    // Setup the temporary storage location.
    String sep = Platform.pathSeparator;
    tmpDirectory = StagerConstants.temporaryDirectory;
    
    // Ensure the directory exists asynchronously.
    await tmpDirectory.create(recursive: true);
    
    // Copy the schema files in parallel and await their completion.
    // This prevents a race condition in validate().
    await Future.wait([
      _copyToTmp('$kmlXSDRoot$sep$atomAuthorLinkXSD', atomAuthorLinkXSD),
      _copyToTmp('$kmlXSDRoot$sep$xALXSD', xALXSD),
      _copyToTmp('$kmlXSDRoot$sep$kmlXSD', kmlXSD),
    ]);

    // Mark the schema as existing since it has been externalized.
    _schemaExists = true;
  }

  /// This function validates an XML file against the KML schema.
  ///
  /// Returns 0 if the file is valid, non-zero otherwise.
  Future<int> validate() async {
    if (!_schemaExists) {
      throw StateError('KML schemas must be loaded via load() before validation.');
    }
    
    String sep = Platform.pathSeparator;
    return checkXMLFile(
      xsdPath: '${tmpDirectory.path}$sep$kmlXSD',
      xmlPath: kmlXMLLocation,
    );
    // TODO: Add Dart-side enum to native plugins for error results.
  }

  /// Parses the KML file into a [KMLTreeRootNode].
  ///
  /// Throws an exception if the file cannot be read or parsed.
  Future<KMLTreeRootNode> parse() async {
    final file = File(kmlXMLLocation);
    if (!file.existsSync()) {
      throw FileSystemException('KML file not found', kmlXMLLocation);
    }
    final content = await file.readAsString();
    final parser = KMLParser();
    return parser.parse(content);
  }
}
