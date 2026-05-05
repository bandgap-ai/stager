// Dart core
import 'dart:typed_data';

/// An abstract interface for handling binary and text-based storage operations.
///
/// This interface allows the platform to decouple metadata management from the
/// physical storage of auxiliary assets (images, audio, CSV, KML, etc.).
/// Implementations can target local filesystems, cloud storage (S3), or
/// database blobs.
abstract class StorageProvider {
  /// Stores data and returns a unique storage identifier (path).
  ///
  /// [data] is the raw content as bytes. For text-based formats like CSV or
  /// plain text, the caller is responsible for encoding (e.g., utf8.encode).
  /// [category] is a logical grouping (e.g., 'photos', 'reports', 'raw_data').
  /// [fileName] is the suggested name for the file.
  /// [mimeType] provides a hint to the storage backend (e.g., 'text/csv' or
  /// 'image/jpeg').
  Future<String> store(
    Uint8List data, {
    required String category,
    required String fileName,
    String mimeType = 'application/octet-stream',
  });

  /// Retrieves the raw bytes for the given [identifier].
  ///
  /// [identifier] is the unique storage identifier returned by [store].
  Future<Uint8List> get(String identifier);

  /// Opens a stream for reading the given [identifier].
  ///
  /// Recommended for large assets (audio/video/large CSVs) to avoid memory
  /// issues.
  /// [identifier] is the unique storage identifier returned by [store].
  Future<Stream<List<int>>> getStream(String identifier);

  /// Checks if an asset exists for the given [identifier].
  ///
  /// [identifier] is the unique storage identifier returned by [store].
  Future<bool> exists(String identifier);

  /// Deletes the asset associated with the [identifier].
  ///
  /// [identifier] is the unique storage identifier returned by [store].
  Future<void> delete(String identifier);

  /// Opens a platform-specific dialog to export the asset to a public location.
  ///
  /// [identifier] is the internal path to the asset.
  /// [fileName] is the name presented to the user in the picker.
  Future<void> export(String identifier, String fileName);

  /// Returns a URI (file://, https://, etc.) for UI display or external players.
  ///
  /// [identifier] is the unique storage identifier returned by [store].
  String getUri(String identifier);
}
