import 'package:flutter/cupertino.dart';
import 'package:stager_platform/editors/basic_site_controls.dart';
import 'package:stager_platform/editors/dialog_control_button.dart';
import 'package:stager_platform/tree/composite_node.dart';
import 'package:stager_platform/tree/leaf_node.dart';

/// This is a simple mock that adds tracking to the BasicSiteControls class
/// using delegation. Its primary purpose is to ensure that site controls can be
/// injected.
class MockSiteControls extends BasicSiteControls {

  /// Tracking variable for the buildAddNodeControl method.
  bool _buildAddNodeCalled = false;
  bool get buildAddNodeCalled => _buildAddNodeCalled;

  /// Tracking variable for the buildEditNodeControl method.
  bool _buildEditNodeCalled = false;
  bool get buildEditNodeCalled => _buildEditNodeCalled;

  /// This function resets the tracking variables.
  void reset() {
    _buildAddNodeCalled = false;
    _buildEditNodeCalled = false;
  }

  @override
  DialogControlButton buildAddNodeControl(BuildContext context, CompositeNode parent) {
    _buildAddNodeCalled = true;
    return super.buildAddNodeControl(context, parent);
  }

  @override
  DialogControlButton buildEditNodeControl(BuildContext context, LeafNode state) {
    _buildEditNodeCalled = true;
    return super.buildEditNodeControl(context, state);
  }

}