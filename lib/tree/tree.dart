/// This file contains the core data structures for the Stager tree.
/// It follows the Composite and Observer design patterns.
library;

// Core interfaces
export 'package:stager_platform/tree/node_properties_observer.dart';
export 'package:stager_platform/tree/leaf_node_observer.dart';
export 'package:stager_platform/tree/observable_subject.dart';
export 'package:stager_platform/tree/node_properties.dart';
export 'package:stager_platform/tree/leaf_node.dart';
export 'package:stager_platform/tree/composite_node.dart';
export 'package:stager_platform/tree/tree_node.dart';
export 'package:stager_platform/tree/data_node.dart';
export 'package:stager_platform/tree/data_properties.dart';

// Concrete implementations
export 'package:stager_platform/tree/concrete_node_properties.dart';
export 'package:stager_platform/tree/concrete_leaf_node.dart';
export 'package:stager_platform/tree/concrete_composite_node.dart';
export 'package:stager_platform/tree/concrete_tree_node.dart';
