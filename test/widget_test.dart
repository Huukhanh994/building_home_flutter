import 'package:flutter_test/flutter_test.dart';
import 'package:buildhome_vn/main.dart';
import 'package:buildhome_vn/models/house_type.dart';
import 'package:buildhome_vn/models/project_model.dart';
import 'package:buildhome_vn/services/material_calculator.dart';

void main() {
  group('MaterialCalculator', () {
    test('basic house 10x10, 1 floor', () {
      final project = ProjectModel(
        name: 'Test',
        width: 10,
        length: 10,
        floors: 1,
        houseType: HouseType.capBon,
      );
      final result = MaterialCalculator.calculate(project);

      expect(result.floorArea, equals(100.0));
      expect(result.totalArea, equals(100.0));
      expect(result.steel, equals(9000.0));          // 100 * 90
      expect(result.concrete, equals(25.0));          // 100 * 0.25
      expect(result.sand, closeTo(12.5, 0.01));       // 25 * 0.5
      expect(result.stone, closeTo(20.0, 0.01));      // 25 * 0.8
      expect(result.totalCost, equals(450000000.0));  // 100 * 4_500_000
    });

    test('2 floor house 8x12', () {
      final project = ProjectModel(
        name: 'Test 2T',
        width: 8,
        length: 12,
        floors: 2,
        houseType: HouseType.twoStory,
      );
      final result = MaterialCalculator.calculate(project);

      expect(result.floorArea, equals(96.0));
      expect(result.totalArea, equals(192.0));
      expect(result.structuralCost, equals(result.totalCost * 0.6));
      expect(result.finishingCost, equals(result.totalCost * 0.4));
    });

    test('total cost = structural + finishing', () {
      final project = ProjectModel(
        name: 'Sanity',
        width: 6,
        length: 20,
        floors: 3,
        houseType: HouseType.villa,
      );
      final r = MaterialCalculator.calculate(project);
      expect(r.structuralCost + r.finishingCost, closeTo(r.totalCost, 1.0));
    });
  });

  group('HouseType cost', () {
    test('capBon is cheapest', () {
      expect(
        HouseType.capBon.costPerM2,
        lessThan(HouseType.twoStory.costPerM2),
      );
    });

    test('villa is most expensive', () {
      for (final type in HouseType.values) {
        if (type != HouseType.villa) {
          expect(HouseType.villa.costPerM2,
              greaterThanOrEqualTo(type.costPerM2));
        }
      }
    });
  });
}
