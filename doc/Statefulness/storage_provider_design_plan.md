# Storage Provider for Text and Binary Data Objects - May 2026

## Status
Draft

## Context & Background
The Stager Platform currently manages node metadata through the `NodeProperties` system, which serializes to JSON. While this works well for primitive types, it is poorly suited for auxiliary binary data like images, audio memos, or PDF attachments. 

Currently, images are handled as a simple list of strings (`imagePaths`) in the primary `NodeProperties` map. This "unstructured list" approach is a red flag because it forces editors to have hard-coded knowledge of specific property keys, makes metadata management (e.g., file size, timestamps) difficult, and complicates the export/import lifecycle. To support professional GIS and data management workflows, Stager requires a structured "Binary Sidecar" architecture that decouples the tree hierarchy from the specific storage implementation (Local Filesystem, S3, Firebase, etc.).

## Goals
*   **Structured Binary Metadata**: Replace unstructured property lists with formal `DataNode` objects managed by a `DataProperties` container.
*   **Global Storage Abstraction**: Implement a globally accessible `StorageProvider` (via `StagerSystem.storage`) that allows host applications to swap storage backends with a single line of configuration.
*   **Active Data Management**: Empower `DataNode` to handle its own I/O operations (read, stream, delete, export), reducing the burden on the user to interact with the storage layer directly.
*   **Lifting State Up**: Use "Controller Injection" or direct property access to ensure UI components and the storage layer stay in sync without redundant callback loops.
*   **Asset Portability**: Facilitate "Site Archive" exports where binary dependencies are bundled with the JSON tree by leveraging the `Visitor` pattern on `DataProperties`.

## Exclusions
*   This design does NOT attempt to store binary "blobs" (Uint8List) directly inside the JSON tree.
*   This design does NOT provide a generic database (like Sembast) for the tree itself; it focuses solely on binary asset management.

## Proposed Design

### 1. Global Storage Provider
We will introduce an abstract interface for binary storage. A static member in `StagerSystem` will host the active implementation. This allows the provider to be set globally at application startup.

```dart
abstract class StorageProvider {
  /// Stores binary data and returns a unique storage identifier.
  /// Use [mimeType] to provide a hint to the storage backend (e.g., for S3 headers).
  Future<String> store(Uint8List data, {
    required String category, 
    required String fileName,
    String? mimeType,
  });

  /// Retrieves the raw bytes for the given [identifier].
  Future<Uint8List> get(String identifier);

  /// Opens a stream for reading the given [identifier]. 
  /// Recommended for large assets (audio/video) to avoid OOM errors.
  Future<Stream<List<int>>> getStream(String identifier);

  /// Checks if an asset exists for the given [identifier].
  Future<bool> exists(String identifier);

  /// Deletes the asset associated with the [identifier].
  Future<void> delete(String identifier);

  /// Returns a URI (file://, https://, etc.) for UI display or external players.
  String getUri(String identifier);
}
```
**Example Configuration:** `StagerSystem.storage = LocalFileStorageProvider();`

### 2. The Data Sidecar (`DataNode` & `DataProperties`)
To keep the primary metadata clean, we introduce a new low-level node hierarchy:
*   **DataNode**: A lightweight object representing a single binary asset. It holds the `path` (the unique identifier used by the provider) and its own metadata (size, MIME type, category, timestamp). It provides proxy methods to the `StorageProvider`.
*   **DataProperties**: A specialized instance of `NodeProperties` held by every `LeafNode`. It manages the collection of `DataNode` objects. This allows binary assets to be treated as first-class citizens of the tree.

### 3. Integration with Visitation
Stager's `Visitor` pattern will be extended to allow visitors to traverse a node's `DataProperties`. This allows an "ArchiveVisitor" to walk the tree, collect all unique identifiers, and request the bytes from the provider to bundle them into a ZIP for export.

## Alternatives Considered
*   **Base64 in JSON**: Rejected due to massive performance degradation and JSON bloat.
*   **Sembast for Blobs**: Rejected because storing images in a NoSQL database leads to massive file sizes and slow query performance.
*   **Unstructured Lists**: (Current Implementation) Rejected due to high coupling and lack of metadata support.

## Reviews & Audits
*   **Dual Source of Truth**: Previous attempts to sync `TextEditingControllers` between parents and children via `onLocationChanged` callbacks proved brittle (causing "double-pop" issues). The new design prefers "Controller Injection" or direct `DataProperties` access to ensure a single source of truth.
*   **Visibility**: Audit confirms that `DataProperties` must be included in the `toMap`/`fromMap` serialization cycle to ensure persistence.
*   **First Audit (Findings)**:
    *   **Naming Alignment**: Identified a naming discrepancy between `storageIdentifier` in the plan and `path` in `DataNode`. Resolved by standardizing on `path` to represent the unique identifier.
    *   **Memory Safety**: Recommended adding `getStream` to support large binary assets (audio/video) without exhausting device memory.
    *   **Validation**: Recommended adding `exists()` to allow metadata verification without loading full asset payloads.
    *   **Backend Metadata**: Recommended passing `mimeType` into `store()` to assist backends that require content-type headers (e.g., AWS S3).
*   **Second Audit (Findings)**:
    *   **Active DataNodes**: Decided that `DataNode` should not be a passive record. It must provide direct access to its data via the `StorageProvider`.
    *   **Safe Deletion**: Introduced `remove(bool confirmed)` on `DataNode` to ensure physical deletion from storage requires explicit intent and can be coordinated with tree updates.
    *   **Atomic Operations**: Recommended that `DataProperties` provide convenience methods to store data and create nodes in a single call to prevent partial failures and simplify the API.
*   **Third Audit (OS-Specific Hurdles)**:
    *   **Sandbox Variance**: Audit of `getApplicationDocumentsDirectory` reveals that it is a hidden sandbox on Android/iOS (private) but a public folder on Windows/Linux (user-visible). 
    *   **Desktop Namespacing**: To maintain "Sandbox Isolation" on Desktop, the `LocalFileStorageProvider` should use a sub-directory (e.g., `Documents/Stager/Assets`) to avoid cluttering the user's primary folders.
    *   **User Reviewability**: Confirmed that on mobile, assets are **not** user-visible via the OS. End-users must review assets through an in-app viewer or explicit "Export" action. This design choice protects data integrity and avoids the "Permission Mess" of public storage.
    *   **Permission-Free Pathing**: Confirmed that using application-specific internal directories avoids the `FileHandler`-style Scoped Storage complexities on modern Android (API 30+).

## Implementation Details

### Phase 1: Models & Foundation (Completed)
*   Create `DataNode` in `lib/tree/`. Ensure it uses the field name `path` for consistency with the provider's identifier.
*   Implement `DataProperties` as a specialized `NodeProperties`.
*   Update `LeafNode` to include a `dataNodes` member (returning `DataProperties`).
*   Update `LeafNode.toMap()` and `LeafNode.fromMap()` to support nested data properties.
*   Update `LeafNode` tests.

### Phase 2: Migration (Completed)
*   Refactor `PropertiesWidget` to use `DataProperties` instead of the `imagePaths` property list.
*   Update the `ImagePicker` logic to create `DataNodes`.
*   Update existing editors and UI components to remove references to the deprecated `imagePaths` key.

### Phase 3: Storage Provider & Integration
*   Define `StorageProvider` interface in `lib/system/` including `getStream` and `exists` methods.
*   Add the `storage` static member to `StagerSystem`.
*   **Enhance DataNode**:
    *   Add `Future<Uint8List> readBytes() => StagerSystem.storage.get(path);`.
    *   Add `Future<Stream<List<int>>> openStream() => StagerSystem.storage.getStream(path);`.
    *   Add `Future<void> remove(bool confirmed)`: If confirmed, call `StagerSystem.storage.delete(path)`.
    *   Add `Future<void> export(String suggestedFileName)`: Facilitates moving the file from the private sandbox to a public, user-accessible directory (e.g., Downloads) using an OS-specific picker.
*   **Enhance DataProperties**:
    *   Add `Future<DataNode> addAsset(Uint8List bytes, ...)` convenience method to handle storage and node creation atomically.
    *   Logic for removing a node should ensure `DataNode.remove(true)` is called before the metadata is purged from the properties container.
*   Implement `LocalFileStorageProvider` using the `path_provider` package and OS-specific delegates
    in the Stager Platform project.
*   **OS-Dependent Considerations**:
    *   **Android/iOS**: Persistent data must live in the private `ApplicationDocumentsDirectory`.
    *   **Desktop (Windows/Linux)**: Use `getApplicationDocumentsDirectory()`, but append a `/Stager` sub-folder to respect the user's workspace.
    *   **Pathing**: Use `path.join()` from `package:path` for OS-agnostic path construction.

## Testing Plan
* **Unit Tests**: Verify `DataNode` serialization and `DataProperties` management.
* **Storage Tests**: Verify that `DataNode.remove(true)` correctly triggers the `StorageProvider.delete()`.
* **Widget Tests**: Verify that the `PropertiesWidget` correctly displays attachments from the `DataProperties`.
* **Integration Tests**: Verify that changing `StagerSystem.storage` at runtime correctly redirects asset retrieval.

## Short Example

### Adding, Exporting, and Removing an Asset
```dart
// Adding an image via the new convenience method
final bytes = await image.readAsBytes(); // Uint8List from dart:typed_data
final dataNode = await node.dataNodes.addAsset(
  bytes, 
  category: 'photos', 
  fileName: 'site_check.jpg',
  mimeType: 'image/jpeg',
);

// Exporting the file to a public location
await dataNode.export('my_exported_photo.jpg');

// Removing the asset safely requires confirmation and cleans up storage
final nodeToRemove = node.dataNodes.get('attachment_0');
await nodeToRemove.remove(true); // Deletes from physical storage
node.dataNodes.remove('attachment_0'); // Removes from metadata tree
```

## Open Questions
* Should `DataProperties` support nested categories (folders) natively?

## Tickets

- [Implement DataNode and DataProperties](https://gitlab.com/bandgap/stager-platform/stager/-/work_items/59)
- [Refactor LeafNode for DataProperties](https://gitlab.com/bandgap/stager-platform/stager/-/work_items/60)
- [Migrate imagePaths to DataProperties](https://gitlab.com/bandgap/stager-platform/stager/-/work_items/61)
- [Define StorageProvider Interface](https://gitlab.com/bandgap/stager-platform/stager/-/work_items/62)
- [Implement LocalFileStorageProvider](https://gitlab.com/bandgap/stager-platform/stager/-/work_items/63)
- [Binary Storage Integration Tests](https://gitlab.com/bandgap/stager-platform/stager/-/work_items/64)
