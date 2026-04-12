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

  Map<String, dynamic> toJson() => {
        'project': project.toJson(),
        'floorArea': floorArea,
        'totalArea': totalArea,
        'steel': steel,
        'concrete': concrete,
        'cement': cement,
        'sand': sand,
        'stone': stone,
        'bricks': bricks,
        'structuralCost': structuralCost,
        'finishingCost': finishingCost,
        'totalCost': totalCost,
      };

  factory MaterialEstimate.fromJson(Map<String, dynamic> json) =>
      MaterialEstimate(
        project:
            ProjectModel.fromJson(json['project'] as Map<String, dynamic>),
        floorArea: (json['floorArea'] as num).toDouble(),
        totalArea: (json['totalArea'] as num).toDouble(),
        steel: (json['steel'] as num).toDouble(),
        concrete: (json['concrete'] as num).toDouble(),
        cement: (json['cement'] as num).toDouble(),
        sand: (json['sand'] as num).toDouble(),
        stone: (json['stone'] as num).toDouble(),
        bricks: json['bricks'] as int,
        structuralCost: (json['structuralCost'] as num).toDouble(),
        finishingCost: (json['finishingCost'] as num).toDouble(),
        totalCost: (json['totalCost'] as num).toDouble(),
      );
}
