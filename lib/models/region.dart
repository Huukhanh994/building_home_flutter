/// Vietnamese construction cost regions.
/// Multiplier is applied on top of the base [HouseType.costPerM2].
enum Region {
  hcm('TP. Hồ Chí Minh', 1.15),
  hn('Hà Nội', 1.10),
  mienTrung('Miền Trung', 1.0),
  mienNam('Miền Nam (tỉnh)', 0.95),
  other('Khác / Nông thôn', 0.90);

  const Region(this.label, this.multiplier);

  final String label;

  /// Cost multiplier relative to the base price (1.0 = no adjustment).
  final double multiplier;
}
