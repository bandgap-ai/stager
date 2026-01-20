/// This file defines the SinglePointMapEditor widget for interactive editing of a single map point.
library;

import 'dart:math'; // For distance calculation if needed for delete/move via map tap
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// --- DEFINE TOP-LEVEL CONSTANTS HERE ---
// These are the actual 32-bit ARGB integer values for the primary shades
// of Colors.orange and Colors.red.
const int _kOrangePrimaryARGBValue = 0xFFFF9800; // Value of Colors.orange (shade 500)
const int _kRedPrimaryARGBValue = 0xFFF44336;     // Value of Colors.red (shade 500)

// These are now true compile-time system, declared at the top level
const Color orangeWithOpacity = Color.fromRGBO(
    (_kOrangePrimaryARGBValue >> 16) & 0xFF, // Extract Red from ARGB
    (_kOrangePrimaryARGBValue >> 8) & 0xFF,  // Extract Green from ARGB
    _kOrangePrimaryARGBValue & 0xFF,       // Extract Blue from ARGB
    0.7                                    // Opacity
);

const Color redWithOpacity = Color.fromRGBO(
    (_kRedPrimaryARGBValue >> 16) & 0xFF,    // Extract Red from ARGB
    (_kRedPrimaryARGBValue >> 8) & 0xFF,     // Extract Green from ARGB
    _kRedPrimaryARGBValue & 0xFF,          // Extract Blue from ARGB
    0.7                                      // Opacity
);
// --- END OF TOP-LEVEL CONSTANTS ---

/// A widget that provides interactive map-based editing of a single point.
///
/// Users can click to add/set a point, drag the point to move it,
/// and click on the point (or use a button) to delete it.
class SinglePointMapEditor extends StatefulWidget {

  /// Initial point to edit (can be null).
  final LatLng? initialPoint;

  /// Center position for the map view.
  final LatLng centerPosition;

  /// Callback when the point is updated (or cleared).
  final void Function(LatLng?) onPointChanged;

  final List<TileLayer>? tileLayers;

  /// Creates a [SinglePointMapEditor] widget.
  const SinglePointMapEditor({
    super.key,
    this.initialPoint,
    required this.centerPosition,
    required this.onPointChanged,
    this.tileLayers,
  });

  @override
  State<SinglePointMapEditor> createState() => _SinglePointMapEditorState();
}

class _SinglePointMapEditorState extends State<SinglePointMapEditor> {

  /// The current point being edited.
  LatLng? _currentPoint;

  /// Whether the marker is currently being dragged.
  bool _isDraggingMarker = false;

  /// Map controller for programmatic map control.
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _currentPoint = widget.initialPoint;
  }

  @override
  void didUpdateWidget(covariant SinglePointMapEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the initialPoint prop changes externally, update the internal state
    if (widget.initialPoint != oldWidget.initialPoint && _currentPoint != widget.initialPoint) {
      setState(() {
        _currentPoint = widget.initialPoint;
      });
    }
  }

  /// Handles tap events on the map.
  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (_isDraggingMarker) return; // Don't handle map tap if dragging marker

    setState(() {
      _currentPoint = point;
      widget.onPointChanged(_currentPoint);
    });

    // Optional: If in delete mode, clicking near the point could delete it,
    // but a dedicated button or marker tap is often clearer for a single point.
  }

  /// Clears the current point.
  void _clearPoint() {
    setState(() {
      _currentPoint = null;
      widget.onPointChanged(null);
    });
  }

  /// Creates a marker for the current point.
  List<Marker> _createPointMarker() {
    if (_currentPoint == null) return [];

    return [
      Marker(
        width: 30.0, // Make it a bit more prominent
        height: 30.0,
        point: _currentPoint!,
        child: GestureDetector(
          onTap: () {
              _clearPoint();
            },
          onPanStart: (details) {
              setState(() {
                _isDraggingMarker = true;
              });
          },
          onPanUpdate: (details) {
            if (!_isDraggingMarker || _currentPoint == null) return;

            final camera = _mapController.camera;
            final zoom = camera.zoom;

            // Simple approximation for pixel to LatLng offset (consider using mapController.pixelToLatLng if available and suitable)
            // This is a rough conversion and might need adjustment based on flutter_map's projection logic at high/low zoom levels
            final metersPerPixel = 156543.03392 * cos(_currentPoint!.latitude * pi / 180) / pow(2, zoom);
            final latOffset = -details.delta.dy * metersPerPixel / 111320; // Approx meters per degree latitude
            final lngOffset = details.delta.dx * metersPerPixel / (111320 * cos(_currentPoint!.latitude * pi / 180)); // Approx meters per degree longitude at latitude

            setState(() {
              _currentPoint = LatLng(
                _currentPoint!.latitude + latOffset,
                _currentPoint!.longitude + lngOffset,
              );
              widget.onPointChanged(_currentPoint);
            });
          },
          onPanEnd: (details) {
            if (_isDraggingMarker) {
              setState(() {
                _isDraggingMarker = false;
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: _isDraggingMarker ? orangeWithOpacity : redWithOpacity,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              Icons.location_pin,
              color: Colors.white,
              size: _isDraggingMarker ? 20 : 16,
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar

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
                  style: TextStyle(fontSize: 18, color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              if (_currentPoint != null)
                TextButton.icon(
                  onPressed: _clearPoint,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear Point'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                )
              else
                const Text('No point selected'),
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
              interactionOptions: InteractionOptions(
                flags: _isDraggingMarker ? InteractiveFlag.none : InteractiveFlag.all,
              ),
            ),
            children: [
              // Use provided tile layers, or default to satellite view
              ...(widget.tileLayers ??
                  [
                    // 1. Satellite Base Layer
                    TileLayer(
                      urlTemplate:
                          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                      userAgentPackageName:
                          'dev.flutter_map.example', // Replace with your app's package name
                    ),
                    // 2. Roads, Boundaries, and Labels Overlay Layer
                    // This layer (World_Boundaries_and_Places) should inherently have transparency.
                    TileLayer(
                      urlTemplate:
                          'https://services.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}',
                      // NO backgroundColor parameter here
                      userAgentPackageName:
                          'dev.flutter_map.example', // Replace with your app's package name
                    ),
                  ]),
              MarkerLayer(markers: _createPointMarker()),
              // Attribution (if needed)
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'Esri, Maxar, Earthstar Geographics, and the GIS User Community', // Updated typical Esri attribution
                    // onTap: () => launchUrl(Uri.parse('https://www.esri.com/en-us/home')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getInstructionText() {
    if (_currentPoint == null) {
      return 'Click on the map to place the point.';
    }
    return 'Click on the map to move the point. Drag the marker to move it, or tap it (or use "Clear Point" button) to delete.';
  }
}
