import '../models/house_template.dart';
import '../models/house_type.dart';

final List<HouseTemplate> allTemplates = [
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
  ),
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
  ),
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
  ),
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
  ),
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
  ),
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
  ),
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
  ),
];
