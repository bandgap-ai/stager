import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/nodes/kml_folder_node.dart';
import 'package:stager_platform/mapping/style/kml_style.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

void main() {
  group('KMLFolderNode', () {
    late KMLStyleManager manager;

    setUp(() {
      manager = KMLStyleManager();
    });

    test('Constructor correctly initializes with default styleUrl', () {
      final folder = KMLFolderNode(
        id: 'f1',
        name: 'Default Folder',
        styleManager: manager,
      );

      expect(folder.styleUrl, 'default');
      // Mixin should return a default KMLStyle when ID is 'default' 
      // and not in manager.
      expect(folder.kmlStyle.id, 'default');
    });

    test('Resolves registered style from manager', () {
      const style = KMLStyle(id: 'folderStyle');
      manager.registerStyle(style);

      final folder = KMLFolderNode(
        id: 'f2',
        name: 'Styled Folder',
        styleManager: manager,
        styleUrl: '#folderStyle',
      );

      expect(folder.kmlStyle, equals(style));
    });

    test('Throws ArgumentError for missing non-default style', () {
      final folder = KMLFolderNode(
        id: 'f3',
        name: 'Missing Style Folder',
        styleManager: manager,
        styleUrl: 'missing-id',
      );

      // The mixin delegates to the manager, which throws on missing IDs.
      expect(() => folder.kmlStyle, throwsArgumentError);
    });

    test('Handles styleUrl starting with #', () {
      const style = KMLStyle(id: 'hashStyle');
      manager.registerStyle(style);

      final folder = KMLFolderNode(
        id: 'f4',
        name: 'Hash Style Folder',
        styleManager: manager,
        styleUrl: '#hashStyle',
      );

      expect(folder.kmlStyle.id, 'hashStyle');
    });
  });
}
