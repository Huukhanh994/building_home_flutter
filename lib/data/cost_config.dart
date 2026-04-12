/// Shared cost-split constants used by both [MaterialCalculator] and any UI
/// that displays structural vs finishing breakdown.
class CostConfig {
  CostConfig._();

  /// Fraction of total cost attributed to structural work (phần thô).
  static const double structuralFraction = 0.6;

  /// Fraction of total cost attributed to finishing work (phần hoàn thiện).
  static const double finishingFraction = 0.4;
}
