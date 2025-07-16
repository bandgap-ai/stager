/// This file defines the EnhancedEditNodeDialog widget for editing Level 1 nodes with outline areas.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:stager/tree/tree.dart';
import 'package:stager/editors/outline_area_map_editor.dart';

/// A dialog widget for editing Level 1 nodes with support for outline areas.
///
/// This dialog extends the basic name editing with the ability to define and edit
/// outline areas for Level 1 nodes (nodes directly under sites).
class EnhancedEditNodeDialog extends StatefulWidget {
  /// The [NodeProperties] to be edited.
  final NodeProperties properties;

  /// The [LeafNode] being edited (needed to determine level and get position).
  final LeafNode node;

  /// Creates an [EnhancedEditNodeDialog].
  const EnhancedEditNodeDialog({
    super.key,
    required this.properties,
    required this.node,
  });

  @override
  State<EnhancedEditNodeDialog> createState() => _EnhancedEditNodeDialogState();
}

/// The state for the [EnhancedEditNodeDialog] widget.
class _EnhancedEditNodeDialogState extends State<EnhancedEditNodeDialog> {
  /// Controller for the name text field.
  late TextEditingController _nameController;

  /// Current outline area points.
  List<LatLng> _outlinePoints = [];

  /// Whether to show the map editor or coordinate list editor.
  bool _useMapEditor = false;

  /// Determines if this is a Level 1 node (directly under a site).
  bool get _isLevel1Node {
    return _getNodeLevel(widget.node) == 1;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.properties.getProperty('name') as String? ?? '',
    );
    _loadOutlineArea();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Determines the level of a node in the tree (1 = top level under site, etc.)
  int _getNodeLevel(LeafNode node) {
    int level = 0;
    LeafNode? current = node;
    while (current?.parent != null) {
      level++;
      current = current!.parent;
    }
    return level;
  }

  /// Loads existing outline area from the node properties.
  void _loadOutlineArea() {
    final outlineData = widget.properties.getProperty('outline');
    if (outlineData != null) {
      List<LatLng> points = [];

      // Handle different outline data formats
      if (outlineData is List<LatLng>) {
        points = outlineData;
      } else if (outlineData is List) {
        // Try to convert list of maps/objects to LatLng
        for (final point in outlineData) {
          if (point is Map<String, dynamic>) {
            final lat = point['latitude'] ?? point['lat'];
            final lng = point['longitude'] ?? point['lng'] ?? point['lon'];
            if (lat != null && lng != null) {
              points.add(LatLng(lat.toDouble(), lng.toDouble()));
            }
          } else if (point is LatLng) {
            points.add(point);
          }
        }
      }

      _outlinePoints = points;
    }
  }

  /// Gets the center position for the map editor.
  LatLng _getCenterPosition() {
    // Try to get position from separate latitude/longitude properties first
    final lat = widget.properties.getProperty('latitude');
    final lng = widget.properties.getProperty('longitude');

    if (lat != null && lng != null) {
      // Handle different numeric types
      double? latDouble;
      double? lngDouble;

      if (lat is double) {
        latDouble = lat;
      } else if (lat is int) {
        latDouble = lat.toDouble();
      } else if (lat is String) {
        latDouble = double.tryParse(lat);
      }

      if (lng is double) {
        lngDouble = lng;
      } else if (lng is int) {
        lngDouble = lng.toDouble();
      } else if (lng is String) {
        lngDouble = double.tryParse(lng);
      }

      if (latDouble != null && lngDouble != null) {
        return LatLng(latDouble, lngDouble);
      }
    }

    // Fallback: try to get from a 'position' property (if it exists as LatLng)
    final position = widget.properties.getProperty('position');
    if (position is LatLng) {
      return position;
    }

    // Default to a reasonable center if no position is set
    return const LatLng(40.7128, -74.0060); // New York City
  }

  /// Builds the outline area editing section for Level 1 nodes.
  Widget _buildOutlineAreaEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'Outline Area:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Coordinates'),
                  icon: Icon(Icons.list, size: 16),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Map Editor'),
                  icon: Icon(Icons.map, size: 16),
                ),
              ],
              selected: {_useMapEditor},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _useMapEditor = selection.first;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: _useMapEditor ? 400 : 200,
          child: _useMapEditor ? _buildMapEditor() : _buildCoordinateEditor(),
        ),
      ],
    );
  }

  /// Builds the map-based editor for outline areas.
  Widget _buildMapEditor() {
    return OutlineAreaMapEditor(
      initialPoints: _outlinePoints,
      centerPosition: _getCenterPosition(),
      onPointsChanged: (points) {
        setState(() {
          _outlinePoints = points;
        });
      },
    );
  }

  /// Builds the coordinate list editor for outline areas.
  Widget _buildCoordinateEditor() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Coordinates',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: _addCoordinate,
                  tooltip: 'Add Coordinate',
                ),
              ],
            ),
          ),
          // Coordinate list
          Expanded(
            child: _outlinePoints.isEmpty
                ? const Center(
                    child: Text(
                      'No coordinates defined\nTap + to add coordinates',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _outlinePoints.length,
                    itemBuilder: (context, index) {
                      final point = _outlinePoints[index];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 12,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, size: 16),
                          onPressed: () => _removeCoordinate(index),
                        ),
                        onTap: () => _editCoordinate(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Adds a new coordinate to the outline.
  void _addCoordinate() async {
    final result = await _showCoordinateDialog();
    if (result != null) {
      setState(() {
        _outlinePoints.add(result);
      });
    }
  }

  /// Removes a coordinate from the outline.
  void _removeCoordinate(int index) {
    setState(() {
      _outlinePoints.removeAt(index);
    });
  }

  /// Edits an existing coordinate.
  void _editCoordinate(int index) async {
    final result = await _showCoordinateDialog(
      initialLat: _outlinePoints[index].latitude,
      initialLng: _outlinePoints[index].longitude,
    );
    if (result != null) {
      setState(() {
        _outlinePoints[index] = result;
      });
    }
  }

  /// Shows a dialog for entering/editing coordinates.
  Future<LatLng?> _showCoordinateDialog({
    double? initialLat,
    double? initialLng,
  }) async {
    final latController = TextEditingController(
      text: initialLat?.toStringAsFixed(6) ?? '',
    );
    final lngController = TextEditingController(
      text: initialLng?.toStringAsFixed(6) ?? '',
    );

    return showDialog<LatLng>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initialLat != null ? 'Edit Coordinate' : 'Add Coordinate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                hintText: 'e.g., 40.7128',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lngController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: 'e.g., -74.0060',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final lat = double.tryParse(latController.text);
              final lng = double.tryParse(lngController.text);
              if (lat != null && lng != null) {
                Navigator.of(context).pop(LatLng(lat, lng));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Saves the changes and closes the dialog.
  void _saveChanges() {
    // Save the name
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      widget.properties.setProperty('name', newName);
    }

    // Save the outline area for Level 1 nodes
    if (_isLevel1Node) {
      if (_outlinePoints.isNotEmpty) {
        widget.properties.setProperty('outline', _outlinePoints);
      } else {
        // Remove outline property if no points
        widget.properties.setProperty('outline', null);
      }
    }

    Navigator.of(context).pop(newName);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isLevel1Node ? 'Edit Level 1 Node' : 'Edit Node'),
      content: SizedBox(
        width: _isLevel1Node ? 600 : 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name editing
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),

              // Outline area editing for Level 1 nodes
              if (_isLevel1Node) _buildOutlineAreaEditor(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveChanges, child: const Text('Save')),
      ],
    );
  }
}
