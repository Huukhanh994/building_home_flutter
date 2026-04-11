import 'package:flutter/material.dart';

enum HouseType {
  capBon('Nhà Cấp 4', Icons.house_outlined, 4500000),
  twoStory('Nhà 2 Tầng', Icons.apartment_outlined, 5000000),
  threeStory('Nhà 3 Tầng', Icons.business_outlined, 5500000),
  villa('Biệt Thự', Icons.villa_outlined, 8000000),
  townhouse('Nhà Phố', Icons.location_city_outlined, 6000000);

  const HouseType(this.label, this.icon, this.costPerM2);

  final String label;
  final IconData icon;

  /// VND per m²
  final double costPerM2;
}
