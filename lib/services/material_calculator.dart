import '../data/cost_config.dart';
import '../models/material_estimate.dart';
import '../models/project_model.dart';

class MaterialCalculator {
  MaterialCalculator._();

  static MaterialEstimate calculate(ProjectModel project) {
    final floorArea = project.width * project.length;
    final totalArea = floorArea * project.floors;

    // Steel: 90 kg / m²
    final steel = totalArea * 90.0;

    // Concrete: 0.25 m³ / m²
    final concrete = totalArea * 0.25;

    // Cement bags (50 kg each): concrete * 300 kg/m³ ÷ 50
    final cement = (concrete * 300.0) / 50.0;

    // Sand: 0.5 m³ / m³ concrete
    final sand = concrete * 0.5;

    // Stone: 0.8 m³ / m³ concrete
    final stone = concrete * 0.8;

    // Bricks: perimeter × storey height × floors × 70 % solid × 60 bricks/m²
    final perimeter = 2.0 * (project.width + project.length);
    final wallArea = perimeter * 3.2 * project.floors * 0.7;
    final bricks = (wallArea * 60.0).toInt();

    // Costs — base price adjusted by regional multiplier
    final totalCost = totalArea *
        project.houseType.costPerM2 *
        project.region.multiplier;
    final structuralCost = totalCost * CostConfig.structuralFraction;
    final finishingCost  = totalCost * CostConfig.finishingFraction;

    return MaterialEstimate(
      project: project,
      floorArea: floorArea,
      totalArea: totalArea,
      steel: steel,
      concrete: concrete,
      cement: cement.ceilToDouble(),
      sand: sand,
      stone: stone,
      bricks: bricks,
      structuralCost: structuralCost,
      finishingCost: finishingCost,
      totalCost: totalCost,
    );
  }
}
