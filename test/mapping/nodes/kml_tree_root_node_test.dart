import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/nodes/kml_tree_root_node.dart';
import 'package:stager_platform/mapping/style/kml_style.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

void main() {
  group('KMLTreeRootNode', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('Constructor correctly initializes with default styleUrl', () {
      final root = KMLTreeRootNode(
        id: 'root1',
        name: 'KML Document',
        styleManager: manager,
      );

      expect(root.properties.getProperty('id'), 'root1');
      expect(root.properties.getProperty('name'), 'KML Document');
      expect(root.styleUrl, 'default');
      expect(root.kmlStyle.id, 'default');
    });

    test('Resolves registered style from manager', () {
      const style = KMLStyle(id: 'rootStyle');
      manager.registerStyle(style);

      final root = KMLTreeRootNode(
        id: 'root2',
        name: 'Styled Root',
        styleManager: manager,
        styleUrl: 'rootStyle',
      );

      expect(root.kmlStyle, equals(style));
    });

    test('Inherits traversal capabilities from ConcreteTreeNode', () {
      final root = KMLTreeRootNode(
        id: 'root3',
        name: 'Traversable Root',
        styleManager: manager,
      );

      // Verify it provides iterators
      expect(root.depthFirstIterator, isNotNull);
      expect(root.breadthFirstIterator, isNotNull);
    });

    test('Throws ArgumentError for missing non-default style', () {
      final root = KMLTreeRootNode(
        id: 'root4',
        name: 'Invalid Style Root',
        styleManager: manager,
        styleUrl: 'bad-style',
      );

      expect(() => root.kmlStyle, throwsArgumentError);
    });
  });
}
