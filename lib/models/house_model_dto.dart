class HouseModelDto {
  const HouseModelDto({
    required this.id,
    required this.name,
    required this.houseType,
    required this.glbUrl,
    this.thumbnailUrl,
    this.description,
    this.sortOrder = 0,
  });

  final int id;
  final String name;
  final String houseType;
  final String glbUrl;
  final String? thumbnailUrl;
  final String? description;
  final int sortOrder;

  factory HouseModelDto.fromJson(Map<String, dynamic> json) {
    return HouseModelDto(
      id:           json['id'] as int,
      name:         json['name'] as String,
      houseType:    json['house_type'] as String,
      glbUrl:       json['glb_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      description:  json['description'] as String?,
      sortOrder:    json['sort_order'] as int? ?? 0,
    );
  }
}
