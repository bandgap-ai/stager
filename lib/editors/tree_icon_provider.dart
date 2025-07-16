import 'package:flutter/material.dart';

/// Provides [IconData] based on the tree node's level.
class TreeIconProvider {
  static const Map<int, IconData> _iconMap = {
    0: Icons.public, // Site
    1: Icons.location_on, // Site Location
    2: Icons.category, // Site Feature
    3: Icons.eco, // Site Object (leaf node)
  };

  /// Returns the appropriate [IconData] for a given tree node [level].
  IconData getIconForLevel(int level) {
    return _iconMap[level] ?? Icons.folder; // Default for deeper levels or unexpected
  }
}
