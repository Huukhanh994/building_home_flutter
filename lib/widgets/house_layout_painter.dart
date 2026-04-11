import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HouseLayoutCard extends StatelessWidget {
  final double houseWidth;
  final double houseLength;
  final int floors;

  const HouseLayoutCard({
    super.key,
    required this.houseWidth,
    required this.houseLength,
    required this.floors,
  });

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
                  'Tầng trệt',
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
            height: 200,
            child: CustomPaint(
              painter: _FloorPlanPainter(
                houseWidth: houseWidth,
                houseLength: houseLength,
              ),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 10),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: const [
        _LegendItem(color: Color(0xFF1B7D40), label: 'Tường ngoài'),
        _LegendItem(color: Color(0xFF86EFAC), label: 'Vách ngăn'),
        _LegendItem(color: Color(0xFF3B82F6), label: 'Cửa sổ'),
        _LegendItem(color: Color(0xFFE07B2C), label: 'Cửa ra vào'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 14,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _FloorPlanPainter extends CustomPainter {
  final double houseWidth;
  final double houseLength;

  const _FloorPlanPainter({
    required this.houseWidth,
    required this.houseLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const margin = 36.0;
    final drawW = size.width  - margin * 2;
    final drawH = size.height - margin * 2;

    // Scale keeping aspect ratio
    final aspect = houseWidth / houseLength;
    double rectW, rectH;
    if (aspect > drawW / drawH) {
      rectW = drawW;
      rectH = drawW / aspect;
    } else {
      rectH = drawH;
      rectW = drawH * aspect;
    }

    final left   = (size.width  - rectW) / 2;
    final top    = (size.height - rectH) / 2;
    final right  = left + rectW;
    final bottom = top  + rectH;
    final rect   = Rect.fromLTWH(left, top, rectW, rectH);

    // Floor fill
    canvas.drawRect(
      rect,
      Paint()..color = const Color(0xFFF0FFF4),
    );

    // Grid lines (light)
    final gridPaint = Paint()
      ..color = const Color(0xFFD1FAE5)
      ..strokeWidth = 0.5;
    final gridStep = min(rectW, rectH) / 5;
    for (var x = left + gridStep; x < right; x += gridStep) {
      canvas.drawLine(Offset(x, top), Offset(x, bottom), gridPaint);
    }
    for (var y = top + gridStep; y < bottom; y += gridStep) {
      canvas.drawLine(Offset(left, y), Offset(right, y), gridPaint);
    }

    // Inner room dividers
    final dividerPaint = Paint()
      ..color = const Color(0xFF86EFAC)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final divY = top + rectH * 0.42;
    final divX = left + rectW * 0.55;

    // Horizontal divider (separates living from bedroom zone)
    canvas.drawLine(Offset(left + 2, divY), Offset(right - 2, divY), dividerPaint);
    // Vertical divider (splits upper zone into 2 rooms)
    canvas.drawLine(Offset(divX, top + 2), Offset(divX, divY), dividerPaint);

    // Room labels
    _drawRoomLabel(canvas, 'Phòng khách', Offset(left + rectW * 0.28, divY + rectH * 0.28));
    _drawRoomLabel(canvas, 'Bếp + Ăn', Offset(left + rectW * 0.78, divY + rectH * 0.28));
    _drawRoomLabel(canvas, 'Phòng ngủ 1', Offset(left + rectW * 0.27, top + rectH * 0.2));
    _drawRoomLabel(canvas, 'Phòng ngủ 2', Offset(left + rectW * 0.77, top + rectH * 0.2));

    // Windows — small blue rectangles on walls
    _drawWindow(canvas, Offset(left, top + rectH * 0.22), true);
    _drawWindow(canvas, Offset(right, top + rectH * 0.22), true);
    _drawWindow(canvas, Offset(left + rectW * 0.22, top), false);
    _drawWindow(canvas, Offset(left + rectW * 0.72, top), false);

    // Door — gap + arc on bottom wall center
    final doorW = rectW * 0.14;
    final doorLeft  = left + (rectW - doorW) / 2;
    final doorRight = doorLeft + doorW;

    // Erase gap in bottom wall
    canvas.drawLine(
      Offset(doorLeft, bottom),
      Offset(doorRight, bottom),
      Paint()
        ..color = const Color(0xFFF5F7F4)
        ..strokeWidth = 4,
    );
    // Door swing arc
    canvas.drawArc(
      Rect.fromLTWH(doorLeft, bottom - doorW, doorW, doorW),
      0,
      -pi / 2,
      false,
      Paint()
        ..color = const Color(0xFFE07B2C)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    // Door leaf line
    canvas.drawLine(
      Offset(doorLeft, bottom),
      Offset(doorLeft, bottom - doorW),
      Paint()
        ..color = const Color(0xFFE07B2C)
        ..strokeWidth = 1.5,
    );

    // Outer walls (drawn last so they're on top of everything)
    final wallPaint = Paint()
      ..color = const Color(0xFF1B7D40)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, wallPaint);

    // Dimension labels
    _drawDimLabel(
      canvas,
      '${houseWidth.toStringAsFixed(1)} m',
      Offset(left + rectW / 2, top - 18),
      horizontal: true,
    );
    _drawDimLabel(
      canvas,
      '${houseLength.toStringAsFixed(1)} m',
      Offset(right + 18, top + rectH / 2),
      horizontal: false,
    );

    // North arrow
    _drawNorthArrow(canvas, Offset(left - 26, top + rectH / 2));
  }

  void _drawWindow(Canvas canvas, Offset center, bool vertical) {
    const wLen = 14.0;
    const wDepth = 5.0;
    final rect = vertical
        ? Rect.fromCenter(center: center, width: wDepth, height: wLen)
        : Rect.fromCenter(center: center, width: wLen, height: wDepth);

    canvas.drawRect(rect, Paint()..color = Colors.white);
    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0xFF3B82F6)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    // Center glass line
    if (vertical) {
      canvas.drawLine(
        Offset(center.dx, center.dy - wLen / 2),
        Offset(center.dx, center.dy + wLen / 2),
        Paint()..color = const Color(0xFF93C5FD)..strokeWidth = 1,
      );
    } else {
      canvas.drawLine(
        Offset(center.dx - wLen / 2, center.dy),
        Offset(center.dx + wLen / 2, center.dy),
        Paint()..color = const Color(0xFF93C5FD)..strokeWidth = 1,
      );
    }
  }

  void _drawRoomLabel(Canvas canvas, String text, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 9,
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawDimLabel(Canvas canvas, String text, Offset pos,
      {required bool horizontal}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF1B7D40),
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    if (!horizontal) {
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    } else {
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height));
    }
    canvas.restore();
  }

  void _drawNorthArrow(Canvas canvas, Offset pos) {
    final arrowPaint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 1.5;
    canvas.drawLine(pos, pos - const Offset(0, 16), arrowPaint);
    canvas.drawLine(
        pos - const Offset(0, 16), pos - const Offset(4, 10), arrowPaint);
    canvas.drawLine(
        pos - const Offset(0, 16), pos - const Offset(-4, 10), arrowPaint);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(fontSize: 9, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, 32));
  }

  @override
  bool shouldRepaint(_FloorPlanPainter old) =>
      old.houseWidth != houseWidth || old.houseLength != houseLength;
}
