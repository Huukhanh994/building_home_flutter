import 'blueprint_layout.dart';
import 'house_type.dart';

class HouseTemplate {
  final String id;
  final String name;
  final HouseType type;
  final double area;
  final int floors;
  final double estimatedCost;
  final String roofStyle;
  final String description;
  final List<String> features;

  /// Ground-floor blueprint. Null falls back to the auto-generated layout.
  final BlueprintLayout? blueprint;

  const HouseTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.area,
    required this.floors,
    required this.estimatedCost,
    required this.roofStyle,
    required this.description,
    required this.features,
    this.blueprint,
  });
}
