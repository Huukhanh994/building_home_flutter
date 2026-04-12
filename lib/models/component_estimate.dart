import 'package:flutter/foundation.dart';
import 'house_component.dart';

/// Material quantities for a single component
@immutable
class ComponentMaterials {
  const ComponentMaterials({
    this.cement = 0,
    this.sand = 0,
    this.steel = 0,
    this.brick = 0,
    this.concrete = 0,
    this.roofTile = 0,
  });

  /// bags
  final double cement;

  /// m³
  final double sand;

  /// kg
  final double steel;

  /// pieces
  final double brick;

  /// m³
  final double concrete;

  /// pieces (for roof components)
  final double roofTile;
}

/// Cost breakdown for a single component (VND)
@immutable
class ComponentCost {
  const ComponentCost({
    required this.materialCost,
    required this.laborCost,
  });

  final double materialCost;
  final double laborCost;
  double get total => materialCost + laborCost;
}

/// Full estimation result for a single component
@immutable
class ComponentEstimate {
  const ComponentEstimate({
    required this.component,
    required this.materials,
    required this.cost,
    required this.calculationVersion,
  });

  final HouseComponent component;
  final ComponentMaterials materials;
  final ComponentCost cost;
  final String calculationVersion;
}
