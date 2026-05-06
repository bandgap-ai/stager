import 'package:logger/logger.dart';
import '../../system/basic_selection_visitor_handler.dart';
import '../../system/point.dart';
import '../../tree/concrete_composite_node.dart';
import '../../tree/concrete_leaf_node.dart';
import '../../tree/concrete_tree_node.dart';
import '../../tree/leaf_node.dart';
import '../../tree/node_properties.dart';
import '../../system/callable_selection_visitor.dart';

class MapSelectionVisitorHandler extends BasicSelectionVisitorHandler {
  final Logger _mappableNodeLogger = Logger();
  Point location = Point();

  // Private function for mapping a basic node to a Point location.
  void _getNodeLocation(LeafNode node) {
    location = node.position;
  }

  // Private function to get the position of a leaf node
  void _getLeafNodeLocation(ConcreteLeafNode node) {
    _getNodeLocation(node);
  }

  // Private function to get the position of a composite node
  void _getCompositeNodeLocation(ConcreteCompositeNode node) {
    _getNodeLocation(node);
  }

  // Private function to get the position of a tree node
  void _getTreeNodeLocation(ConcreteTreeNode node) {
    _getNodeLocation(node);
  }

  /// Visitor for basic leaf nodes
  late CallableSelectionVisitor<ConcreteLeafNode> leafNodeVisitor;

  /// Visitor for basic composite nodes
  late CallableSelectionVisitor<ConcreteCompositeNode>
  compositeNodeVisitor;

  /// Visitor for basic tree nodes
  late CallableSelectionVisitor<ConcreteTreeNode> treeNodeVisitor;

  MapSelectionVisitorHandler() {
    /// Visitor for basic leaf nodes
    leafNodeVisitor = CallableSelectionVisitor(
      ConcreteLeafNode(name: ''),
      _getLeafNodeLocation,
    );

    /// Visitor for basic composite nodes
    compositeNodeVisitor = CallableSelectionVisitor(
      ConcreteCompositeNode(name: ''),
      _getCompositeNodeLocation,
    );

    /// Visitor for basic tree nodes
    treeNodeVisitor = CallableSelectionVisitor(
      ConcreteTreeNode(name: ''),
      _getTreeNodeLocation,
    );

    /// Register all the visitors
    register(ConcreteLeafNode, leafNodeVisitor);
    register(ConcreteCompositeNode, compositeNodeVisitor);
    register(ConcreteTreeNode, treeNodeVisitor);
  }
}
