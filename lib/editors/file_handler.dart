import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:stager/persistence/json_codec.dart';
import 'package:stager/tree/tree.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:stager/editors/message_dialog.dart';
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
    required BuildContext context,
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
    required BuildContext context,
  });

  Future<void> writeToFile(String path, List<LeafNode> nodes);

  Future<List<LeafNode>?> readFromFile(String path);
}

/// A basic implementation of [FileHandler] that uses the `file_picker` package
/// and a `JsonCodec` to handle file operations.
class BasicFileHandler implements FileHandler {
  final JsonCodec _codec = JsonCodec();

  @override
  Future<void> writeToFile(String path, List<LeafNode> nodes) async {
    final jsonString = _codec.serialize(nodes);
    final file = File(path);
    await file.writeAsString(jsonString);
  }

  /// Saves the given list of [nodes] to a file on the mobile platform...
  /// ... because they're so very particular.
  ///
  /// [nodes] is the list of nodes to save.
  /// [suggestedFileName] is the suggested name for the file.
  void _saveOnMobile(List<LeafNode> nodes, String? suggestedFileName,
      BuildContext context) async {
    // Make sure directory picking is supported.
    if (!await FlutterFileDialog.isPickDirectorySupported()) {
      final String msgTitle = "Error";
      final String errMsg = "Directory selection and exporting not available on "
          "this platform.";
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) {
            Widget dialog = MessageDialog(title: msgTitle, content: errMsg,);
            return dialog;
          },
        );
      }
      return;
    }
    // Get the directory and save and mobile.
    final pickedDirectory = await FlutterFileDialog.pickDirectory();
    if (pickedDirectory != null) {
      String filename = suggestedFileName ?? "tracee_export.json";
      final filePath = await FlutterFileDialog.saveFileToDirectory(
        directory: pickedDirectory,
        data: utf8.encode(_codec.serialize(nodes)),
        mimeType: "application/json",
        fileName: filename,
        replace: true,
      );
      String msg = "File saved to $filePath";
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
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
    required BuildContext context,
    String? suggestedFileName,
  }) async {
    try {
      // Android and iOS are very picky about writing files to external storage.
      // Thus, we need to figure out if we're on those platforms and use a
      // difference file picker if so.
      bool platformIsMobile = Platform.isAndroid || Platform.isIOS;
      if (platformIsMobile) {
        _saveOnMobile(nodes, suggestedFileName, context);
      } else {
        final String? outputFile = await _getExportFilePath(
          filePath,
          suggestedFileName,
        );

        if (outputFile != null) {
          await writeToFile(outputFile, nodes);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export complete!')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  @override
  Future<List<LeafNode>?> import({
    String? filePath,
    required BuildContext context,
  }) async {
    try {
      final String? path = await _getImportFilePath(filePath);

      if (path != null) {
        final importedNodes = await readFromFile(path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${importedNodes?.length ?? 0} nodes imported!')),
          );
        }
        return importedNodes;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
    return null;
  }

  Future<String?> _getImportFilePath(String? filePath) async {
    if (filePath != null) {
      return filePath;
    }
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    return result?.files.single.path;
  }

  @override
  Future<List<LeafNode>?> readFromFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      return _codec.deserialize(jsonString);
    }
    return null;
  }

}
