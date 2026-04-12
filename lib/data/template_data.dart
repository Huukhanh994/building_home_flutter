import '../models/blueprint_layout.dart';
import '../models/house_template.dart';
import '../models/house_type.dart';

final List<HouseTemplate> allTemplates = [
  // ── tmpl_01: Nhà Cấp 4 Mái Thái ─────────────────────────────────��───────
  const HouseTemplate(
    id: 'tmpl_01',
    name: 'Nhà Cấp 4 Mái Thái',
    type: HouseType.capBon,
    area: 60,
    floors: 1,
    estimatedCost: 270000000,
    roofStyle: 'Mái Thái',
    description:
        'Thiết kế đơn giản, tiết kiệm, phù hợp vùng nông thôn và ngoại ô.',
    features: [
      'Mái Thái truyền thống',
      '2 phòng ngủ',
      '1 nhà vệ sinh',
      'Phòng khách thông thoáng',
      'Sân vườn rộng',
    ],
    blueprint: BlueprintLayout(
      floorLabel: 'Mặt bằng tổng thể',
      rooms: [
        BlueprintRoom(label: 'Phòng khách', rect: NormalizedRect(0, 0, 1, 0.35)),
        BlueprintRoom(label: 'Phòng ngủ 1', rect: NormalizedRect(0, 0.35, 0.5, 0.38)),
        BlueprintRoom(label: 'Phòng ngủ 2', rect: NormalizedRect(0.5, 0.35, 0.5, 0.38)),
        BlueprintRoom(label: 'WC', rect: NormalizedRect(0, 0.73, 0.38, 0.27)),
        BlueprintRoom(label: 'Kho / Bếp', rect: NormalizedRect(0.38, 0.73, 0.62, 0.27)),
      ],
      doors: [BlueprintDoor(wall: Wall.bottom, position: 0.5)],
      windows: [
        BlueprintWindow(wall: Wall.top, position: 0.25),
        BlueprintWindow(wall: Wall.top, position: 0.75),
        BlueprintWindow(wall: Wall.left, position: 0.54),
        BlueprintWindow(wall: Wall.right, position: 0.54),
      ],
    ),
  ),

  // ── tmpl_02: Nhà Cấp 4 Mái Nhật ─────────────────────────────────────────
  const HouseTemplate(
    id: 'tmpl_02',
    name: 'Nhà Cấp 4 Mái Nhật',
    type: HouseType.capBon,
    area: 72,
    floors: 1,
    estimatedCost: 324000000,
    roofStyle: 'Mái Nhật',
    description:
        'Phong cách Nhật Bản tối giản, bền bỉ với mái dốc nhẹ và vật liệu tự nhiên.',
    features: [
      'Mái Nhật hiện đại',
      '3 phòng ngủ',
      '2 nhà vệ sinh',
      'Bếp mở kiểu Nhật',
      'Hiên gỗ rộng',
    ],
    blueprint: BlueprintLayout(
      floorLabel: 'Mặt bằng tổng thể',
      rooms: [
        BlueprintRoom(label: 'Phòng khách', rect: NormalizedRect(0, 0, 0.6, 0.38)),
        BlueprintRoom(label: 'Bếp + Ăn', rect: NormalizedRect(0.6, 0, 0.4, 0.38)),
        BlueprintRoom(label: 'Phòng ngủ 1', rect: NormalizedRect(0, 0.38, 0.45, 0.35)),
        BlueprintRoom(label: 'Phòng ngủ 2', rect: NormalizedRect(0.45, 0.38, 0.55, 0.35)),
        BlueprintRoom(label: 'Phòng ngủ 3', rect: NormalizedRect(0, 0.73, 0.45, 0.27)),
        BlueprintRoom(label: 'WC 1', rect: NormalizedRect(0.45, 0.73, 0.28, 0.27)),
        BlueprintRoom(label: 'WC 2', rect: NormalizedRect(0.73, 0.73, 0.27, 0.27)),
      ],
      doors: [BlueprintDoor(wall: Wall.bottom, position: 0.22)],
      windows: [
        BlueprintWindow(wall: Wall.top, position: 0.3),
        BlueprintWindow(wall: Wall.top, position: 0.8),
        BlueprintWindow(wall: Wall.left, position: 0.56),
        BlueprintWindow(wall: Wall.right, position: 0.56),
      ],
    ),
  ),

  // ── tmpl_03: Nhà 2 Tầng Hiện Đại ─────────────────────────────────────────
  const HouseTemplate(
    id: 'tmpl_03',
    name: 'Nhà 2 Tầng Hiện Đại',
    type: HouseType.twoStory,
    area: 80,
    floors: 2,
    estimatedCost: 800000000,
    roofStyle: 'Mái Bằng',
    description:
        'Kiến trúc hiện đại, tận dụng tối đa diện tích đất hẹp ở đô thị.',
    features: [
      'Mặt tiền kính hiện đại',
      '4 phòng ngủ',
      '3 nhà vệ sinh',
      'Garage ô tô',
      'Sân thượng BBQ',
    ],
    blueprint: BlueprintLayout(
      floorLabel: 'Tầng trệt',
      rooms: [
        BlueprintRoom(label: 'Garage', rect: NormalizedRect(0, 0, 1, 0.28)),
        BlueprintRoom(label: 'Phòng khách', rect: NormalizedRect(0, 0.28, 0.6, 0.32)),
        BlueprintRoom(label: 'Bếp + Ăn', rect: NormalizedRect(0.6, 0.28, 0.4, 0.32)),
        BlueprintRoom(label: 'Phòng ngủ 1', rect: NormalizedRect(0, 0.60, 0.5, 0.25)),
        BlueprintRoom(label: 'WC', rect: NormalizedRect(0.5, 0.60, 0.5, 0.25)),
        BlueprintRoom(label: 'Sảnh thang', rect: NormalizedRect(0, 0.85, 1, 0.15)),
      ],
      doors: [
        BlueprintDoor(wall: Wall.top, position: 0.5),
        BlueprintDoor(wall: Wall.bottom, position: 0.5),
      ],
      windows: [
        BlueprintWindow(wall: Wall.top, position: 0.2),
        BlueprintWindow(wall: Wall.top, position: 0.75),
        BlueprintWindow(wall: Wall.left, position: 0.44),
        BlueprintWindow(wall: Wall.right, position: 0.44),
      ],
    ),
  ),

  // ── tmpl_04: Nhà 2 Tầng Tân Cổ Điển ──────────────────────────────────────
  const HouseTemplate(
    id: 'tmpl_04',
    name: 'Nhà 2 Tầng Tân Cổ Điển',
    type: HouseType.twoStory,
    area: 100,
    floors: 2,
    estimatedCost: 1000000000,
    roofStyle: 'Mái Thái',
    description:
        'Phong cách tân cổ điển sang trọng với đường nét tinh tế và nội thất cao cấp.',
    features: [
      'Cột trang trí cổ điển',
      '4 phòng ngủ',
      '3 nhà vệ sinh',
      'Phòng thờ',
      'Ban công rộng 2 tầng',
    ],
    blueprint: BlueprintLayout(
      floorLabel: 'Tầng trệt',
      rooms: [
        BlueprintRoom(label: 'Sảnh đón', rect: NormalizedRect(0, 0, 1, 0.22)),
        BlueprintRoom(label: 'Phòng khách', rect: NormalizedRect(0, 0.22, 0.55, 0.32)),
        BlueprintRoom(label: 'Phòng thờ', rect: NormalizedRect(0.55, 0.22, 0.45, 0.32)),
        BlueprintRoom(label: 'Phòng ngủ 1', rect: NormalizedRect(0, 0.54, 0.45, 0.28)),
        BlueprintRoom(label: 'Bếp + Ăn', rect: NormalizedRect(0.45, 0.54, 0.55, 0.28)),
        BlueprintRoom(label: 'WC', rect: NormalizedRect(0, 0.82, 0.35, 0.18)),
        BlueprintRoom(label: 'Sảnh thang', rect: NormalizedRect(0.35, 0.82, 0.65, 0.18)),
      ],
      doors: [
        BlueprintDoor(wall: Wall.bottom, position: 0.5),
      ],
      windows: [
        BlueprintWindow(wall: Wall.top, position: 0.25),
        BlueprintWindow(wall: Wall.top, position: 0.75),
        BlueprintWindow(wall: Wall.left, position: 0.38),
        BlueprintWindow(wall: Wall.right, position: 0.38),
      ],
    ),
  ),

  // ── tmpl_05: Nhà 3 Tầng Phố ───────────────────────────────────────────────
  const HouseTemplate(
    id: 'tmpl_05',
    name: 'Nhà 3 Tầng Phố',
    type: HouseType.threeStory,
    area: 60,
    floors: 3,
    estimatedCost: 990000000,
    roofStyle: 'Mái Bằng',
    description:
        'Tối ưu cho đất mặt phố, tầng trệt kinh doanh, tầng trên để ở.',
    features: [
      'Tầng trệt thương mại',
      '3 phòng ngủ',
      '3 nhà vệ sinh',
      'Tầng thượng thư giãn',
      'Thang máy tùy chọn',
    ],
    blueprint: BlueprintLayout(
      floorLabel: 'Tầng trệt (Kinh doanh)',
      rooms: [
        BlueprintRoom(label: 'Không gian KD', rect: NormalizedRect(0, 0, 1, 0.55)),
        BlueprintRoom(label: 'Kho hàng', rect: NormalizedRect(0, 0.55, 0.45, 0.25)),
        BlueprintRoom(label: 'WC', rect: NormalizedRect(0.45, 0.55, 0.55, 0.25)),
        BlueprintRoom(label: 'Sảnh thang', rect: NormalizedRect(0, 0.80, 1, 0.20)),
      ],
      doors: [
        BlueprintDoor(wall: Wall.top, position: 0.5),
        BlueprintDoor(wall: Wall.bottom, position: 0.5),
      ],
      windows: [
        BlueprintWindow(wall: Wall.top, position: 0.25),
        BlueprintWindow(wall: Wall.top, position: 0.75),
        BlueprintWindow(wall: Wall.left, position: 0.28),
        BlueprintWindow(wall: Wall.right, position: 0.28),
      ],
    ),
  ),

  // ── tmpl_06: Biệt Thự Vườn ────────────────────────────────────────────────
  const HouseTemplate(
    id: 'tmpl_06',
    name: 'Biệt Thự Vườn',
    type: HouseType.villa,
    area: 200,
    floors: 2,
    estimatedCost: 3200000000,
    roofStyle: 'Mái Thái',
    description:
        'Biệt thự sân vườn đẳng cấp với không gian xanh, hồ bơi riêng và thiết kế mở.',
    features: [
      'Hồ bơi riêng',
      '5 phòng ngủ suite',
      '5 nhà vệ sinh',
      'Phòng gym & spa',
      'Garage đôi',
      'Sân vườn cảnh quan',
    ],
    blueprint: BlueprintLayout(
      floorLabel: 'Tầng trệt',
      rooms: [
        BlueprintRoom(label: 'Sảnh đón', rect: NormalizedRect(0.3, 0, 0.4, 0.2)),
        BlueprintRoom(label: 'Phòng khách', rect: NormalizedRect(0, 0, 0.3, 0.42)),
        BlueprintRoom(label: 'Phòng ăn', rect: NormalizedRect(0.3, 0.2, 0.4, 0.22)),
        BlueprintRoom(label: 'Bếp', rect: NormalizedRect(0.7, 0, 0.3, 0.42)),
        BlueprintRoom(label: 'Phòng ngủ chính', rect: NormalizedRect(0, 0.42, 0.42, 0.32)),
        BlueprintRoom(label: 'Phòng ngủ 2', rect: NormalizedRect(0.42, 0.42, 0.58, 0.32)),
        BlueprintRoom(label: 'WC 1', rect: NormalizedRect(0, 0.74, 0.25, 0.26)),
        BlueprintRoom(label: 'WC 2', rect: NormalizedRect(0.25, 0.74, 0.25, 0.26)),
        BlueprintRoom(label: 'Phòng gym', rect: NormalizedRect(0.5, 0.74, 0.3, 0.26)),
        BlueprintRoom(label: 'Garage', rect: NormalizedRect(0.8, 0.74, 0.2, 0.26)),
      ],
      doors: [
        BlueprintDoor(wall: Wall.bottom, position: 0.12),
        BlueprintDoor(wall: Wall.bottom, position: 0.9),
      ],
      windows: [
        BlueprintWindow(wall: Wall.top, position: 0.15),
        BlueprintWindow(wall: Wall.top, position: 0.5),
        BlueprintWindow(wall: Wall.top, position: 0.85),
        BlueprintWindow(wall: Wall.left, position: 0.21),
        BlueprintWindow(wall: Wall.left, position: 0.58),
        BlueprintWindow(wall: Wall.right, position: 0.21),
        BlueprintWindow(wall: Wall.right, position: 0.58),
      ],
    ),
  ),

  // ── tmpl_07: Nhà Phố Thương Mại ───────────────────────────────────────────
  const HouseTemplate(
    id: 'tmpl_07',
    name: 'Nhà Phố Thương Mại',
    type: HouseType.townhouse,
    area: 50,
    floors: 4,
    estimatedCost: 1200000000,
    roofStyle: 'Mái Bằng',
    description:
        'Nhà phố kết hợp kinh doanh và sinh sống, 4 tầng tối ưu hóa không gian.',
    features: [
      'Mặt tiền rộng 5m',
      '4 phòng ngủ',
      '4 nhà vệ sinh',
      'Tầng trệt kinh doanh',
      'Sân thượng tiệc nướng',
    ],
    blueprint: BlueprintLayout(
      floorLabel: 'Tầng trệt',
      rooms: [
        BlueprintRoom(label: 'Mặt tiền KD', rect: NormalizedRect(0, 0, 1, 0.45)),
        BlueprintRoom(label: 'Kho', rect: NormalizedRect(0, 0.45, 0.5, 0.25)),
        BlueprintRoom(label: 'WC', rect: NormalizedRect(0.5, 0.45, 0.5, 0.25)),
        BlueprintRoom(label: 'Sảnh thang', rect: NormalizedRect(0, 0.70, 1, 0.30)),
      ],
      doors: [
        BlueprintDoor(wall: Wall.top, position: 0.5),
        BlueprintDoor(wall: Wall.bottom, position: 0.5),
      ],
      windows: [
        BlueprintWindow(wall: Wall.top, position: 0.3),
        BlueprintWindow(wall: Wall.top, position: 0.7),
        BlueprintWindow(wall: Wall.left, position: 0.56),
        BlueprintWindow(wall: Wall.right, position: 0.56),
      ],
    ),
  ),
];
