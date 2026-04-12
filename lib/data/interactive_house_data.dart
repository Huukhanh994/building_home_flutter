import '../models/house_component.dart';

/// House style variants supported by the interactive viewer
enum InteractiveHouseStyle {
  thaiRoof1Floor,
  thaiRoof2Floor,
  japaneseRoof,
  gardenVilla,
}

extension InteractiveHouseStyleX on InteractiveHouseStyle {
  String get label => switch (this) {
        InteractiveHouseStyle.thaiRoof1Floor => 'Mái Thái 1 Tầng',
        InteractiveHouseStyle.thaiRoof2Floor => 'Mái Thái 2 Tầng',
        InteractiveHouseStyle.japaneseRoof => 'Mái Nhật',
        InteractiveHouseStyle.gardenVilla => 'Biệt Thự Sân Vườn',
      };

  int get floors => switch (this) {
        InteractiveHouseStyle.thaiRoof2Floor => 2,
        InteractiveHouseStyle.gardenVilla => 2,
        _ => 1,
      };

  String get houseTypeKey => switch (this) {
        InteractiveHouseStyle.thaiRoof1Floor => 'thai_roof',
        InteractiveHouseStyle.thaiRoof2Floor => 'thai_roof',
        InteractiveHouseStyle.japaneseRoof => 'japanese_roof',
        InteractiveHouseStyle.gardenVilla => 'garden_villa',
      };
}

/// Component definitions for each house style.
/// Areas are representative defaults (m²) for a 6m × 10m footprint.
/// Replace with user-provided dimensions when available.
class InteractiveHouseData {
  InteractiveHouseData._();

  static const _defaultWidth = 6.0; // metres
  static const _defaultLength = 10.0; // metres

  static List<HouseComponent> componentsFor(
    InteractiveHouseStyle style, {
    double width = _defaultWidth,
    double length = _defaultLength,
    int? floors,
  }) {
    final f = floors ?? style.floors;
    final footprint = width * length;
    final perimeter = 2 * (width + length);
    final wallHeight = 3.2; // m per floor
    final wallArea = perimeter * wallHeight * f;

    return switch (style) {
      InteractiveHouseStyle.thaiRoof1Floor ||
      InteractiveHouseStyle.thaiRoof2Floor ||
      InteractiveHouseStyle.japaneseRoof =>
        _standardComponents(
          footprint: footprint,
          wallArea: wallArea,
          perimeter: perimeter,
          floors: f,
          hasSubRoof: style == InteractiveHouseStyle.thaiRoof1Floor ||
              style == InteractiveHouseStyle.thaiRoof2Floor,
        ),
      InteractiveHouseStyle.gardenVilla => _villaComponents(
          footprint: footprint,
          wallArea: wallArea,
          perimeter: perimeter,
        ),
    };
  }

  static List<HouseComponent> _standardComponents({
    required double footprint,
    required double wallArea,
    required double perimeter,
    required int floors,
    required bool hasSubRoof,
  }) {
    // Roof area ≈ footprint × 1.35 slope factor for pitched roof
    final roofArea = footprint * 1.35;
    // Sub-roof overhang band ≈ perimeter × 0.8
    final subRoofArea = hasSubRoof ? perimeter * 0.8 : 0.0;
    // Net wall area minus openings (~20%)
    final netWallArea = wallArea * 0.80;
    // Door: standard 0.9m × 2.1m = 1.89 m²
    const doorArea = 1.89;
    // Window: 1.2m × 1.2m each, assume 4 windows
    const windowArea = 1.2 * 1.2 * 4;
    // Foundation: perimeter × 0.5m depth section
    final foundationArea = perimeter * 0.5;
    // Column: 0.3m × 0.3m × 3.2m × number of columns (~8)
    final columnArea = 0.3 * 3.2 * 8;

    return [
      HouseComponent(
        id: 'roof_main',
        label: 'Mái chính',
        group: ComponentGroup.roof,
        area: roofArea,
        unit: 'm2',
      ),
      if (hasSubRoof)
        HouseComponent(
          id: 'roof_sub',
          label: 'Mái phụ (diềm)',
          group: ComponentGroup.roof,
          area: subRoofArea,
          unit: 'm2',
        ),
      HouseComponent(
        id: 'wall_front',
        label: 'Tường bao',
        group: ComponentGroup.wallSystem,
        area: netWallArea,
        unit: 'm2',
      ),
      HouseComponent(
        id: 'door_main',
        label: 'Cửa chính',
        group: ComponentGroup.wallSystem,
        area: doorArea,
        unit: 'm2',
      ),
      HouseComponent(
        id: 'window_front',
        label: 'Cửa sổ',
        group: ComponentGroup.wallSystem,
        area: windowArea,
        unit: 'm2',
      ),
      HouseComponent(
        id: 'column',
        label: 'Cột',
        group: ComponentGroup.structure,
        area: columnArea,
        unit: 'm2',
      ),
      HouseComponent(
        id: 'foundation',
        label: 'Móng',
        group: ComponentGroup.structure,
        area: foundationArea,
        unit: 'm2',
      ),
    ];
  }

  static List<HouseComponent> _villaComponents({
    required double footprint,
    required double wallArea,
    required double perimeter,
  }) {
    final roofArea = footprint * 1.4;
    final netWallArea = wallArea * 0.75;
    final gardenArea = footprint * 1.5;

    return [
      HouseComponent(
        id: 'roof_main',
        label: 'Mái chính',
        group: ComponentGroup.roof,
        area: roofArea,
        unit: 'm2',
      ),
      HouseComponent(
        id: 'wall_front',
        label: 'Tường bao',
        group: ComponentGroup.wallSystem,
        area: netWallArea,
        unit: 'm2',
      ),
      HouseComponent(
        id: 'door_main',
        label: 'Cửa chính',
        group: ComponentGroup.wallSystem,
        area: 2.4,
        unit: 'm2',
      ),
      HouseComponent(
        id: 'window_front',
        label: 'Cửa sổ',
        group: ComponentGroup.wallSystem,
        area: 1.44 * 6,
        unit: 'm2',
      ),
      HouseComponent(
        id: 'balcony',
        label: 'Ban công',
        group: ComponentGroup.exterior,
        area: footprint * 0.15,
        unit: 'm2',
      ),
      HouseComponent(
        id: 'foundation',
        label: 'Móng',
        group: ComponentGroup.structure,
        area: perimeter * 0.6,
        unit: 'm2',
      ),
      HouseComponent(
        id: 'garden',
        label: 'Sân vườn',
        group: ComponentGroup.exterior,
        area: gardenArea,
        unit: 'm2',
      ),
    ];
  }
}
