import 'house_type.dart';

class ProjectModel {
  final String name;
  final double width;
  final double length;
  final int floors;
  final HouseType houseType;
  final DateTime createdAt;

  ProjectModel({
    required this.name,
    required this.width,
    required this.length,
    required this.floors,
    required this.houseType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
