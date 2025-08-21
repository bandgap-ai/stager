import 'package:stager_platform/tree/basic_node_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/leaf_node.dart';

void main() {
  group('Basic Node Builder', () {

    BasicNodeBuilder builder = BasicNodeBuilder();

    test('Build a leaf node', () {
      // Create a leaf node
      String id = "1";
      String name = "One";
      LeafNode node = builder.buildLeafNode(id, name);
      expect(node.properties.getProperty('id'), id);
      expect(node.properties.getProperty('name'), name);
      expect(node.isComposite,isFalse);
    });

    test('Build a composite node', () {
      // Create a leaf node
      String id = "2";
      String name = "Two";
      CompositeNode node = builder.buildCompositeNode(id, name);
      expect(node.properties.getProperty('id'), id);
      expect(node.properties.getProperty('name'), name);
      expect(node.isComposite,isTrue);
    });
  });
}
