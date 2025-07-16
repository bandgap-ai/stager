import 'package:file_picker/file_picker.dart';

/// A wrapper around the [FilePicker] to make it easier to mock in tests.
class FilePickerWrapper {
  /// Opens the file picker to save a file.
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
  }) async {
    return await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
    );
  }

  /// Opens the file picker to pick files.
  Future<FilePickerResult?> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    return await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
    );
  }
}
