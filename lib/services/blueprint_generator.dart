import '../models/blueprint_layout.dart';
import '../models/house_type.dart';

/// Generates a generic [BlueprintLayout] for the ground floor based on the
/// house type and total floor count. Used for custom calculator results where
/// no hand-crafted template layout exists.
class BlueprintGenerator {
  BlueprintGenerator._();

  static BlueprintLayout forHouseType(HouseType type, int floors) {
    switch (type) {
      case HouseType.capBon:
        return _capBon();
      case HouseType.twoStory:
        return _twoStory();
      case HouseType.threeStory:
        return _threeStory();
      case HouseType.villa:
        return _villa();
      case HouseType.townhouse:
        return _townhouse();
    }
  }

  // ── Nhà Cấp 4 ── 4-bedroom single-storey, matching Vietnamese floor plan ──
  static BlueprintLayout _capBon() => const BlueprintLayout(
        floorLabel: 'Mặt bằng tổng thể',
        rooms: [
          // ── Top row (h: 0 → 0.47) ──────────────────────────────────────────
          BlueprintRoom(
            label: 'Phòng thờ',
            rect: NormalizedRect(0, 0, 0.14, 0.47),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.altarTable,
                normRect: NormalizedRect(0.08, 0.10, 0.84, 0.45),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Phòng ngủ 3',
            rect: NormalizedRect(0.14, 0, 0.21, 0.47),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.bedDouble,
                normRect: NormalizedRect(0.08, 0.12, 0.84, 0.58),
              ),
              BlueprintFurniture(
                type: FurnitureType.wardrobe,
                normRect: NormalizedRect(0.08, 0.78, 0.84, 0.16),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Phòng ngủ 2',
            rect: NormalizedRect(0.35, 0, 0.21, 0.47),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.bedDouble,
                normRect: NormalizedRect(0.08, 0.12, 0.84, 0.58),
              ),
              BlueprintFurniture(
                type: FurnitureType.wardrobe,
                normRect: NormalizedRect(0.08, 0.78, 0.84, 0.16),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Phòng ngủ 1',
            rect: NormalizedRect(0.56, 0, 0.21, 0.47),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.bedDouble,
                normRect: NormalizedRect(0.08, 0.12, 0.84, 0.58),
              ),
              BlueprintFurniture(
                type: FurnitureType.wardrobe,
                normRect: NormalizedRect(0.08, 0.78, 0.84, 0.16),
              ),
            ],
          ),
          // WC area split into two stacked rooms
          BlueprintRoom(
            label: 'WC 1',
            rect: NormalizedRect(0.77, 0, 0.23, 0.27),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.toilet,
                normRect: NormalizedRect(0.05, 0.05, 0.48, 0.60),
              ),
              BlueprintFurniture(
                type: FurnitureType.sink,
                normRect: NormalizedRect(0.55, 0.05, 0.38, 0.38),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Sân rửa',
            rect: NormalizedRect(0.77, 0.27, 0.23, 0.20),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.bathtub,
                normRect: NormalizedRect(0.06, 0.08, 0.88, 0.84),
              ),
            ],
          ),
          // ── Bottom row (h: 0.47 → 1.0) ─────────────────────────────────────
          BlueprintRoom(
            label: 'Phòng khách',
            rect: NormalizedRect(0, 0.47, 0.35, 0.53),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.sofa,
                normRect: NormalizedRect(0.05, 0.05, 0.90, 0.28),
              ),
              BlueprintFurniture(
                type: FurnitureType.coffeeTable,
                normRect: NormalizedRect(0.22, 0.37, 0.56, 0.20),
              ),
              BlueprintFurniture(
                type: FurnitureType.tvUnit,
                normRect: NormalizedRect(0.05, 0.76, 0.90, 0.16),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Phòng ăn',
            rect: NormalizedRect(0.35, 0.47, 0.21, 0.53),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.diningTable,
                normRect: NormalizedRect(0.08, 0.10, 0.84, 0.80),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Phòng bếp',
            rect: NormalizedRect(0.56, 0.47, 0.21, 0.53),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.stove,
                normRect: NormalizedRect(0.05, 0.05, 0.90, 0.36),
              ),
              BlueprintFurniture(
                type: FurnitureType.sink,
                normRect: NormalizedRect(0.05, 0.55, 0.50, 0.36),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Kho vật dụng',
            rect: NormalizedRect(0.77, 0.47, 0.23, 0.53),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.wardrobe,
                normRect: NormalizedRect(0.05, 0.05, 0.90, 0.38),
              ),
            ],
          ),
        ],
        doors: [
          BlueprintDoor(wall: Wall.bottom, position: 0.18),
        ],
        windows: [
          BlueprintWindow(wall: Wall.top, position: 0.07),
          BlueprintWindow(wall: Wall.top, position: 0.245),
          BlueprintWindow(wall: Wall.top, position: 0.455),
          BlueprintWindow(wall: Wall.top, position: 0.665),
          BlueprintWindow(wall: Wall.bottom, position: 0.18),
          BlueprintWindow(wall: Wall.bottom, position: 0.455),
          BlueprintWindow(wall: Wall.bottom, position: 0.665),
          BlueprintWindow(wall: Wall.left, position: 0.74),
        ],
      );

  // ── Nhà 2 Tầng ── standard Vietnamese tube-house ground floor ─────────────
  static BlueprintLayout _twoStory() => const BlueprintLayout(
        floorLabel: 'Tầng trệt',
        rooms: [
          BlueprintRoom(
            label: 'Phòng khách',
            rect: NormalizedRect(0, 0, 1, 0.35),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.sofa,
                normRect: NormalizedRect(0.05, 0.08, 0.55, 0.35),
              ),
              BlueprintFurniture(
                type: FurnitureType.coffeeTable,
                normRect: NormalizedRect(0.15, 0.50, 0.35, 0.25),
              ),
              BlueprintFurniture(
                type: FurnitureType.tvUnit,
                normRect: NormalizedRect(0.65, 0.10, 0.30, 0.60),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Phòng ngủ 1',
            rect: NormalizedRect(0, 0.35, 0.5, 0.32),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.bedDouble,
                normRect: NormalizedRect(0.08, 0.10, 0.84, 0.60),
              ),
              BlueprintFurniture(
                type: FurnitureType.wardrobe,
                normRect: NormalizedRect(0.08, 0.78, 0.84, 0.16),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Bếp + Ăn',
            rect: NormalizedRect(0.5, 0.35, 0.5, 0.32),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.stove,
                normRect: NormalizedRect(0.05, 0.05, 0.45, 0.40),
              ),
              BlueprintFurniture(
                type: FurnitureType.diningTable,
                normRect: NormalizedRect(0.55, 0.10, 0.40, 0.80),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'WC',
            rect: NormalizedRect(0, 0.67, 0.35, 0.33),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.toilet,
                normRect: NormalizedRect(0.05, 0.05, 0.42, 0.55),
              ),
              BlueprintFurniture(
                type: FurnitureType.sink,
                normRect: NormalizedRect(0.55, 0.05, 0.38, 0.38),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Sảnh thang',
            rect: NormalizedRect(0.35, 0.67, 0.65, 0.33),
          ),
        ],
        doors: [
          BlueprintDoor(wall: Wall.bottom, position: 0.5),
        ],
        windows: [
          BlueprintWindow(wall: Wall.top, position: 0.3),
          BlueprintWindow(wall: Wall.top, position: 0.7),
          BlueprintWindow(wall: Wall.left, position: 0.5),
          BlueprintWindow(wall: Wall.right, position: 0.5),
        ],
      );

  // ── Nhà 3 Tầng ── slightly wider ground plan ──────────────────────────────
  static BlueprintLayout _threeStory() => const BlueprintLayout(
        floorLabel: 'Tầng trệt',
        rooms: [
          BlueprintRoom(
            label: 'Phòng khách',
            rect: NormalizedRect(0, 0, 0.65, 0.38),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.sofa,
                normRect: NormalizedRect(0.05, 0.08, 0.50, 0.35),
              ),
              BlueprintFurniture(
                type: FurnitureType.coffeeTable,
                normRect: NormalizedRect(0.15, 0.48, 0.30, 0.22),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Phòng tiếp khách',
            rect: NormalizedRect(0.65, 0, 0.35, 0.38),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.diningTable,
                normRect: NormalizedRect(0.10, 0.10, 0.80, 0.80),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Phòng ngủ 1',
            rect: NormalizedRect(0, 0.38, 0.45, 0.32),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.bedDouble,
                normRect: NormalizedRect(0.08, 0.10, 0.84, 0.65),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Bếp + Ăn',
            rect: NormalizedRect(0.45, 0.38, 0.55, 0.32),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.stove,
                normRect: NormalizedRect(0.05, 0.08, 0.38, 0.50),
              ),
              BlueprintFurniture(
                type: FurnitureType.sink,
                normRect: NormalizedRect(0.05, 0.65, 0.30, 0.30),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'WC',
            rect: NormalizedRect(0, 0.70, 0.3, 0.30),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.toilet,
                normRect: NormalizedRect(0.05, 0.05, 0.45, 0.55),
              ),
              BlueprintFurniture(
                type: FurnitureType.sink,
                normRect: NormalizedRect(0.55, 0.05, 0.38, 0.38),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Kho / Giặt',
            rect: NormalizedRect(0.3, 0.70, 0.35, 0.30),
          ),
          BlueprintRoom(
            label: 'Sảnh thang',
            rect: NormalizedRect(0.65, 0.70, 0.35, 0.30),
          ),
        ],
        doors: [
          BlueprintDoor(wall: Wall.bottom, position: 0.18),
        ],
        windows: [
          BlueprintWindow(wall: Wall.top, position: 0.3),
          BlueprintWindow(wall: Wall.top, position: 0.75),
          BlueprintWindow(wall: Wall.left, position: 0.55),
          BlueprintWindow(wall: Wall.right, position: 0.2),
          BlueprintWindow(wall: Wall.right, position: 0.55),
        ],
      );

  // ── Biệt Thự ── wider footprint, more rooms ───────────────────────────────
  static BlueprintLayout _villa() => const BlueprintLayout(
        floorLabel: 'Tầng trệt',
        rooms: [
          BlueprintRoom(
            label: 'Phòng khách',
            rect: NormalizedRect(0.2, 0, 0.6, 0.35),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.sofa,
                normRect: NormalizedRect(0.05, 0.08, 0.60, 0.35),
              ),
              BlueprintFurniture(
                type: FurnitureType.coffeeTable,
                normRect: NormalizedRect(0.15, 0.50, 0.35, 0.22),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Sảnh đón',
            rect: NormalizedRect(0, 0, 0.2, 0.35),
          ),
          BlueprintRoom(
            label: 'Văn phòng',
            rect: NormalizedRect(0.8, 0, 0.2, 0.35),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.tvUnit,
                normRect: NormalizedRect(0.08, 0.10, 0.84, 0.45),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Phòng ngủ chính',
            rect: NormalizedRect(0, 0.35, 0.5, 0.35),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.bedDouble,
                normRect: NormalizedRect(0.08, 0.10, 0.84, 0.60),
              ),
              BlueprintFurniture(
                type: FurnitureType.wardrobe,
                normRect: NormalizedRect(0.08, 0.78, 0.84, 0.16),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Bếp + Ăn',
            rect: NormalizedRect(0.5, 0.35, 0.5, 0.35),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.stove,
                normRect: NormalizedRect(0.05, 0.08, 0.38, 0.48),
              ),
              BlueprintFurniture(
                type: FurnitureType.diningTable,
                normRect: NormalizedRect(0.50, 0.10, 0.45, 0.80),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'WC 1',
            rect: NormalizedRect(0, 0.70, 0.25, 0.30),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.toilet,
                normRect: NormalizedRect(0.05, 0.05, 0.45, 0.55),
              ),
              BlueprintFurniture(
                type: FurnitureType.sink,
                normRect: NormalizedRect(0.55, 0.05, 0.38, 0.38),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'WC 2',
            rect: NormalizedRect(0.25, 0.70, 0.25, 0.30),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.bathtub,
                normRect: NormalizedRect(0.06, 0.08, 0.88, 0.84),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Giặt / Phụ',
            rect: NormalizedRect(0.5, 0.70, 0.25, 0.30),
          ),
          BlueprintRoom(
            label: 'Garage',
            rect: NormalizedRect(0.75, 0.70, 0.25, 0.30),
          ),
        ],
        doors: [
          BlueprintDoor(wall: Wall.bottom, position: 0.12),
          BlueprintDoor(wall: Wall.bottom, position: 0.88),
        ],
        windows: [
          BlueprintWindow(wall: Wall.top, position: 0.2),
          BlueprintWindow(wall: Wall.top, position: 0.5),
          BlueprintWindow(wall: Wall.top, position: 0.8),
          BlueprintWindow(wall: Wall.left, position: 0.18),
          BlueprintWindow(wall: Wall.left, position: 0.55),
          BlueprintWindow(wall: Wall.right, position: 0.18),
          BlueprintWindow(wall: Wall.right, position: 0.55),
        ],
      );

  // ── Nhà Phố ── narrow tube-house with garage ──────────────────────────────
  static BlueprintLayout _townhouse() => const BlueprintLayout(
        floorLabel: 'Tầng trệt',
        rooms: [
          BlueprintRoom(
            label: 'Garage / Kinh doanh',
            rect: NormalizedRect(0, 0, 1, 0.28),
          ),
          BlueprintRoom(
            label: 'Phòng khách',
            rect: NormalizedRect(0, 0.28, 1, 0.28),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.sofa,
                normRect: NormalizedRect(0.05, 0.08, 0.55, 0.35),
              ),
              BlueprintFurniture(
                type: FurnitureType.coffeeTable,
                normRect: NormalizedRect(0.15, 0.50, 0.30, 0.25),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Phòng ngủ 1',
            rect: NormalizedRect(0, 0.56, 0.5, 0.26),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.bedDouble,
                normRect: NormalizedRect(0.08, 0.10, 0.84, 0.65),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Bếp + Ăn',
            rect: NormalizedRect(0.5, 0.56, 0.5, 0.26),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.stove,
                normRect: NormalizedRect(0.05, 0.08, 0.38, 0.55),
              ),
              BlueprintFurniture(
                type: FurnitureType.diningTable,
                normRect: NormalizedRect(0.50, 0.10, 0.45, 0.80),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'WC',
            rect: NormalizedRect(0, 0.82, 0.4, 0.18),
            furniture: [
              BlueprintFurniture(
                type: FurnitureType.toilet,
                normRect: NormalizedRect(0.05, 0.05, 0.42, 0.85),
              ),
              BlueprintFurniture(
                type: FurnitureType.sink,
                normRect: NormalizedRect(0.55, 0.05, 0.38, 0.55),
              ),
            ],
          ),
          BlueprintRoom(
            label: 'Sảnh thang',
            rect: NormalizedRect(0.4, 0.82, 0.6, 0.18),
          ),
        ],
        doors: [
          BlueprintDoor(wall: Wall.top, position: 0.5),
          BlueprintDoor(wall: Wall.bottom, position: 0.5),
        ],
        windows: [
          BlueprintWindow(wall: Wall.top, position: 0.25),
          BlueprintWindow(wall: Wall.top, position: 0.75),
          BlueprintWindow(wall: Wall.left, position: 0.4),
          BlueprintWindow(wall: Wall.right, position: 0.4),
        ],
      );
}
