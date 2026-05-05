// Dart core
import 'dart:io';

// Project files
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

  /// Returns the current [StorageProvider].
  static StorageProvider get storage => _storage;

  /// Sets the [StorageProvider] to the provided [value].
  static set storage(StorageProvider value) => _storage = value;

  /// This returns the current instance of the selection service.
  SelectionService selectionService() => SelectionService();
}
