// Dart core
import 'dart:io';
import 'dart:typed_data';

// External packages
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

// Project files
import '../system/storage_provider.dart';

/// A [StorageProvider] implementation that stores assets on the local
/// filesystem.
///
/// This implementation uses [Directory] and [File] from `dart:io` to manage
/// assets within a specified base directory. It adheres to the project's
/// "no-null" and "single return" policies.
class LocalStorageProvider implements StorageProvider {
  /// Logger for recording storage operations.
  static final Logger _logger = Logger();

  /// The root directory where assets are managed.
  final String basePath;

  /// Creates a new [LocalStorageProvider] with the given [basePath].
  const LocalStorageProvider(this.basePath);

  @override
  Future<String> store(
    Uint8List data, {
    required String category,
    required String fileName,
    String mimeType = 'application/octet-stream',
  }) async {
    // Determine the directory and ensure it exists.
    final String directoryPath = p.join(basePath, category);
    final Directory directory = Directory(directoryPath);

    if (!await directory.exists()) {
      _logger.d('Creating directory: $directoryPath');
      await directory.create(recursive: true);
    }

    // Write the bytes to the file and return the absolute path.
    late final String resultPath;
    resultPath = p.join(directoryPath, fileName);
    final File file = File(resultPath);

    _logger.d('Storing file: $resultPath ($mimeType)');
    await file.writeAsBytes(data);

    return resultPath;
  }

  @override
  Future<Uint8List> get(String identifier) async {
    // Read the file bytes if the file exists, or return an empty list.
    late final Uint8List result;
    final File file = File(identifier);

    if (await file.exists()) {
      _logger.d('Reading file: $identifier');
      result = await file.readAsBytes();
    } else {
      _logger.w('File not found: $identifier');
      result = Uint8List(0);
    }

    return result;
  }

  @override
  Future<Stream<List<int>>> getStream(String identifier) async {
    // Open a read stream for the file, or return an empty stream.
    late final Stream<List<int>> result;
    final File file = File(identifier);

    if (await file.exists()) {
      _logger.d('Opening read stream for file: $identifier');
      result = file.openRead();
    } else {
      _logger.w('Stream source file not found: $identifier');
      result = const Stream.empty();
    }

    return result;
  }

  @override
  Future<bool> exists(String identifier) async {
    // Check if the file exists on the filesystem.
    late final bool result;
    result = await File(identifier).exists();
    return result;
  }

  @override
  Future<void> delete(String identifier) async {
    // Delete the file if it exists.
    final File file = File(identifier);
    if (await file.exists()) {
      _logger.d('Deleting file: $identifier');
      await file.delete();
    } else {
      _logger.w('Delete skipped: file not found at $identifier');
    }
  }

  @override
  Future<void> export(String identifier, String fileName) async {
    // Exporting is platform-dependent and often requires native dialogs.
    // This local implementation acts as a placeholder for higher-level services
    // that coordinate with platform-specific pickers.
    _logger.i('Export requested for $identifier as $fileName. '
        'Note: LocalStorageProvider export is a stub.');
    return;
  }

  @override
  String getUri(String identifier) {
    // Convert the local path into a file:// URI.
    late final String result;
    result = Uri.file(identifier).toString();
    return result;
  }
}
