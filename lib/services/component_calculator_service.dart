import '../models/component_estimate.dart';
import '../models/house_component.dart';
import 'buildhome_api_client.dart';

/// Material & cost estimation per structural component.
///
/// Uses Vietnamese regional construction ratios.
/// Structured so the core [calculate] method can be swapped for an HTTP
/// call to the Laravel backend when it is ready — just replace the body
/// with an ApiClient call and return a [ComponentEstimate].
class ComponentCalculatorService {
  const ComponentCalculatorService._();

  static const String _version = 'v1.0';

  // ── Regional cement price (VND / bag 50kg) ───────────────────────────────
  static const double _cementPriceVnd = 90000;
  // ── Sand price (VND / m³) ─────────────────────────────────────────────────
  static const double _sandPriceVnd = 350000;
  // ── Steel price (VND / kg) ────────────────────────────────────────────────
  static const double _steelPriceVnd = 20000;
  // ── Brick price (VND / piece) ─────────────────────────────────────────────
  static const double _brickPriceVnd = 2000;
  // ── Roof tile price (VND / piece) ─────────────────────────────────────────
  static const double _roofTilePriceVnd = 8000;
  // ── Concrete (VND / m³) ───────────────────────────────────────────────────
  static const double _concretePriceVnd = 1500000;

  /// Try the Laravel backend first; fall back to local formulas on any error.
  static Future<ComponentEstimate> calculate(
    HouseComponent component, {
    String houseType = 'thai_roof',
    int floors = 1,
    String location = 'default',
  }) async {
    try {
      final client = BuildhomeApiClient();
      return await client.calculateComponent(
        component: component,
        houseType: houseType,
        floors:    floors,
        location:  location,
      );
    } on Exception {
      // Offline or API unavailable — use local calculation
      return _localEstimate(component);
    }
  }

  // ── Local estimation formulas ─────────────────────────────────────────────

  static ComponentEstimate _localEstimate(HouseComponent component) {
    final area = component.area;

    return switch (component.id) {
      'roof_main' || 'roof_sub' => _roofEstimate(component),
      'wall_front' => _wallEstimate(component),
      'door_main' => _doorEstimate(component),
      'window_front' => _windowEstimate(component),
      'foundation' => _foundationEstimate(component),
      'column' => _columnEstimate(component),
      'balcony' => _balconyEstimate(component),
      'garden' => _gardenEstimate(component),
      _ => _genericEstimate(component, area),
    };
  }

  // Roof: tile + cement mortar bed + steel bracing
  static ComponentEstimate _roofEstimate(HouseComponent component) {
    final area = component.area;
    // 22 tiles/m² for Vietnamese curved tiles
    final tiles = (area * 22).roundToDouble();
    // Mortar: 0.03 m³ cement/m²
    final cementBags = (area * 0.03 * 300 / 50).roundToDouble();
    final sandM3 = (area * 0.03 * 0.5).roundToDouble();
    // Steel bracing: ~4 kg/m²
    final steelKg = (area * 4).roundToDouble();

    final matCost = tiles * _roofTilePriceVnd +
        cementBags * _cementPriceVnd +
        sandM3 * _sandPriceVnd +
        steelKg * _steelPriceVnd;
    final laborCost = area * 120000; // 120k VND/m² labour

    return ComponentEstimate(
      component: component,
      materials: ComponentMaterials(
        roofTile: tiles,
        cement: cementBags,
        sand: sandM3,
        steel: steelKg,
      ),
      cost: ComponentCost(materialCost: matCost, laborCost: laborCost),
      calculationVersion: _version,
    );
  }

  // Wall: brick + mortar + plaster
  static ComponentEstimate _wallEstimate(HouseComponent component) {
    final area = component.area;
    // 60 bricks/m² for 200mm wall
    final bricks = (area * 60).roundToDouble();
    final cementBags = (area * 0.25 * 300 / 50).roundToDouble();
    final sandM3 = (area * 0.06).roundToDouble();

    final matCost = bricks * _brickPriceVnd +
        cementBags * _cementPriceVnd +
        sandM3 * _sandPriceVnd;
    final laborCost = area * 150000;

    return ComponentEstimate(
      component: component,
      materials: ComponentMaterials(
        brick: bricks,
        cement: cementBags,
        sand: sandM3,
      ),
      cost: ComponentCost(materialCost: matCost, laborCost: laborCost),
      calculationVersion: _version,
    );
  }

  // Door: steel door + frame install
  static ComponentEstimate _doorEstimate(HouseComponent component) {
    final area = component.area;
    // Door unit cost: 4M VND/m² (steel door, mid-range)
    final matCost = area * 4000000;
    final laborCost = area * 300000;

    return ComponentEstimate(
      component: component,
      materials: const ComponentMaterials(),
      cost: ComponentCost(materialCost: matCost, laborCost: laborCost),
      calculationVersion: _version,
    );
  }

  // Window: glass + aluminum frame
  static ComponentEstimate _windowEstimate(HouseComponent component) {
    final area = component.area;
    // Aluminum frame window: 2.5M VND/m²
    final matCost = area * 2500000;
    final laborCost = area * 200000;

    return ComponentEstimate(
      component: component,
      materials: const ComponentMaterials(),
      cost: ComponentCost(materialCost: matCost, laborCost: laborCost),
      calculationVersion: _version,
    );
  }

  // Foundation: concrete + steel rebar
  static ComponentEstimate _foundationEstimate(HouseComponent component) {
    final area = component.area;
    // 0.5m³ concrete per m² of foundation section
    final concreteM3 = (area * 0.5).roundToDouble();
    final steelKg = (area * 90).roundToDouble(); // 90 kg/m³ equivalent
    final cementBags = (concreteM3 * 300 / 50).roundToDouble();
    final sandM3 = (concreteM3 * 0.5).roundToDouble();

    final matCost = concreteM3 * _concretePriceVnd +
        steelKg * _steelPriceVnd +
        cementBags * _cementPriceVnd +
        sandM3 * _sandPriceVnd;
    final laborCost = area * 250000;

    return ComponentEstimate(
      component: component,
      materials: ComponentMaterials(
        concrete: concreteM3,
        steel: steelKg,
        cement: cementBags,
        sand: sandM3,
      ),
      cost: ComponentCost(materialCost: matCost, laborCost: laborCost),
      calculationVersion: _version,
    );
  }

  // Column: reinforced concrete
  static ComponentEstimate _columnEstimate(HouseComponent component) {
    final area = component.area;
    final concreteM3 = (area * 0.09).roundToDouble(); // 300×300 cross section
    final steelKg = (area * 120).roundToDouble();
    final cementBags = (concreteM3 * 350 / 50).roundToDouble();

    final matCost = concreteM3 * _concretePriceVnd +
        steelKg * _steelPriceVnd +
        cementBags * _cementPriceVnd;
    final laborCost = area * 300000;

    return ComponentEstimate(
      component: component,
      materials: ComponentMaterials(
        concrete: concreteM3,
        steel: steelKg,
        cement: cementBags,
      ),
      cost: ComponentCost(materialCost: matCost, laborCost: laborCost),
      calculationVersion: _version,
    );
  }

  // Balcony: slab + railing
  static ComponentEstimate _balconyEstimate(HouseComponent component) {
    final area = component.area;
    final concreteM3 = (area * 0.12).roundToDouble();
    final steelKg = (area * 80).roundToDouble();
    final matCost =
        concreteM3 * _concretePriceVnd + steelKg * _steelPriceVnd + area * 500000;
    final laborCost = area * 200000;

    return ComponentEstimate(
      component: component,
      materials: ComponentMaterials(concrete: concreteM3, steel: steelKg),
      cost: ComponentCost(materialCost: matCost, laborCost: laborCost),
      calculationVersion: _version,
    );
  }

  // Garden: landscaping flat rate
  static ComponentEstimate _gardenEstimate(HouseComponent component) {
    final area = component.area;
    final matCost = area * 200000; // 200k VND/m² landscaping
    final laborCost = area * 80000;

    return ComponentEstimate(
      component: component,
      materials: const ComponentMaterials(),
      cost: ComponentCost(materialCost: matCost, laborCost: laborCost),
      calculationVersion: _version,
    );
  }

  static ComponentEstimate _genericEstimate(
      HouseComponent component, double area) {
    final matCost = area * 1000000;
    final laborCost = area * 300000;

    return ComponentEstimate(
      component: component,
      materials: const ComponentMaterials(),
      cost: ComponentCost(materialCost: matCost, laborCost: laborCost),
      calculationVersion: _version,
    );
  }

  /// Aggregate estimates for multiple components (multi-select, Phase 2)
  static Future<List<ComponentEstimate>> calculateMultiple(
      List<HouseComponent> components) async {
    return Future.wait(components.map(calculate));
  }

  static double aggregateTotalCost(List<ComponentEstimate> estimates) =>
      estimates.fold(0.0, (sum, e) => sum + e.cost.total);
}
