import 'package:flutter_test/flutter_test.dart';
import 'package:stager_platform/mapping/nodes/kml_folder_node.dart';
import 'package:stager_platform/mapping/style/kml_style.dart';
import 'package:stager_platform/mapping/style/kml_style_manager.dart';

void main() {
  group('KmlFolderNode Tests', () {
    test('Resolves style from manager', () {
      final manager = KmlStyleManager();
      const style = KmlStyle(id: 'folderStyle', iconScale: 2.0);
      manager.registerStyle(style);

      final folder = KmlFolderNode(
        id: '1',
        name: 'Test Folder',
        styleManager: manager,
        styleUrl: '#folderStyle',
      );

      expect(folder.kmlStyle, equals(style));
    });

    test('Returns null for missing style', () {
      final manager = KmlStyleManager();
      final folder = KmlFolderNode(
        id: '1',
        name: 'Test Folder',
        styleManager: manager,
        styleUrl: '#missing',
      );

      expect(folder.kmlStyle, isNull);
    });
  });
}
