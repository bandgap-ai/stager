/// The Stager Platform, a Flutter and Dart project for managing and "staging"
/// UI components in a library used by third-party applications.
library stager_platform;

// This file is the public entry point for the Stager Platform package.
// It should only contain `export` statements to expose the public API.

// Core data structures for the tree.
export 'tree/tree.dart';

// KML Integration
export 'mapping/kml_file.dart';
export 'mapping/kml_parser.dart';
export 'mapping/nodes/kml_tree_root_node.dart';
export 'mapping/nodes/kml_folder_node.dart';
export 'mapping/nodes/kml_placemark_node.dart';
export 'mapping/style/kml_style.dart';
export 'mapping/style/kml_style_manager.dart';

// Publicly available editor widgets.
export 'editors/location_editor.dart';
export 'editors/location_picker.dart';
export 'editors/standard_widgets.dart';

// Abstractions for data providers and their concrete implementations.
export 'providers/location_provider.dart';
export 'providers/geolocator_location_provider.dart';

// Public interfaces for persistence and file handling.
export 'editors/file_handler.dart';
