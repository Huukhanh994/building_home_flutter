import 'package:flutter/material.dart';
import '../data/interactive_house_data.dart';
import '../models/house_component.dart';

// ── Hit-test region tied to a component ──────────────────────────────────────

class _ComponentRegion {
  _ComponentRegion({required this.component, required this.path});

  final HouseComponent component;
  final Path path;

  bool contains(Offset point) => path.contains(point);
}

// ── Colors for each component group ──────────────────────────────────────────

Color _baseColor(String componentId) => switch (componentId) {
      'roof_main' => const Color(0xFF8B4513),
      'roof_sub' => const Color(0xFFA0522D),
      'wall_front' => const Color(0xFFF5DEB3),
      'door_main' => const Color(0xFF6B3A2A),
      'window_front' => const Color(0xFF87CEEB),
      'column' => const Color(0xFFD2B48C),
      'foundation' => const Color(0xFF808080),
      'balcony' => const Color(0xFFDEB887),
      'garden' => const Color(0xFF90EE90),
      _ => const Color(0xFFCCCCCC),
    };

const _selectedColor = Color(0xFF1B7D40);
const _highlightOpacity = 0.85;
const _baseOpacity = 0.92;

// ── Painter ───────────────────────────────────────────────────────────────────

/// Draws a schematic front-elevation of a Vietnamese house.
/// Supports Thai roof (1 & 2 floor), Japanese roof, and garden villa styles.
/// Provides hit-testing for component tap detection.
class InteractiveHousePainter extends CustomPainter {
  InteractiveHousePainter({
    required this.style,
    required this.components,
    this.selectedComponentId,
  });

  final InteractiveHouseStyle style;
  final List<HouseComponent> components;
  final String? selectedComponentId;

  // Built during paint, used for hit testing
  final List<_ComponentRegion> _regions = [];

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns the component at [point] or null if none matched.
  HouseComponent? componentAt(Offset point) {
    // Reversed so top-drawn (last) elements have priority
    for (final region in _regions.reversed) {
      if (region.contains(point)) return region.component;
    }
    return null;
  }

  // ── Paint ─────────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    _regions.clear();

    switch (style) {
      case InteractiveHouseStyle.thaiRoof1Floor:
        _drawThaiRoof1Floor(canvas, size);
      case InteractiveHouseStyle.thaiRoof2Floor:
        _drawThaiRoof2Floor(canvas, size);
      case InteractiveHouseStyle.japaneseRoof:
        _drawJapaneseRoof(canvas, size);
      case InteractiveHouseStyle.gardenVilla:
        _drawGardenVilla(canvas, size);
    }

    // Decorative label
    _drawLabel(canvas, size, style.label);
  }

  @override
  bool shouldRepaint(InteractiveHousePainter old) =>
      old.selectedComponentId != selectedComponentId ||
      old.style != style ||
      old.components != components;

  // ── House Drawing Routines ────────────────────────────────────────────────

  void _drawThaiRoof1Floor(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Layout proportions (normalized to size)
    final foundationTop = h * 0.85;
    final wallBottom = foundationTop;
    final wallTop = h * 0.48;
    final wallLeft = w * 0.08;
    final wallRight = w * 0.92;

    // Foundation
    final foundationPath = Path()
      ..addRect(Rect.fromLTRB(wallLeft, foundationTop, wallRight, h * 0.98));
    _drawRegion(canvas, 'foundation', foundationPath);

    // Wall
    final wallPath = Path()
      ..addRect(Rect.fromLTRB(wallLeft, wallTop, wallRight, wallBottom));
    _drawRegion(canvas, 'wall_front', wallPath);

    // Door (centre of wall)
    final doorW = w * 0.14;
    final doorH = h * 0.28;
    final doorL = (w - doorW) / 2;
    final doorT = wallBottom - doorH;
    final doorPath = Path()
      ..addRRect(RRect.fromLTRBR(
          doorL, doorT, doorL + doorW, wallBottom, const Radius.circular(4)));
    _drawRegion(canvas, 'door_main', doorPath);

    // Windows (two either side of door)
    final winW = w * 0.12;
    final winH = h * 0.14;
    final winT = wallTop + h * 0.10;
    // Left window
    final winLPath = Path()
      ..addRect(Rect.fromLTWH(wallLeft + w * 0.06, winT, winW, winH));
    _drawRegion(canvas, 'window_front', winLPath);
    // Right window — same region id so both highlight together
    final winRPath = Path()
      ..addRect(
          Rect.fromLTWH(wallRight - w * 0.06 - winW, winT, winW, winH));
    _addRegionPath(canvas, 'window_front', winRPath);

    // Roof sub (overhang band, Thai style)
    final subRoofT = wallTop - h * 0.06;
    final subRoofPath = Path()
      ..addRect(Rect.fromLTRB(wallLeft - w * 0.04, subRoofT,
          wallRight + w * 0.04, wallTop));
    _drawRegion(canvas, 'roof_sub', subRoofPath);

    // Roof main (peaked Thai shape)
    final roofPeak = Offset(w / 2, h * 0.04);
    final roofPath = Path()
      ..moveTo(wallLeft - w * 0.06, subRoofT)
      ..quadraticBezierTo(w / 2, h * -0.02, wallRight + w * 0.06, subRoofT)
      ..lineTo(wallRight + w * 0.06, subRoofT)
      ..lineTo(roofPeak.dx, roofPeak.dy)
      ..lineTo(wallLeft - w * 0.06, subRoofT)
      ..close();
    _drawRegion(canvas, 'roof_main', roofPath);
  }

  void _drawThaiRoof2Floor(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final foundationTop = h * 0.88;
    final floor1Bottom = foundationTop;
    final floor1Top = h * 0.60;
    final floor2Top = h * 0.38;
    final wallLeft = w * 0.10;
    final wallRight = w * 0.90;

    // Foundation
    _drawRegion(
      canvas,
      'foundation',
      Path()
        ..addRect(Rect.fromLTRB(wallLeft, foundationTop, wallRight, h * 0.98)),
    );

    // Wall (both floors combined region)
    final wallPath = Path()
      ..addRect(Rect.fromLTRB(wallLeft, floor2Top, wallRight, floor1Bottom));
    _drawRegion(canvas, 'wall_front', wallPath);

    // 2nd floor balcony slab
    final balconyPath = Path()
      ..addRect(
          Rect.fromLTRB(wallLeft - w * 0.02, floor2Top, wallRight + w * 0.02,
              floor2Top + h * 0.03));
    _drawRegion(canvas, 'balcony', balconyPath);

    // Door ground floor
    final doorW = w * 0.14;
    final doorH = h * 0.20;
    final doorL = (w - doorW) / 2;
    final doorT = floor1Bottom - doorH;
    _drawRegion(
      canvas,
      'door_main',
      Path()
        ..addRRect(RRect.fromLTRBR(
            doorL, doorT, doorL + doorW, floor1Bottom, const Radius.circular(4))),
    );

    // Windows — floor 1
    final win1W = w * 0.10;
    final win1H = h * 0.11;
    final win1T = floor1Top + (floor2Top - floor1Top) * 0.3;
    _drawRegion(
        canvas,
        'window_front',
        Path()
          ..addRect(Rect.fromLTWH(wallLeft + w * 0.06, win1T, win1W, win1H)));
    _addRegionPath(
        canvas,
        'window_front',
        Path()
          ..addRect(Rect.fromLTWH(
              wallRight - w * 0.06 - win1W, win1T, win1W, win1H)));

    // Windows — floor 2
    final win2T = floor2Top + h * 0.06;
    _addRegionPath(
        canvas,
        'window_front',
        Path()
          ..addRect(Rect.fromLTWH(wallLeft + w * 0.06, win2T, win1W, win1H)));
    _addRegionPath(
        canvas,
        'window_front',
        Path()
          ..addRect(Rect.fromLTWH(
              wallRight - w * 0.06 - win1W, win2T, win1W, win1H)));

    // Sub roof overhang
    final subT = floor2Top - h * 0.05;
    _drawRegion(
      canvas,
      'roof_sub',
      Path()
        ..addRect(
            Rect.fromLTRB(wallLeft - w * 0.04, subT, wallRight + w * 0.04,
                floor2Top)),
    );

    // Main roof
    final roofPath = Path()
      ..moveTo(wallLeft - w * 0.06, subT)
      ..quadraticBezierTo(w / 2, h * 0.01, wallRight + w * 0.06, subT)
      ..lineTo(w / 2, h * 0.06)
      ..close();
    _drawRegion(canvas, 'roof_main', roofPath);
  }

  void _drawJapaneseRoof(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final foundationTop = h * 0.85;
    final wallTop = h * 0.46;
    final wallLeft = w * 0.08;
    final wallRight = w * 0.92;

    _drawRegion(
        canvas,
        'foundation',
        Path()
          ..addRect(
              Rect.fromLTRB(wallLeft, foundationTop, wallRight, h * 0.98)));

    _drawRegion(
        canvas,
        'wall_front',
        Path()
          ..addRect(Rect.fromLTRB(wallLeft, wallTop, wallRight, foundationTop)));

    // Door
    final doorW = w * 0.13;
    final doorH = h * 0.26;
    final doorL = (w - doorW) / 2;
    _drawRegion(
        canvas,
        'door_main',
        Path()
          ..addRRect(RRect.fromLTRBR(doorL, foundationTop - doorH,
              doorL + doorW, foundationTop, const Radius.circular(2))));

    // Windows — slightly narrower, Japanese proportion
    final winW = w * 0.11;
    final winH = h * 0.12;
    final winT = wallTop + h * 0.09;
    _drawRegion(
        canvas,
        'window_front',
        Path()..addRect(Rect.fromLTWH(wallLeft + w * 0.07, winT, winW, winH)));
    _addRegionPath(
        canvas,
        'window_front',
        Path()
          ..addRect(
              Rect.fromLTWH(wallRight - w * 0.07 - winW, winT, winW, winH)));

    // Japanese roof — flatter pitch with curved eaves
    final eaveH = h * 0.08;
    final eaveT = wallTop - eaveH;
    final eavePath = Path()
      ..addRect(
          Rect.fromLTRB(wallLeft - w * 0.05, eaveT, wallRight + w * 0.05,
              wallTop));
    _drawRegion(canvas, 'roof_sub', eavePath);

    // Roof main — gentler slope
    final roofPath = Path()
      ..moveTo(wallLeft - w * 0.07, eaveT)
      ..quadraticBezierTo(w / 2, h * 0.06, wallRight + w * 0.07, eaveT)
      ..lineTo(w / 2, h * 0.12)
      ..close();
    _drawRegion(canvas, 'roof_main', roofPath);
  }

  void _drawGardenVilla(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final foundationTop = h * 0.85;
    final floor2Top = h * 0.42;
    final wallLeft = w * 0.06;
    final wallRight = w * 0.94;

    // Garden strip
    _drawRegion(
        canvas,
        'garden',
        Path()
          ..addRect(Rect.fromLTRB(0, foundationTop + h * 0.04, w, h * 0.98)));

    _drawRegion(
        canvas,
        'foundation',
        Path()
          ..addRect(
              Rect.fromLTRB(wallLeft, foundationTop, wallRight, foundationTop + h * 0.04)));

    // Wall body
    _drawRegion(
        canvas,
        'wall_front',
        Path()
          ..addRect(Rect.fromLTRB(wallLeft, floor2Top, wallRight, foundationTop)));

    // Balcony slab
    final balconyTop = floor2Top + h * 0.01;
    _drawRegion(
        canvas,
        'balcony',
        Path()
          ..addRect(Rect.fromLTRB(wallLeft - w * 0.03, balconyTop,
              wallRight + w * 0.03, balconyTop + h * 0.03)));

    // Large entrance door
    final doorW = w * 0.18;
    final doorH = h * 0.28;
    final doorL = (w - doorW) / 2;
    _drawRegion(
        canvas,
        'door_main',
        Path()
          ..addRRect(RRect.fromLTRBR(doorL, foundationTop - doorH,
              doorL + doorW, foundationTop, const Radius.circular(6))));

    // Wide panoramic windows
    final winH = h * 0.12;
    final winT = floor2Top + h * 0.06;
    _drawRegion(
        canvas,
        'window_front',
        Path()
          ..addRect(Rect.fromLTWH(wallLeft + w * 0.04, winT, w * 0.18, winH)));
    _addRegionPath(
        canvas,
        'window_front',
        Path()
          ..addRect(Rect.fromLTWH(
              wallRight - w * 0.04 - w * 0.18, winT, w * 0.18, winH)));

    // Flat/hip roof
    final roofPath = Path()
      ..moveTo(wallLeft - w * 0.05, floor2Top)
      ..lineTo(w * 0.15, h * 0.12)
      ..lineTo(w * 0.85, h * 0.12)
      ..lineTo(wallRight + w * 0.05, floor2Top)
      ..close();
    _drawRegion(canvas, 'roof_main', roofPath);
  }

  // ── Drawing Helpers ───────────────────────────────────────────────────────

  void _drawRegion(Canvas canvas, String id, Path path) {
    final component = _componentById(id);
    if (component == null) return;

    final isSelected = id == selectedComponentId;
    final base = _baseColor(id);
    final color =
        isSelected ? _selectedColor : base.withValues(alpha: _baseOpacity);

    // Fill
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: isSelected ? _highlightOpacity : _baseOpacity)
        ..style = PaintingStyle.fill,
    );

    // Stroke
    canvas.drawPath(
      path,
      Paint()
        ..color = isSelected
            ? _selectedColor.withValues(alpha: 1)
            : Colors.black.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.5 : 1.0,
    );

    _regions.add(_ComponentRegion(component: component, path: path));
  }

  /// Adds an additional path to an existing component region (e.g. right window).
  void _addRegionPath(Canvas canvas, String id, Path path) {
    final component = _componentById(id);
    if (component == null) return;

    final isSelected = id == selectedComponentId;
    final base = _baseColor(id);
    final color = isSelected ? _selectedColor : base;

    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: isSelected ? _highlightOpacity : _baseOpacity)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = isSelected
            ? _selectedColor.withValues(alpha: 1)
            : Colors.black.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.5 : 1.0,
    );

    _regions.add(_ComponentRegion(component: component, path: path));
  }

  HouseComponent? _componentById(String id) {
    try {
      return components.firstWhere((c) => c.id == id);
    } on StateError {
      return null;
    }
  }

  void _drawLabel(Canvas canvas, Size size, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.width - tp.width) / 2, size.height - 14));
  }
}

// ── Widget wrapper ────────────────────────────────────────────────────────────

/// Interactive widget that wraps [InteractiveHousePainter] and dispatches
/// component tap events.
class InteractiveHouseView extends StatefulWidget {
  const InteractiveHouseView({
    super.key,
    required this.style,
    required this.components,
    required this.onComponentTapped,
    this.selectedComponentId,
    this.height = 320,
  });

  final InteractiveHouseStyle style;
  final List<HouseComponent> components;
  final ValueChanged<HouseComponent> onComponentTapped;
  final String? selectedComponentId;
  final double height;

  @override
  State<InteractiveHouseView> createState() => _InteractiveHouseViewState();
}

class _InteractiveHouseViewState extends State<InteractiveHouseView> {
  late InteractiveHousePainter _painter;

  @override
  void initState() {
    super.initState();
    _rebuildPainter();
  }

  @override
  void didUpdateWidget(InteractiveHouseView old) {
    super.didUpdateWidget(old);
    if (old.style != widget.style ||
        old.components != widget.components ||
        old.selectedComponentId != widget.selectedComponentId) {
      _rebuildPainter();
    }
  }

  void _rebuildPainter() {
    _painter = InteractiveHousePainter(
      style: widget.style,
      components: widget.components,
      selectedComponentId: widget.selectedComponentId,
    );
  }

  void _handleTap(TapUpDetails details) {
    // Convert global tap to local canvas coordinates
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    final hit = _painter.componentAt(local);
    if (hit != null) widget.onComponentTapped(hit);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _handleTap,
      child: CustomPaint(
        painter: _painter,
        child: SizedBox(
          width: double.infinity,
          height: widget.height,
        ),
      ),
    );
  }
}
