// Dart core
import 'dart:io';

// Project files
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../persistence/local_storage_provider.dart';
import 'selection_service.dart';
import 'storage_provider.dart';

/// This class stores system used across Stager.
class StagerSystem {
  /// The root of the temporary data directory UNDER the cache/temp
  /// directory root of the OS. For example, if the OS sets the temp directory
  /// root as '/tmp', then the full temporary directory would be '/tmp/stager'.
  ///
  /// Clients need to add their own file separator by calling the
  /// Platform.separator function from dart:io to the beginning AND the end of
  /// the path because this is a compile-time constant value.
  ///
  /// Clients looking for the full path to the temporary directory with proper
  /// OS path separators should see the [temporaryDirectory] method.
  static const String tmpDirectoryRoot = 'stager';

  /// The active storage provider for the Stager system. Adheres to the
  /// global storage abstraction goal in the storage provider design plan.
  static StorageProvider _storage =
      LocalStorageProvider(temporaryDirectory.path);

  /// Creates a new [StagerSystem].
  const StagerSystem();

  /// This function returns the temporary directory for storing Stager files.
  static Directory get temporaryDirectory =>
      Directory(Directory.systemTemp.path +
          Platform.pathSeparator +
          tmpDirectoryRoot);

  /// This returns the application's document directory.
  ///
  /// On Desktop, this appends the [tmpDirectoryRoot] to ensure
  /// isolation as per the Storage Provider Design Plan. Furthermore, unless the
  /// client app changes the Storage Provider, it will default to the local
  /// temporary storage directory (i.e., /tmp on Linux).
  static Future<Directory> get documentsDirectory async {
    final Directory base = await getApplicationDocumentsDirectory();
    late final Directory result;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      result = Directory(path.join(base.path, tmpDirectoryRoot));
    } else {
      result = base;
    }

    return result;
  }

  /// Returns the current [StorageProvider].
  static StorageProvider get storage => _storage;

  /// Sets the [StorageProvider] to the provided [value].
  static set storage(StorageProvider value) => _storage = value;

  /// This returns the current instance of the selection service.
  SelectionService selectionService() => SelectionService();
}
