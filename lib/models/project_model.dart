import 'house_type.dart';
import 'region.dart';

class ProjectModel {
  final String name;
  final double width;
  final double length;
  final int floors;
  final HouseType houseType;
  final Region region;
  final DateTime createdAt;

  ProjectModel({
    required this.name,
    required this.width,
    required this.length,
    required this.floors,
    required this.houseType,
    Region? region,
    DateTime? createdAt,
  })  : region = region ?? Region.other,
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'name': name,
        'width': width,
        'length': length,
        'floors': floors,
        'houseType': houseType.name,
        'region': region.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        name: json['name'] as String,
        width: (json['width'] as num).toDouble(),
        length: (json['length'] as num).toDouble(),
        floors: json['floors'] as int,
        houseType: HouseType.values.firstWhere(
          (e) => e.name == json['houseType'],
          orElse: () => HouseType.twoStory,
        ),
        region: Region.values.firstWhere(
          (e) => e.name == (json['region'] ?? ''),
          orElse: () => Region.other,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
