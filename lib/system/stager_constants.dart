import 'dart:io';

/// This class stores system used across Stager.
class StagerConstants {

  /// This is the root of the temporary data directory UNDER the cache/temp
  /// directory root of the OS. For example, if the OS sets the temp directory
  /// root as '/tmp', then the full temporary directory would be '/tmp/stager'.
  ///
  /// Clients need to add their own file separator by calling the
  /// Platform.separator function from dart:io.
  ///
  /// Clients looking for the full path to the temporary directory should see
  /// [temporaryDirectory] (below).
  static final String tmpDirectoryRoot = '${Platform.pathSeparator}stager';

  /// This function returns the temporary directory for storing Stager files.
  static Directory get temporaryDirectory => Directory(Directory.systemTemp.path
      + tmpDirectoryRoot);
}