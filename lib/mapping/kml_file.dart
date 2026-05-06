import 'dart:io';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:stager_platform_native_plugins/stager_platform_native_plugins.dart';
import '../system/stager_system.dart';
import 'kml_parser.dart';
import 'nodes/kml_tree_root_node.dart';

/// Exception thrown when KML validation fails.
class KMLValidationException implements Exception {
  /// A descriptive message explaining the validation failure.
  final String message;

  /// Creates a [KMLValidationException] with the given [message].
  KMLValidationException(this.message);

  @override
  String toString() => 'KMLValidationException: $message';
}

/// Represents a KML (Keyhole Markup Language) file and its associated
/// XML schema files. This class is responsible for:
///   * Externalizing the required XSD schema files from the Flutter asset 
///     bundle to a temporary directory that native code can access.
///   * Providing a method to validate the KML file against the copied schema 
///     via native plugins.
///   * Orchestrating the transformation of KML content into a Stager tree.
///
/// Usage example:
/// ```dart
/// final kml = KMLFile(kmlXMLLocation: '/path/to/file.kml');
/// await kml.prepareSchemas();     // Environment setup
/// final root = await kml.parse(); // Automatic validation and parsing
/// ```
class KMLFile {
  /// Logger for capturing validation and I/O errors.
  final Logger _logger = Logger();

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
  /// available and in existence until prepareSchemas() is called.
  /// Returns `true` once `prepareSchemas()` has successfully copied the schema
  /// files to the temporary directory.
  bool get schemaExists => _schemaExists;

  /// Creates a [KMLFile] instance for the given [kmlXMLLocation].
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

  /// Prepares the KML schema files by copying them from the app assets into 
  /// a temporary file system location accessible by native code.
  /// 
  /// This setup must be performed once before any validation can occur.
  Future<void> prepareSchemas() async {
    // Setup the temporary storage location.
    String sep = Platform.pathSeparator;
    tmpDirectory = StagerSystem.temporaryDirectory;
    
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

  /// Validates the XML file at [kmlXMLLocation] against the KML schema.
  ///
  /// Throws [KMLValidationException] if the file is invalid.
  /// Throws [StateError] if [prepareSchemas] has not been called first.
  Future<void> validate() async {
    // Optimized Branch Order: The most likely scenario is that the schema 
    // has already been prepared.
    if (_schemaExists) {
      String sep = Platform.pathSeparator;
      final result = await checkXMLFile(
        xsdPath: '${tmpDirectory.path}$sep$kmlXSD',
        xmlPath: kmlXMLLocation,
      );

      // checkXMLFile() is a native method (technically wrapped in dart) in the
      // stager_platform_native_plugins. 0 indicates success. Any other value
      // indicates a failure detected by the native plugin.
      if (result != 0) {
        final message = 'KML validation failed for file: $kmlXMLLocation';
        _logger.e(message);
        throw KMLValidationException(message);
      }
    } else {
      const message = 'KML schemas must be prepared via prepareSchemas() before validation.';
      _logger.e(message);
      throw StateError(message);
    }
  }

  /// Parses the KML file into a [KMLTreeRootNode].
  ///
  /// This method automatically calls [validate] before proceeding with the 
  /// transformation.
  ///
  /// Returns the root of the constructed Stager tree.
  ///
  /// Throws [FileSystemException] if the file is missing.
  /// Throws [KMLValidationException] if the file fails schema validation.
  /// Throws [FormatException] if the KML structure is logically invalid.
  Future<KMLTreeRootNode> parse() async {
    // Automatically validate before parsing. Throws an exception if it fails.
    await validate();

    final file = File(kmlXMLLocation);
    late KMLTreeRootNode root;

    // Prioritize the happy path where the file exists.
    if (file.existsSync()) {
      final content = await file.readAsString();
      final parser = KMLParser();
      root = parser.parse(content);
    } else {
      final message = 'KML file not found: $kmlXMLLocation';
      _logger.e(message);
      throw FileSystemException(message, kmlXMLLocation);
    }

    return root;
  }
}
