import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import '../../system/basic_selection_visitor_handler.dart';
import '../../system/selection_visitor.dart';
import '../../tree/concrete_composite_node.dart';
import '../../tree/concrete_leaf_node.dart';
import '../../tree/concrete_tree_node.dart';
import '../../tree/node_properties.dart';
import '../../system/callable_selection_visitor.dart';

class MapSelectionVisitorHandler extends BasicSelectionVisitorHandler {
  final Logger _mappableNodeLogger = Logger();
  LatLng location = LatLng(0.0, 0.0);

  // Private function for mapping a basic node to a LatLng location.
  void _getNodeLocation(NodeProperties props) {

    // Check that the latitude and longitude properties are set
    if (props.getProperty("latitude") != null &&
        props.getProperty("longitude") != null) {
      location = LatLng(
        // This is not a nice way to get the position. Need to update those classes.
        props.getProperty("latitude")! as double,
        props.getProperty("longitude")! as double,
      );
    } else {
      // If not, complain and bounce the location to the middle of the ocean.
      location = LatLng(0.0, 0.0);
      final String msg =
          "Unable to get location from node properties. The node "
          "has been mapped to LatLng(0.0,0.0). Have fun swimming in the ocean.";
      _mappableNodeLogger.w(msg);
    }
  }

  // Private function to get the position of a leaf node
  void _getLeafNodeLocation(ConcreteLeafNode node) {
    _getNodeLocation(node.properties);
  }

  // Private function to get the position of a composite node
  void _getCompositeNodeLocation(ConcreteCompositeNode node) {
    _getNodeLocation(node.properties);
  }

  // Private function to get the position of a tree node
  void _getTreeNodeLocation(ConcreteTreeNode node) {
    _getNodeLocation(node.properties);
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
      ConcreteLeafNode(id: '', name: ''),
      _getLeafNodeLocation,
    );

    /// Visitor for basic composite nodes
    compositeNodeVisitor = CallableSelectionVisitor(
      ConcreteCompositeNode(id: '', name: ''),
      _getCompositeNodeLocation,
    );

    /// Visitor for basic tree nodes
    treeNodeVisitor = CallableSelectionVisitor(
      ConcreteTreeNode(id: '', name: ''),
      _getTreeNodeLocation,
    );

    /// Register all the visitors
    register(ConcreteLeafNode, leafNodeVisitor);
    register(ConcreteCompositeNode, compositeNodeVisitor);
    register(ConcreteTreeNode, treeNodeVisitor);
  }
}
