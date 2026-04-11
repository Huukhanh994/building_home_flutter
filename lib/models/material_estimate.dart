import 'project_model.dart';

class MaterialEstimate {
  final ProjectModel project;

  // Areas
  final double floorArea;   // m²
  final double totalArea;   // m²

  // Raw materials
  final double steel;       // kg
  final double concrete;    // m³
  final double cement;      // bags (50 kg)
  final double sand;        // m³
  final double stone;       // m³
  final int bricks;

  // Costs (VND)
  final double structuralCost;
  final double finishingCost;
  final double totalCost;

  const MaterialEstimate({
    required this.project,
    required this.floorArea,
    required this.totalArea,
    required this.steel,
    required this.concrete,
    required this.cement,
    required this.sand,
    required this.stone,
    required this.bricks,
    required this.structuralCost,
    required this.finishingCost,
    required this.totalCost,
  });
}
