import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/concrete_composite_node.dart';
import 'package:stager_platform/tree/concrete_leaf_node.dart';
import 'package:stager_platform/tree/leaf_node.dart';
import 'package:stager_platform/tree/node_builder.dart';

/// This is a mock node builder for testing the ability of Stager to create new
/// nodes using an injected builder. It adds some basic properties to the nodes
/// it creates to prove that the builder is working and not the default builder.
class MockNodeBuilder extends NodeBuilder {
  @override
  CompositeNode buildCompositeNode(String id, String name) {
    ConcreteCompositeNode node = ConcreteCompositeNode(id: id, name: name);
    node.properties.setProperty("isMock", true);
    return node;
  }

  @override
  LeafNode buildLeafNode(String id, String name) {
    ConcreteLeafNode node = ConcreteLeafNode(id: id, name: name);
    node.properties.setProperty("isMock", false);
    return node;
  }

}