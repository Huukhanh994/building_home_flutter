import 'dart:math';
import 'package:flutter/material.dart';
import '../models/blueprint_layout.dart';
import '../models/house_type.dart';
import '../services/blueprint_generator.dart';
import '../theme/app_theme.dart';

/// Displays an architectural floor-plan diagram for [layout].
/// Use [HouseLayoutCard.fromHouseType] for the calculator result view, or
/// pass a custom [BlueprintLayout] for template-specific plans.
class HouseLayoutCard extends StatelessWidget {
  const HouseLayoutCard({
    super.key,
    required this.layout,
    required this.houseWidth,
    required this.houseLength,
  });

  /// Convenience constructor for the custom-calculator results screen.
  factory HouseLayoutCard.fromHouseType({
    Key? key,
    required double houseWidth,
    required double houseLength,
    required int floors,
    required HouseType houseType,
  }) {
    return HouseLayoutCard(
      key: key,
      layout: BlueprintGenerator.forHouseType(houseType, floors),
      houseWidth: houseWidth,
      houseLength: houseLength,
    );
  }

  final BlueprintLayout layout;
  final double houseWidth;
  final double houseLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.architecture_rounded,
                  color: AppColors.green500, size: 20),
              const SizedBox(width: 8),
              Text(
                'Sơ Đồ Mặt Bằng',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.green100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  layout.floorLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.green500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: CustomPaint(
              painter: _FloorPlanPainter(
                layout: layout,
                houseWidth: houseWidth,
                houseLength: houseLength,
              ),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return const Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        _LegendItem(color: Color(0xFF1A1A1A), label: 'Tường ngoài'),
        _LegendItem(color: Color(0xFF444444), label: 'Vách ngăn'),
        _LegendItem(color: Color(0xFF1565C0), label: 'Cửa sổ'),
        _LegendItem(color: Color(0xFF9E9E9E), label: 'Nội thất'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _FloorPlanPainter extends CustomPainter {
  const _FloorPlanPainter({
    required this.layout,
    required this.houseWidth,
    required this.houseLength,
  });

  final BlueprintLayout layout;
  final double houseWidth;
  final double houseLength;

  // Margins leave room for dimension labels outside the house rect
  static const _margin = 42.0;

  // Architectural color palette (monochrome / engineering drawing style)
  static const _bgColor = Color(0xFFEDEDED);
  static const _floorFill = Color(0xFFFFFFFF);
  static const _outerWallColor = Color(0xFF1A1A1A);
  static const _innerWallColor = Color(0xFF333333);
  static const _windowFill = Color(0xFFDCEEFD);
  static const _windowStroke = Color(0xFF1565C0);
  static const _doorColor = Color(0xFF555555);
  static const _furnitureFill = Color(0xFFF0F0F0);
  static const _furnitureStroke = Color(0xFF9E9E9E);
  static const _labelColor = Color(0xFF1A1A1A);
  static const _dimColor = Color(0xFF555555);
  static const _gridColor = Color(0xFFD8D8D8);

  @override
  void paint(Canvas canvas, Size size) {
    final drawW = size.width - _margin * 2;
    final drawH = size.height - _margin * 2;

    // Fit house rectangle preserving aspect ratio
    final aspect = houseWidth / houseLength;
    double rectW, rectH;
    if (aspect > drawW / drawH) {
      rectW = drawW;
      rectH = drawW / aspect;
    } else {
      rectH = drawH;
      rectW = drawH * aspect;
    }

    final left = (size.width - rectW) / 2;
    final top = (size.height - rectH) / 2;
    final houseRect = Rect.fromLTWH(left, top, rectW, rectH);

    // 1. Canvas background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = _bgColor,
    );

    // 2. Floor fill
    canvas.drawRect(houseRect, Paint()..color = _floorFill);

    // 3. Subtle grid
    _drawGrid(canvas, houseRect);

    // 4. Room inner walls, furniture, and labels
    _drawRooms(canvas, houseRect);

    // 5. Windows (drawn before outer wall so they break the wall stroke)
    for (final w in layout.windows) {
      _drawWindow(canvas, houseRect, w);
    }

    // 6. Doors
    for (final d in layout.doors) {
      _drawDoor(canvas, houseRect, d);
    }

    // 7. Outer double-line wall (on top to clean up edges)
    _drawOuterWalls(canvas, houseRect);

    // 8. Dimension lines
    _drawDimensions(canvas, houseRect);

    // 9. North arrow
    _drawNorthArrow(
      canvas,
      Offset(houseRect.left - 30, houseRect.bottom - 20),
    );
  }

  // ── Grid ──────────────────────────────────────────────────────────────────

  void _drawGrid(Canvas canvas, Rect house) {
    final gridPaint = Paint()
      ..color = _gridColor
      ..strokeWidth = 0.5;
    final step = min(house.width, house.height) / 6;
    for (var x = house.left + step; x < house.right; x += step) {
      canvas.drawLine(Offset(x, house.top), Offset(x, house.bottom), gridPaint);
    }
    for (var y = house.top + step; y < house.bottom; y += step) {
      canvas.drawLine(Offset(house.left, y), Offset(house.right, y), gridPaint);
    }
  }

  // ── Outer double-line wall ────────────────────────────────────────────────

  void _drawOuterWalls(Canvas canvas, Rect house) {
    // Outer thick line
    canvas.drawRect(
      house,
      Paint()
        ..color = _outerWallColor
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke,
    );
    // Inner thin line — creates architectural double-wall appearance
    canvas.drawRect(
      house.deflate(5.5),
      Paint()
        ..color = _outerWallColor
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );
  }

  // ── Rooms ─────────────────────────────────────────────────────────────────

  void _drawRooms(Canvas canvas, Rect house) {
    final innerWallPaint = Paint()
      ..color = _innerWallColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw inner wall lines
    for (final room in layout.rooms) {
      final roomRect = _roomToCanvas(room.rect, house);
      final r = room.rect;
      if ((r.left + r.width) < 0.999) {
        canvas.drawLine(roomRect.topRight, roomRect.bottomRight, innerWallPaint);
      }
      if ((r.top + r.height) < 0.999) {
        canvas.drawLine(
            roomRect.bottomLeft, roomRect.bottomRight, innerWallPaint);
      }
      if (r.left > 0.001) {
        canvas.drawLine(roomRect.topLeft, roomRect.bottomLeft, innerWallPaint);
      }
      if (r.top > 0.001) {
        canvas.drawLine(roomRect.topLeft, roomRect.topRight, innerWallPaint);
      }
    }

    // Draw furniture then labels (labels on top)
    for (final room in layout.rooms) {
      final roomRect = _roomToCanvas(room.rect, house);
      for (final item in room.furniture) {
        _drawFurnitureItem(canvas, roomRect, item);
      }
    }
    for (final room in layout.rooms) {
      final roomRect = _roomToCanvas(room.rect, house);
      _drawRoomLabel(canvas, room.label, roomRect);
    }
  }

  Rect _roomToCanvas(NormalizedRect r, Rect house) => Rect.fromLTWH(
        house.left + r.left * house.width,
        house.top + r.top * house.height,
        r.width * house.width,
        r.height * house.height,
      );

  // ── Furniture ─────────────────────────────────────────────────────────────

  void _drawFurnitureItem(
      Canvas canvas, Rect roomRect, BlueprintFurniture item) {
    final r = item.normRect;
    const pad = 3.0;
    final fRect = Rect.fromLTWH(
      roomRect.left + r.left * roomRect.width + pad,
      roomRect.top + r.top * roomRect.height + pad,
      r.width * roomRect.width - pad * 2,
      r.height * roomRect.height - pad * 2,
    );
    if (fRect.width < 6 || fRect.height < 6) return;

    switch (item.type) {
      case FurnitureType.bedDouble:
        _drawBed(canvas, fRect, isDouble: true);
      case FurnitureType.bedSingle:
        _drawBed(canvas, fRect, isDouble: false);
      case FurnitureType.sofa:
        _drawSofa(canvas, fRect);
      case FurnitureType.coffeeTable:
        _drawCoffeeTable(canvas, fRect);
      case FurnitureType.diningTable:
        _drawDiningTable(canvas, fRect);
      case FurnitureType.toilet:
        _drawToilet(canvas, fRect);
      case FurnitureType.bathtub:
        _drawBathtub(canvas, fRect);
      case FurnitureType.sink:
        _drawSink(canvas, fRect);
      case FurnitureType.stove:
        _drawStove(canvas, fRect);
      case FurnitureType.wardrobe:
        _drawWardrobe(canvas, fRect);
      case FurnitureType.tvUnit:
        _drawTVUnit(canvas, fRect);
      case FurnitureType.altarTable:
        _drawAltarTable(canvas, fRect);
    }
  }

  Paint get _fFill => Paint()..color = _furnitureFill;

  Paint get _fStroke => Paint()
    ..color = _furnitureStroke
    ..strokeWidth = 0.7
    ..style = PaintingStyle.stroke;

  void _drawBed(Canvas canvas, Rect r, {required bool isDouble}) {
    canvas.drawRect(r, _fFill);
    canvas.drawRect(r, _fStroke);

    // Pillow area (top 28%)
    final pillowH = r.height * 0.28;
    canvas.drawRect(
      Rect.fromLTWH(r.left, r.top, r.width, pillowH),
      Paint()..color = const Color(0xFFDDDDDD),
    );
    canvas.drawLine(
      Offset(r.left, r.top + pillowH),
      Offset(r.right, r.top + pillowH),
      _fStroke,
    );

    if (isDouble) {
      // Center divider
      canvas.drawLine(
        Offset(r.center.dx, r.top + pillowH),
        Offset(r.center.dx, r.bottom),
        _fStroke,
      );
      // Two pillows
      final pw = r.width * 0.28;
      final ph = pillowH * 0.72;
      final py = r.top + (pillowH - ph) / 2;
      canvas.drawRRect(
        RRect.fromRectXY(Rect.fromLTWH(r.left + 4, py, pw, ph), 2, 2),
        _fStroke,
      );
      canvas.drawRRect(
        RRect.fromRectXY(Rect.fromLTWH(r.right - pw - 4, py, pw, ph), 2, 2),
        _fStroke,
      );
    } else {
      final pw = r.width * 0.70;
      final ph = pillowH * 0.72;
      final py = r.top + (pillowH - ph) / 2;
      canvas.drawRRect(
        RRect.fromRectXY(
          Rect.fromLTWH(r.left + (r.width - pw) / 2, py, pw, ph),
          2,
          2,
        ),
        _fStroke,
      );
    }
  }

  void _drawSofa(Canvas canvas, Rect r) {
    canvas.drawRect(r, _fFill);
    canvas.drawRect(r, _fStroke);

    // Backrest (top 28%)
    final backH = r.height * 0.28;
    canvas.drawRect(
      Rect.fromLTWH(r.left, r.top, r.width, backH),
      Paint()..color = const Color(0xFFDDDDDD),
    );
    canvas.drawLine(
      Offset(r.left, r.top + backH),
      Offset(r.right, r.top + backH),
      _fStroke,
    );

    // Armrests
    final armW = r.width * 0.10;
    canvas.drawRect(
      Rect.fromLTWH(r.left, r.top + backH, armW, r.height - backH),
      Paint()..color = const Color(0xFFDDDDDD),
    );
    canvas.drawLine(
      Offset(r.left + armW, r.top + backH),
      Offset(r.left + armW, r.bottom),
      _fStroke,
    );
    canvas.drawRect(
      Rect.fromLTWH(r.right - armW, r.top + backH, armW, r.height - backH),
      Paint()..color = const Color(0xFFDDDDDD),
    );
    canvas.drawLine(
      Offset(r.right - armW, r.top + backH),
      Offset(r.right - armW, r.bottom),
      _fStroke,
    );
  }

  void _drawCoffeeTable(Canvas canvas, Rect r) {
    canvas.drawOval(r, _fFill);
    canvas.drawOval(r, _fStroke);
  }

  void _drawDiningTable(Canvas canvas, Rect r) {
    canvas.drawOval(r.deflate(6), _fFill);
    canvas.drawOval(r.deflate(6), _fStroke);

    // Chairs
    final cx = r.center.dx;
    final cy = r.center.dy;
    final radX = r.width / 2 + 2;
    final radY = r.height / 2 + 2;
    final cSize = min(r.width, r.height) * 0.13;

    for (final angle in [0.0, pi / 2, pi, 3 * pi / 2]) {
      final cc =
          Offset(cx + radX * cos(angle), cy + radY * sin(angle));
      canvas.drawCircle(cc, cSize, _fFill);
      canvas.drawCircle(cc, cSize, _fStroke);
    }
    if (r.height > r.width * 0.8) {
      for (final angle in [pi * 0.33, pi * 0.67, pi * 1.33, pi * 1.67]) {
        final cc =
            Offset(cx + radX * cos(angle), cy + radY * sin(angle));
        canvas.drawCircle(cc, cSize * 0.85, _fFill);
        canvas.drawCircle(cc, cSize * 0.85, _fStroke);
      }
    }
  }

  void _drawToilet(Canvas canvas, Rect r) {
    final tankH = r.height * 0.32;
    // Tank
    canvas.drawRect(
      Rect.fromLTWH(r.left + r.width * 0.06, r.top, r.width * 0.88, tankH),
      _fFill,
    );
    canvas.drawRect(
      Rect.fromLTWH(r.left + r.width * 0.06, r.top, r.width * 0.88, tankH),
      _fStroke,
    );
    // Bowl
    final bowlRect =
        Rect.fromLTWH(r.left, r.top + tankH, r.width, r.height - tankH);
    canvas.drawOval(bowlRect, _fFill);
    canvas.drawOval(bowlRect, _fStroke);
    canvas.drawOval(bowlRect.deflate(4), _fStroke);
  }

  void _drawBathtub(Canvas canvas, Rect r) {
    canvas.drawRect(r, _fFill);
    canvas.drawRect(r, _fStroke);
    canvas.drawOval(r.deflate(5), _fStroke);
    // Drain
    canvas.drawCircle(
      Offset(r.left + r.width * 0.84, r.center.dy),
      2.5,
      _fStroke,
    );
  }

  void _drawSink(Canvas canvas, Rect r) {
    canvas.drawRect(r, _fFill);
    canvas.drawRect(r, _fStroke);
    canvas.drawOval(r.deflate(4), _fStroke);
    canvas.drawCircle(r.center, 2, _fStroke);
  }

  void _drawStove(Canvas canvas, Rect r) {
    canvas.drawRect(r, _fFill);
    canvas.drawRect(r, _fStroke);
    final br = min(r.width, r.height) * 0.16;
    final burners = [
      Offset(r.left + r.width * 0.28, r.top + r.height * 0.28),
      Offset(r.left + r.width * 0.72, r.top + r.height * 0.28),
      Offset(r.left + r.width * 0.28, r.top + r.height * 0.72),
      Offset(r.left + r.width * 0.72, r.top + r.height * 0.72),
    ];
    for (final pos in burners) {
      canvas.drawCircle(pos, br, _fFill);
      canvas.drawCircle(pos, br, _fStroke);
      canvas.drawCircle(pos, br * 0.45, _fStroke);
    }
  }

  void _drawWardrobe(Canvas canvas, Rect r) {
    canvas.drawRect(r, _fFill);
    canvas.drawRect(r, _fStroke);
    canvas.drawLine(
      Offset(r.center.dx, r.top),
      Offset(r.center.dx, r.bottom),
      _fStroke,
    );
    canvas.drawCircle(Offset(r.center.dx - 5, r.center.dy), 1.5, _fStroke);
    canvas.drawCircle(Offset(r.center.dx + 5, r.center.dy), 1.5, _fStroke);
  }

  void _drawTVUnit(Canvas canvas, Rect r) {
    canvas.drawRect(r, _fFill);
    canvas.drawRect(r, _fStroke);
    canvas.drawRect(r.deflate(3), _fStroke);
  }

  void _drawAltarTable(Canvas canvas, Rect r) {
    canvas.drawRect(r, _fFill);
    canvas.drawRect(r, _fStroke);
    canvas.drawRect(r.deflate(4), _fStroke);
    canvas.drawCircle(r.center, 3, _fStroke);
  }

  // ── Windows ───────────────────────────────────────────────────────────────

  void _drawWindow(Canvas canvas, Rect house, BlueprintWindow w) {
    const wLen = 20.0;
    const wDepth = 7.0;
    final Offset center;
    final bool vertical;

    switch (w.wall) {
      case Wall.top:
        center = Offset(house.left + w.position * house.width, house.top);
        vertical = false;
      case Wall.bottom:
        center = Offset(house.left + w.position * house.width, house.bottom);
        vertical = false;
      case Wall.left:
        center = Offset(house.left, house.top + w.position * house.height);
        vertical = true;
      case Wall.right:
        center = Offset(house.right, house.top + w.position * house.height);
        vertical = true;
    }

    final rect = vertical
        ? Rect.fromCenter(center: center, width: wDepth, height: wLen)
        : Rect.fromCenter(center: center, width: wLen, height: wDepth);

    // Erase wall section
    canvas.drawRect(rect.inflate(1.5), Paint()..color = _floorFill);

    // Window fill
    canvas.drawRect(rect, Paint()..color = _windowFill);

    // Three parallel lines (standard architectural window symbol)
    final lp = Paint()
      ..color = _windowStroke
      ..strokeWidth = 0.9;

    if (vertical) {
      for (final xOff in [-wDepth / 4, 0.0, wDepth / 4]) {
        canvas.drawLine(
          Offset(center.dx + xOff, center.dy - wLen / 2),
          Offset(center.dx + xOff, center.dy + wLen / 2),
          lp,
        );
      }
    } else {
      for (final yOff in [-wDepth / 4, 0.0, wDepth / 4]) {
        canvas.drawLine(
          Offset(center.dx - wLen / 2, center.dy + yOff),
          Offset(center.dx + wLen / 2, center.dy + yOff),
          lp,
        );
      }
    }

    // Border
    canvas.drawRect(
      rect,
      Paint()
        ..color = _windowStroke
        ..strokeWidth = 0.9
        ..style = PaintingStyle.stroke,
    );
  }

  // ── Doors ─────────────────────────────────────────────────────────────────

  void _drawDoor(Canvas canvas, Rect house, BlueprintDoor d) {
    const doorFrac = 0.13;
    final Offset hinge;
    final double swing;
    final bool horizontal;

    switch (d.wall) {
      case Wall.bottom:
        final cx = house.left + d.position * house.width;
        final dw = house.width * doorFrac;
        hinge = Offset(cx - dw / 2, house.bottom);
        swing = dw;
        horizontal = true;
      case Wall.top:
        final cx = house.left + d.position * house.width;
        final dw = house.width * doorFrac;
        hinge = Offset(cx - dw / 2, house.top);
        swing = dw;
        horizontal = true;
      case Wall.left:
        final cy = house.top + d.position * house.height;
        final dh = house.height * doorFrac;
        hinge = Offset(house.left, cy - dh / 2);
        swing = dh;
        horizontal = false;
      case Wall.right:
        final cy = house.top + d.position * house.height;
        final dh = house.height * doorFrac;
        hinge = Offset(house.right, cy - dh / 2);
        swing = dh;
        horizontal = false;
    }

    final gapPaint = Paint()
      ..color = _floorFill
      ..strokeWidth = 5.5
      ..style = PaintingStyle.stroke;
    final arcPaint = Paint()
      ..color = _doorColor
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
    final leafPaint = Paint()
      ..color = _doorColor
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    if (horizontal) {
      canvas.drawLine(hinge, Offset(hinge.dx + swing, hinge.dy), gapPaint);
      canvas.drawLine(hinge, Offset(hinge.dx, hinge.dy - swing), leafPaint);
      canvas.drawArc(
        Rect.fromLTWH(hinge.dx, hinge.dy - swing, swing, swing),
        0,
        -pi / 2,
        false,
        arcPaint,
      );
    } else {
      canvas.drawLine(hinge, Offset(hinge.dx, hinge.dy + swing), gapPaint);
      canvas.drawLine(hinge, Offset(hinge.dx + swing, hinge.dy), leafPaint);
      canvas.drawArc(
        Rect.fromLTWH(hinge.dx, hinge.dy, swing, swing),
        pi,
        pi / 2,
        false,
        arcPaint,
      );
    }
  }

  // ── Room label ────────────────────────────────────────────────────────────

  void _drawRoomLabel(Canvas canvas, String text, Rect roomRect) {
    final upperText = text.toUpperCase();
    final fontSize = roomRect.shortestSide < 32 ? 6.5 : 8.0;
    final maxW = max(roomRect.width - 6, 12.0);

    final tp = TextPainter(
      text: TextSpan(
        text: upperText,
        style: TextStyle(
          fontSize: fontSize,
          color: _labelColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          height: 1.25,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: maxW);

    // Center vertically in bottom 60% of room (furniture often fills top area)
    final dy = roomRect.center.dy - tp.height / 2;
    final dx = roomRect.center.dx - tp.width / 2;
    tp.paint(canvas, Offset(dx, dy));
  }

  // ── Dimension lines ───────────────────────────────────────────────────────

  void _drawDimensions(Canvas canvas, Rect house) {
    final dimPaint = Paint()
      ..color = _dimColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const extLen = 6.0;
    const dimGap = 20.0;

    // ── Top dimension (width) ──
    final topY = house.top - dimGap;
    canvas.drawLine(Offset(house.left, topY), Offset(house.right, topY), dimPaint);
    // Extension lines
    canvas.drawLine(
        Offset(house.left, house.top - 3), Offset(house.left, topY + extLen), dimPaint);
    canvas.drawLine(
        Offset(house.right, house.top - 3), Offset(house.right, topY + extLen), dimPaint);
    // Tick marks
    _drawTick(canvas, Offset(house.left, topY), isHorizontal: true, paint: dimPaint);
    _drawTick(canvas, Offset(house.right, topY), isHorizontal: true, paint: dimPaint);
    // Label
    _drawDimText(
      canvas,
      '${houseWidth.toStringAsFixed(1)} m',
      Offset(house.center.dx, topY - 2),
      horizontal: true,
    );

    // ── Right dimension (length) ──
    final rightX = house.right + dimGap;
    canvas.drawLine(Offset(rightX, house.top), Offset(rightX, house.bottom), dimPaint);
    // Extension lines
    canvas.drawLine(
        Offset(house.right + 3, house.top), Offset(rightX - extLen, house.top), dimPaint);
    canvas.drawLine(
        Offset(house.right + 3, house.bottom), Offset(rightX - extLen, house.bottom), dimPaint);
    // Tick marks
    _drawTick(canvas, Offset(rightX, house.top), isHorizontal: false, paint: dimPaint);
    _drawTick(canvas, Offset(rightX, house.bottom), isHorizontal: false, paint: dimPaint);
    // Label
    _drawDimText(
      canvas,
      '${houseLength.toStringAsFixed(1)} m',
      Offset(rightX + 2, house.center.dy),
      horizontal: false,
    );
  }

  void _drawTick(
      Canvas canvas, Offset pos,
      {required bool isHorizontal, required Paint paint}) {
    const half = 5.0;
    if (isHorizontal) {
      // 45° tick on horizontal dim line
      canvas.drawLine(
        Offset(pos.dx - 2.5, pos.dy - half),
        Offset(pos.dx + 2.5, pos.dy + half),
        paint,
      );
    } else {
      canvas.drawLine(
        Offset(pos.dx - half, pos.dy - 2.5),
        Offset(pos.dx + half, pos.dy + 2.5),
        paint,
      );
    }
  }

  void _drawDimText(Canvas canvas, String text, Offset pos,
      {required bool horizontal}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 9.5,
          color: _dimColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    if (!horizontal) {
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height));
    } else {
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height));
    }
    canvas.restore();
  }

  // ── North arrow ───────────────────────────────────────────────────────────

  void _drawNorthArrow(Canvas canvas, Offset pos) {
    final paint = Paint()
      ..color = const Color(0xFF888888)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const arrowLen = 16.0;
    canvas.drawLine(pos, pos - Offset(0, arrowLen), paint);
    canvas.drawLine(
        pos - Offset(0, arrowLen), pos - const Offset(4, arrowLen - 6), paint);
    canvas.drawLine(
        pos - Offset(0, arrowLen), pos - const Offset(-4, arrowLen - 6), paint);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(
          fontSize: 9,
          color: Color(0xFF888888),
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, arrowLen + tp.height + 2));
  }

  @override
  bool shouldRepaint(_FloorPlanPainter old) =>
      old.layout != layout ||
      old.houseWidth != houseWidth ||
      old.houseLength != houseLength;
}
