import 'package:stager_platform/tree/tree.dart';
import 'package:stager_platform/editors/file_handler.dart';

class MockFileHandler implements FileHandler {
  bool exportCalled = false;
  bool importCalled = false;
  List<LeafNode>? nodesToImport;

  @override
  Future<void> export({
    required List<LeafNode> nodes,
    String? filePath,
    required Function() errorDialogCallback,
    required Function(String) notificationCallback,
    String? suggestedFileName,
  }) async {
    exportCalled = true;
  }

  @override
  Future<List<LeafNode>?> import({
    String? filePath,
    required Function(String) notificationCallback,
  }) async {
    importCalled = true;
    return nodesToImport;
  }

  @override
  Future<List<LeafNode>?> readFromFile(String path) {
    // TODO: implement readFromFile
    throw UnimplementedError();
  }

  @override
  Future<void> writeToFile(String path, List<LeafNode> nodes) {
    // TODO: implement writeToFile
    throw UnimplementedError();
  }
}