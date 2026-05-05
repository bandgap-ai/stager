// Dart core
import 'dart:typed_data';

// Project files
import '../system/stager_system.dart';

/// This is a simple enumeration of basic types of Data represented by data
/// nodes.
enum DataNodeType {
  /// An image file of any type.
  image,

  /// A audio file of any type.
  audio,

  /// A video file of any type.
  video,

  /// A PDF file.
  pdf,

  /// A Microsoft Office doc or docx file.
  doc,

  /// A plain text file.
  txt,

  /// A plain text file with CSV formatting.
  csv,

  /// Any other type of file.
  other
}

/// This class represents data objects stored by Stager. This is one of the
/// lowest level nodes in the tree hierarchy and all LeafNodes can have data
/// stored as DataNodes.
///
/// The DataNode manages its own IO by utilizing the Stager Platform's
/// [StorageProvider], which is part of the System package.
///
/// Like other parts of Stager, it does not mess with null values. In this
/// implementation, it acts as an active record of the binary object it
/// represents.
class DataNode {
  /// A basic storage identifier for the data object (relative path or UID).
  final String path;

  /// The category of data this node represents.
  final DataNodeType type;

  /// The specific MIME type of the file (e.g., image/jpeg).
  final String mimeType;

  /// The size of the file in bytes.
  final int size;

  /// The timestamp (milliseconds since epoch) when the data was created.
  final int timestamp;

  /// Creates a new DataNode with the provided properties.
  const DataNode({
    required this.path,
    this.type = DataNodeType.other,
    this.mimeType = 'application/octet-stream',
    this.size = 0,
    required this.timestamp,
  });

  /// Factory constructor to create a DataNode from a map.
  factory DataNode.fromMap(Map<String, Object> map) {
    late final DataNode result;

    result = DataNode(
      path: map['path'].toString(),
      type: DataNodeType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => DataNodeType.other,
      ),
      mimeType: map['mimeType'].toString(),
      size: (map['size'] as int),
      timestamp: (map['timestamp'] as int),
    );

    return result;
  }

  /// Converts the DataNode to a map for serialization.
  Map<String, Object> toMap() {
    late final Map<String, Object> result;

    result = {
      'path': path,
      'type': type.toString(),
      'mimeType': mimeType,
      'size': size,
      'timestamp': timestamp,
    };

    return result;
  }

  /// Converts the DataNode to an encodable object for JSON serialization.
  Object toJson() => toMap();

  /// Reads the raw bytes of the data object from the active storage provider.
  Future<Uint8List> readBytes() => StagerSystem.storage.get(path);

  /// Opens a stream for reading the data object from the active storage
  /// provider.
  Future<Stream<List<int>>> openStream() => StagerSystem.storage.getStream(path);

  /// Removes the data object from the active storage provider if [confirmed] is
  /// true.
  Future<void> remove(bool confirmed) async {
    if (confirmed) {
      await StagerSystem.storage.delete(path);
    }
  }

  /// Exports the data object to a public location with the
  /// [suggestedFileName].
  Future<void> export(String suggestedFileName) =>
      StagerSystem.storage.export(path, suggestedFileName);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataNode &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          timestamp == other.timestamp;

  @override
  int get hashCode => path.hashCode ^ timestamp.hashCode;
}
