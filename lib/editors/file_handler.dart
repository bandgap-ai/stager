import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:stager_platform/persistence/json_io_util.dart';
import 'package:stager_platform/tree/tree.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'dart:convert';

/// An abstract interface for handling file import and export operations.
///
/// This interface decouples the UI from the concrete implementation of file
/// persistence, allowing for easier testing and maintenance.
abstract class FileHandler {
  /// Exports the given list of [nodes] to a file.
  ///
  /// If [filePath] is provided, the file picker is skipped and the data is
  /// saved directly to that path. This is useful for testing.
  /// If [filePath] is null, the native file picker is shown to the user,
  /// using [suggestedFileName] as the default.
  /// The [context] is required to show `SnackBar` notifications.
  Future<void> export({
    required List<LeafNode> nodes,
    String? filePath,
    required Function() errorDialogCallback,
    required Function(String) notificationCallback,
    String? suggestedFileName,
  });

  /// Imports a list of [LeafNode]s from a file.
  ///
  /// If [filePath] is provided, the file picker is skipped and the data is
  /// loaded directly from that path. This is useful for testing.
  /// If [filePath] is null, the native file picker is shown to the user.
  /// The [context] is required to show `SnackBar` notifications.
  Future<List<LeafNode>?> import({
    String? filePath,
    required Function(String) notificationCallback,
  });

  /// Direct-write utility function.
  Future<void> writeToFile(String path, List<LeafNode> nodes);

  /// Direct-read utility function.
  Future<List<LeafNode>?> readFromFile(String path);
}

/// A basic implementation of [FileHandler] that uses the `file_picker` package
/// and a `JsonCodec` to handle file operations.
class BasicFileHandler implements FileHandler {
  final JsonIOUtil _jsonIOUtil = const JsonIOUtil();

  const BasicFileHandler();

  @override
  Future<void> writeToFile(String path, List<LeafNode> nodes) async {
    final jsonString = _jsonIOUtil.serialize(nodes);
    final file = File(path);
    await file.writeAsString(jsonString);
  }

  /// Saves the given list of [nodes] to a file on the mobile platform...
  /// ... because they're so very particular.
  ///
  /// [nodes] is the list of nodes to save.
  /// [suggestedFileName] is the suggested name for the file.
  void _saveOnMobile(List<LeafNode> nodes, String? suggestedFileName,
      void Function() onErrFunc,
      Function(String) notificationCallback,) async {
    // Make sure directory picking is supported.
    if (!await FlutterFileDialog.isPickDirectorySupported()) {
      onErrFunc();
    }
    // Get the directory and save and mobile.
    final pickedDirectory = await FlutterFileDialog.pickDirectory();
    if (pickedDirectory != null) {
      String filename = suggestedFileName ?? "tracee_export.json";
      final filePath = await FlutterFileDialog.saveFileToDirectory(
        directory: pickedDirectory,
        data: utf8.encode(_jsonIOUtil.serialize(nodes)),
        mimeType: "application/json",
        fileName: filename,
        replace: true,
      );
      String msg = "File saved to $filePath";
      notificationCallback(msg);
    }
    return;
  }

  /// Return a file path picked by the user with FilePicker to which the file
  /// should be saved.
  ///
  /// [filePath] is the path to the file to save to.
  /// [suggestedFileName] is the suggested name for the file.
  Future<String?> _getExportFilePath(
      String? filePath,
      String? suggestedFileName,
      ) async {

    // Apparently Gemini couldn't think of a better way to do this. Leaving for
    // now, but FIXME later.
    if (filePath != null) {
      return filePath;
    }

    // We're on a desktop platform, so we can use FilePicker.
    return await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: suggestedFileName,
    );
  }

  @override
  Future<void> export({
    required List<LeafNode> nodes,
    String? filePath,
    required Function() errorDialogCallback,
    required Function(String) notificationCallback,
    String? suggestedFileName,
  }) async {
    try {
      // Android and iOS are very picky about writing files to external storage.
      // Thus, we need to figure out if we're on those platforms and use a
      // difference file picker if so.
      bool platformIsMobile = Platform.isAndroid || Platform.isIOS;
      if (platformIsMobile) {
        _saveOnMobile(nodes, suggestedFileName, errorDialogCallback,
            notificationCallback);
      } else {
        final String? outputFile = await _getExportFilePath(
          filePath,
          suggestedFileName,
        );

        if (outputFile != null) {
          await writeToFile(outputFile, nodes);
          notificationCallback('Export complete!');
        }
      }
    } catch (e) {
        notificationCallback('Export failed: $e');
    }
  }

  @override
  Future<List<LeafNode>?> import({
    String? filePath,
    required Function(String) notificationCallback,
  }) async {
    try {
      final String? path = await _getImportFilePath(filePath);

      if (path != null) {
        final importedNodes = await readFromFile(path);
        notificationCallback('${importedNodes?.length ?? 0} nodes imported!');
        return importedNodes;
      }
    } catch (e) {
      notificationCallback('Import failed: $e');
    }
    return null;
  }

  Future<String?> _getImportFilePath(String? filePath) async {
    if (filePath != null) {
      return filePath;
    }
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      dialogTitle: 'Select a file:',
      allowedExtensions: ['json'],
    );
    return result?.files.single.path;
  }

  @override
  Future<List<LeafNode>?> readFromFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      return _jsonIOUtil.deserialize(jsonString);
    }
    return null;
  }

}
