/// This file defines the OutlineAreaMapEditor widget for interactive editing of polygon outline areas.
library;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget that provides interactive map-based editing of polygon outline areas.
///
/// Users can click to add points, drag to move points, and click on points to delete them.
class OutlineAreaMapEditor extends StatefulWidget {
  /// Initial outline points to edit.
  final List<LatLng> initialPoints;

  /// Center position for the map view.
  final LatLng centerPosition;

  /// Callback when the outline points are updated.
  final void Function(List<LatLng>) onPointsChanged;

  /// Creates an [OutlineAreaMapEditor] widget.
  const OutlineAreaMapEditor({
    super.key,
    required this.initialPoints,
    required this.centerPosition,
    required this.onPointsChanged,
  });

  @override
  State<OutlineAreaMapEditor> createState() => _OutlineAreaMapEditorState();
}

class _OutlineAreaMapEditorState extends State<OutlineAreaMapEditor> {
  /// Current editing mode.
  EditMode _editMode = EditMode.add;

  /// Current list of outline points being edited.
  List<LatLng> _points = [];

  /// Index of the currently selected point for moving.
  int? _selectedPointIndex;

  /// Whether a point is currently being dragged.
  bool _isDragging = false;

  /// Map controller for programmatic map control.
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _points = List.from(widget.initialPoints);
  }

  /// Handles tap events on the map.
  void _onMapTap(TapPosition tapPosition, LatLng point) {
    // Don't handle tap if we're in the middle of a drag operation
    if (_isDragging) return;
    
    setState(() {
      switch (_editMode) {
        case EditMode.add:
          _points.add(point);
          _selectedPointIndex = null;
          break;
        case EditMode.delete:
          // Find the closest point and remove it if it's close enough
          _deleteNearestPoint(point);
          break;
        case EditMode.move:
          // Select the nearest point for moving
          _selectNearestPoint(point);
          break;
      }
      widget.onPointsChanged(_points);
    });
  }

  /// Deletes the nearest point if it's within a reasonable distance.
  void _deleteNearestPoint(LatLng tapPoint) {
    if (_points.isEmpty) return;

    int nearestIndex = 0;
    double nearestDistance = _calculateDistance(_points[0], tapPoint);

    for (int i = 1; i < _points.length; i++) {
      final distance = _calculateDistance(_points[i], tapPoint);
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = i;
      }
    }

    // Only delete if the tap was close enough (within ~50 meters at zoom level 15)
    if (nearestDistance < 0.0005) {
      _points.removeAt(nearestIndex);
      _selectedPointIndex = null;
    }
  }

  /// Selects the nearest point for moving.
  void _selectNearestPoint(LatLng tapPoint) {
    if (_points.isEmpty) return;

    int nearestIndex = 0;
    double nearestDistance = _calculateDistance(_points[0], tapPoint);

    for (int i = 1; i < _points.length; i++) {
      final distance = _calculateDistance(_points[i], tapPoint);
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = i;
      }
    }

    // Only select if the tap was close enough
    if (nearestDistance < 0.0005) {
      _selectedPointIndex = nearestIndex;
    } else {
      _selectedPointIndex = null;
    }
  }

  /// Handles long press events for moving points.
  void _onMapLongPress(TapPosition tapPosition, LatLng point) {
    if (_selectedPointIndex != null) {
      setState(() {
        _points[_selectedPointIndex!] = point;
        widget.onPointsChanged(_points);
      });
    }
  }

  /// Calculates simple Euclidean distance between two points (for close proximity).
  double _calculateDistance(LatLng point1, LatLng point2) {
    final latDiff = point1.latitude - point2.latitude;
    final lngDiff = point1.longitude - point2.longitude;
    return (latDiff * latDiff + lngDiff * lngDiff);
  }

  /// Clears all points.
  void _clearPoints() {
    setState(() {
      _points.clear();
      _selectedPointIndex = null;
      widget.onPointsChanged(_points);
    });
  }

  /// Creates a polygon from the current points.
  List<Polygon> _createPolygon() {
    if (_points.length < 3) return [];

    return [
      Polygon(
        points: _points,
        color: Colors.blue.withValues(alpha: 0.3),
        borderColor: Colors.blue,
        borderStrokeWidth: 2.0,
      ),
    ];
  }

  /// Creates markers for each point.
  List<Marker> _createPointMarkers() {
    return _points.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;
      final isSelected = _selectedPointIndex == index;

      return Marker(
        width: 20.0,
        height: 20.0,
        point: point,
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (_editMode == EditMode.delete) {
                _points.removeAt(index);
                _selectedPointIndex = null;
                widget.onPointsChanged(_points);
              } else if (_editMode == EditMode.move) {
                _selectedPointIndex = isSelected ? null : index;
              }
            });
          },
          // Add pan gesture detection for move mode
          onPanStart: _editMode == EditMode.move ? (details) {
            setState(() {
              _selectedPointIndex = index;
              _isDragging = true;
            });
          } : null,
          onPanUpdate: _editMode == EditMode.move ? (details) {
            if (_isDragging && _selectedPointIndex == index) {
              // Convert screen coordinates to geographic coordinates
              final camera = _mapController.camera;
              final zoom = camera.zoom;
              
              // Calculate the scale factor for coordinate conversion
              final metersPerPixel = 156543.03392 * cos(point.latitude * pi / 180) / pow(2, zoom);
              final latOffset = -details.delta.dy * metersPerPixel / 111320;
              final lngOffset = details.delta.dx * metersPerPixel / (111320 * cos(point.latitude * pi / 180));
              
              final newLatLng = LatLng(
                point.latitude + latOffset,
                point.longitude + lngOffset,
              );
              
              setState(() {
                _points[index] = newLatLng;
                widget.onPointsChanged(_points);
              });
            }
          } : null,
          onPanEnd: _editMode == EditMode.move ? (details) {
            setState(() {
              _isDragging = false;
            });
          } : null,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.red : (_isDragging && _selectedPointIndex == index ? Colors.orange : Colors.blue),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              const Text('Edit Mode: ', style: TextStyle(fontWeight: FontWeight.bold)),
              SegmentedButton<EditMode>(
                segments: const [
                  ButtonSegment(
                    value: EditMode.add,
                    label: Text('Add'),
                    icon: Icon(Icons.add, size: 16),
                  ),
                  ButtonSegment(
                    value: EditMode.move,
                    label: Text('Move'),
                    icon: Icon(Icons.pan_tool, size: 16),
                  ),
                  ButtonSegment(
                    value: EditMode.delete,
                    label: Text('Delete'),
                    icon: Icon(Icons.delete, size: 16),
                  ),
                ],
                selected: {_editMode},
                onSelectionChanged: (Set<EditMode> selection) {
                  setState(() {
                    _editMode = selection.first;
                    _selectedPointIndex = null;
                  });
                },
              ),
              const Spacer(),
              Text('Points: ${_points.length}'),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: _clearPoints,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear'),
              ),
            ],
          ),
        ),

        // Instructions
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.blue[50],
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getInstructionText(),
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),

        // Map
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.centerPosition,
              initialZoom: 15.0,
              onTap: _onMapTap,
              onLongPress: _onMapLongPress,
              // Disable map interactions during dragging
              interactionOptions: InteractionOptions(
                flags: _isDragging ? InteractiveFlag.none : InteractiveFlag.all,
              ),
            ),
            children: [
              // Satellite tile layer
              TileLayer(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                subdomains: const ['a', 'b', 'c'],
              ),
              
              // Polygon layer
              PolygonLayer(polygons: _createPolygon()),
              
              // Point markers
              MarkerLayer(markers: _createPointMarkers()),
              
              // Attribution
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
                    onTap: () => launchUrl(Uri.parse('https://www.esri.com/en-us/home')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Gets instruction text based on current edit mode.
  String _getInstructionText() {
    switch (_editMode) {
      case EditMode.add:
        return 'Click on the map to add points to the outline. You need at least 3 points to create a polygon.';
      case EditMode.move:
        return 'Click and drag a point marker to move it, or click to select and long-press on the map to move it to a new location.';
      case EditMode.delete:
        return 'Click on a point marker or near a point on the map to delete it.';
    }
  }
}

/// Enum representing different editing modes.
enum EditMode {
  add,
  move,
  delete,
}
