import 'package:stager_platform/system/typed_value.dart';
import 'package:stager_platform/tree/basic_node_builder.dart';
import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/leaf_node.dart';
import 'package:stager_platform/tree/null_nodes.dart';

/// This is a mock node builder for testing the ability of Stager to create new
/// nodes using an injected builder. It adds some basic properties to the nodes
/// it creates to prove that the builder is working and not the default builder.
class MockNodeBuilder extends BasicNodeBuilder {
  @override
  CompositeNode buildCompositeNode(String name, [CompositeNode parent = const NullComposite()]) {
    CompositeNode node = super.buildCompositeNode(name, parent);
    node.properties.set<bool>("isMock", true);
    return node;
  }

  @override
  LeafNode buildLeafNode(String name, [CompositeNode parent = const NullComposite()]) {
    LeafNode node = super.buildLeafNode(name, parent);
    node.properties.set<bool>("isMock", false);
    return node;
  }

}