/// This file defines the SinglePointMapEditor widget for interactive editing of
/// a single map point.
library single_point_map_editor;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// --- DEFINE TOP-LEVEL CONSTANTS HERE ---
const int _kOrangePrimaryARGBValue = 0xFFFF9800; // Colors.orange
const int _kRedPrimaryARGBValue = 0xFFF44336; // Colors.red

const Color orangeWithOpacity = Color.fromRGBO(
  (_kOrangePrimaryARGBValue >> 16) & 0xFF,
  (_kOrangePrimaryARGBValue >> 8) & 0xFF,
  _kOrangePrimaryARGBValue & 0xFF,
  0.7,
);

const Color redWithOpacity = Color.fromRGBO(
  (_kRedPrimaryARGBValue >> 16) & 0xFF,
  (_kRedPrimaryARGBValue >> 8) & 0xFF,
  _kRedPrimaryARGBValue & 0xFF,
  0.7,
);

/// A widget that provides interactive map-based editing of a single point.
///
/// Users can click to add/set a point, drag the point to move it,
/// and click on the point (or use a button) to reset it to the initial point.
class SinglePointMapEditor extends StatefulWidget {
  /// Initial point to edit.
  final LatLng initialPoint;

  /// Center position for the map view.
  final LatLng centerPosition;

  /// Callback when the point is updated (or cleared).
  final void Function(LatLng) onPointChanged;

  /// Optional list of tile layers to display on the map.
  final List<TileLayer>? tileLayers;

  const SinglePointMapEditor({
    super.key,
    this.initialPoint = const LatLng(0, 0),
    required this.centerPosition,
    required this.onPointChanged,
    this.tileLayers,
  });

  @override
  State<SinglePointMapEditor> createState() => _SinglePointMapEditorState();
}

class _SinglePointMapEditorState extends State<SinglePointMapEditor> {
  late LatLng _currentPoint;
  bool _isPointSet = false;
  bool _isDraggingMarker = false;
  final MapController _mapController = MapController();
  final GlobalKey _markerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentPoint = widget.initialPoint;
    _isPointSet = _currentPoint != const LatLng(0, 0);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SinglePointMapEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPoint != oldWidget.initialPoint &&
        widget.initialPoint != _currentPoint) {
      setState(() {
        _currentPoint = widget.initialPoint;
        _isPointSet = _currentPoint != const LatLng(0, 0);
      });
      widget.onPointChanged(_currentPoint);
    }
    if (widget.centerPosition != oldWidget.centerPosition) {
      _mapController.move(widget.centerPosition, _mapController.camera.zoom);
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (!_isDraggingMarker) {
      setState(() {
        _currentPoint = point;
        _isPointSet = true;
      });
      widget.onPointChanged(_currentPoint);
    }
  }

  void _clearPoint() {
    setState(() {
      _currentPoint = widget.initialPoint;
      _isPointSet = _currentPoint != const LatLng(0, 0);
    });
    widget.onPointChanged(_currentPoint);
  }

  List<Marker> _createPointMarker() {
    if (!_isPointSet) return [];
    return [
      Marker(
        width: 40.0, // Increased slightly for a better touch target
        height: 40.0,
        point: _currentPoint,
        child: GestureDetector(
          key: _markerKey,
          behavior: HitTestBehavior.opaque,
          onTap: _clearPoint,
          onPanStart: (_) => setState(() => _isDraggingMarker = true),
          onPanUpdate: (details) {
            if (_isDraggingMarker) {
              final camera = _mapController.camera;
              final zoom = camera.zoom;
              final metersPerPixel = 156543.03392 *
                  cos(_currentPoint.latitude * pi / 180) /
                  pow(2, zoom);
              final latOffset = -details.delta.dy * metersPerPixel / 111320;
              final lngOffset = details.delta.dx *
                  metersPerPixel /
                  (111320 * cos(_currentPoint.latitude * pi / 180));

              setState(() {
                _currentPoint = LatLng(
                  _currentPoint.latitude + latOffset,
                  _currentPoint.longitude + lngOffset,
                );
              });
              widget.onPointChanged(_currentPoint);
            }
          },
          onPanEnd: (_) => setState(() => _isDraggingMarker = false),
          // CRITICAL FIX: Ensure dragging state resets if the gesture is interrupted
          onPanCancel: () => setState(() => _isDraggingMarker = false),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _isDraggingMarker ? orangeWithOpacity : redWithOpacity,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: const Icon(Icons.location_pin, color: Colors.white, size: 20),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.blue[50],
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isPointSet
                      ? 'Click on the map to move the point. Drag the marker to move it, or tap it (or use "Clear Point" button) to delete.'
                      : 'Click on the map to place the point.',
                  style: TextStyle(fontSize: 14, color: Colors.blue[700]),
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
              if (_isPointSet)
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
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.centerPosition,
              initialZoom: 15.0,
              onTap: _onMapTap,
              interactionOptions: const InteractionOptions(
                // CRITICAL FIX: Disabling doubleTapZoom allows single taps to
                // resolve instantly in the gesture arena, which allows the
                // test framework's tester.tapAt() to fire reliably.
                flags: InteractiveFlag.all &
                ~InteractiveFlag.doubleTapZoom &
                ~InteractiveFlag.doubleTapDragZoom,
              ),
            ),
            children: [
              ...(widget.tileLayers != null && widget.tileLayers!.isNotEmpty
                  ? widget.tileLayers!
                  : [
                TileLayer(
                  urlTemplate:
                  'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'ai.bandgap.stager',
                ),
                TileLayer(
                  urlTemplate:
                  'https://services.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'ai.bandgap.stager',
                ),
              ]),
              MarkerLayer(markers: _createPointMarker()),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                      'Esri, Maxar, Earthstar Geographics, and the GIS User Community'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}