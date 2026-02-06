import 'package:flutter/material.dart';
import 'package:stager_platform/editors/stager_editor.dart';
import 'package:stager_platform/mapping/map_state.dart';

class MapEditor extends StagerEditor<MapState> {
  const MapEditor({super.key, required super.state});

  @override
  State<StatefulWidget> createState() => _MapEditorState();
}

class _MapEditorState extends State<MapEditor> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}