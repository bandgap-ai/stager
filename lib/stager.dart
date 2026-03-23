/// The Stager Platform, a Flutter and Dart project for managing and "staging"
/// UI components in a library used by third-party applications.
library;

// This file is the public entry point for the Stager Platform package.
// It should only contain `export` statements to expose the public API.

// Core data structures for the tree
export 'tree/tree.dart';

// Publicly available editor widgets
export 'mapping/location_editor.dart';
export 'mapping/location_picker.dart';
export 'editors/standard_widgets.dart';

// Abstractions for data providers and their concrete implementations
export 'providers/location_provider.dart';
export 'providers/geolocator_location_provider.dart';

// Public interfaces for persistence and file handling
export 'editors/file_handler.dart';

// Geographic Data Models
export 'data/stager_icon.dart';
export 'mapping/lat_lon_box.dart';
export 'mapping/kml_hole.dart';
export 'mapping/kml_icon.dart';

// KML Mapping and GIS support
export 'mapping/kml_file.dart';
export 'mapping/kml_parser.dart';
export 'mapping/kml_parser_utils.dart';

// Specialized KML Nodes
export 'mapping/nodes/kml_feature_node.dart';
export 'mapping/nodes/kml_geometry_node.dart';
export 'mapping/nodes/kml_tree_root_node.dart';
export 'mapping/nodes/kml_document_node.dart';
export 'mapping/nodes/kml_folder_node.dart';
export 'mapping/nodes/kml_placemark_node.dart';
export 'mapping/nodes/kml_point_node.dart';
export 'mapping/nodes/kml_path_node.dart';
export 'mapping/nodes/kml_polygon_node.dart';
export 'mapping/nodes/kml_ground_overlay_node.dart';

// KML Style Subsystem
export 'mapping/style/kml_style.dart';
export 'mapping/style/kml_icon_style.dart';
export 'mapping/style/kml_line_style.dart';
export 'mapping/style/kml_poly_style.dart';
export 'mapping/style/kml_style_manager.dart';
export 'mapping/style/kml_stylable.dart';

// System components
export 'system/selection.dart';
export 'system/selection_observer.dart';
export 'system/selection_service.dart';
export 'system/selection_visitor.dart';
export 'system/selection_visitor_handler.dart';
export 'system/basic_selection_visitor_handler.dart';
export 'system/stager_system.dart';
export 'system/no_selection_exception.dart';
