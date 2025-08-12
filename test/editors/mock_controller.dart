import 'package:stager_platform/editors/site_editor.dart';
import 'package:stager_platform/editors/controller.dart';
import 'package:flutter/material.dart';
import 'mock_site_editor.dart';

class MockController extends Controller {

  late MockSiteEditor _editor;

  /// Observer bool to track if the widget has been built.
  bool _processed = false;

  /// Returns the observer bool.
  bool get wasProcessed => _processed;

  /// Mark the observer bool as false to reset the mock.
  void reset() {
    _processed = false;
  }

  MockController(super.state, super.editorFactory) {
    _editor = MockSiteEditor(state:state);
  }

  SiteEditor get editorRef => _editor;

  @override
  SiteEditor editor(BuildContext context) {
    return _editor;
  }

  @override
  IconData iconData() {
    return Icons.add_home_work;
  }

  @override
  void process(Object input) {
    _processed = true;
  }

}
