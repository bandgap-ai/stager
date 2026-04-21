import 'package:stager_platform/tree/basic_node_builder.dart';
import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/leaf_node.dart';

/// This is a mock node builder for testing the ability of Stager to create new
/// nodes using an injected builder. It adds some basic properties to the nodes
/// it creates to prove that the builder is working and not the default builder.
class MockNodeBuilder extends BasicNodeBuilder {
  @override
  CompositeNode buildCompositeNode(String id, String name, [CompositeNode? parent]) {
    CompositeNode node = super.buildCompositeNode(id, name, parent);
    node.properties.set("isMock", true);
    return node;
  }

  @override
  LeafNode buildLeafNode(String id, String name, [CompositeNode? parent]) {
    LeafNode node = super.buildLeafNode(id, name, parent);
    node.properties.set("isMock", false);
    return node;
  }

}