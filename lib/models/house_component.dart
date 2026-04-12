import 'package:flutter/foundation.dart';

/// Component group categories
enum ComponentGroup { roof, structure, wallSystem, exterior }

/// A single tappable structural component of a house
@immutable
class HouseComponent {
  const HouseComponent({
    required this.id,
    required this.label,
    required this.group,
    required this.area,
    required this.unit,
  });

  /// Unique identifier matching SVG/painter id convention: roof_main, wall_front, etc.
  final String id;

  /// Vietnamese display name
  final String label;
  final ComponentGroup group;

  /// Surface area used for material calculation
  final double area;

  /// Area unit — typically 'm2'
  final String unit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is HouseComponent && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
