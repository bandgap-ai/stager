import 'package:flutter/material.dart';

/// This is widget used to track the state of a pin in other widgets.
///
/// This pin should shows a lock icon when it is not pinned and an unlock icon
/// when it is unpinned.
///
/// When the icon is pressed, the widget emits (via Navigator.pop()) a bool
/// to the parent widget equal to true if it is pinned and equal to false if
/// it is unpinned.
///
/// The widget must be initialized in either a pinned (true) or unpinned (false)
/// state.
class StagerPin extends StatefulWidget {
  /// The initial pin state of this widget.
  final bool initialPinState;
  final ValueChanged<bool> onPinChanged;

  /// Constructor for the [StagerPin] widget.
  ///
  /// [initialPinState] is a bool that indicates whether this widget is pinned
  /// or not.
  /// [onPinChanged] is a callback function that is called when the pin state
  const StagerPin({super.key, required this.initialPinState, required this.onPinChanged});

  @override
  State<StatefulWidget> createState() => _StagerPinState();
}

/// Private state for the [StagerPin] widget.
class _StagerPinState extends State<StagerPin> {
  bool _isPinned = false;

  /// Constructor for the [StagerPin] widget. It sets the initial pin state
  /// based on the value of the [initialPinState] property on [StagerPin].
  @override
  void initState() {
    super.initState();
    _isPinned = widget.initialPinState;
  }

  /// Utility function for flipping the pin state
  void _flipPin() {
    setState(() {
      _isPinned = !_isPinned;
    });
    widget.onPinChanged(_isPinned);
  }

  @override
  Widget build(BuildContext context) {
    // Select the icon type
    final IconData iconData = _isPinned ? Icons.lock : Icons.lock_open;
    // Create the button to toggle the pin state
    final IconButton pinWidget = IconButton(
        icon: Icon(iconData, color: Theme.of(context).colorScheme.onPrimary),
        onPressed: () {
          _flipPin();
        }
    );
    return pinWidget;
  }
}