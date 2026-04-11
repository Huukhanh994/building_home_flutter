import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/material_estimate.dart';

class PdfExporter {
  PdfExporter._();

  static final _vnd = NumberFormat('#,###', 'vi_VN');
  static final _num = NumberFormat('#,###', 'vi_VN');

  /// Returns raw PDF bytes — no file I/O, works on all Android versions.
  static Future<Uint8List> generate(MaterialEstimate estimate) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    final greenDark  = PdfColor.fromHex('#1B7D40');
    final greenLight = PdfColor.fromHex('#DCF0E6');
    final orange     = PdfColor.fromHex('#E07B2C');
    final bgGray     = PdfColor.fromHex('#F5F7F4');
    final textSec    = PdfColor.fromHex('#6B7280');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => [
          _header(greenDark, font, fontBold),
          pw.SizedBox(height: 20),
          _projectSection(estimate, font, fontBold, greenDark, greenLight, bgGray),
          pw.SizedBox(height: 14),
          _layoutSection(estimate, font, fontBold, greenDark, greenLight),
          pw.SizedBox(height: 14),
          _materialSection(estimate, font, fontBold, greenDark, greenLight, bgGray),
          pw.SizedBox(height: 14),
          _costSection(estimate, font, fontBold, greenDark, greenLight, bgGray, orange),
          pw.SizedBox(height: 20),
          _disclaimer(font, textSec, orange),
        ],
        footer: (ctx) => _footer(font, textSec),
      ),
    );

    return pdf.save();
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  static pw.Widget _header(PdfColor green, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [PdfColor.fromHex('#1B7D40'), PdfColor.fromHex('#2EA055')],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('BuildHome VN',
                  style: pw.TextStyle(font: fontBold, fontSize: 22, color: PdfColors.white)),
              pw.SizedBox(height: 4),
              pw.Text('Bao Cao Uoc Tinh Vat Lieu Xay Dung',
                  style: pw.TextStyle(
                      font: font, fontSize: 12, color: PdfColor(1, 1, 1, 0.7))),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section title ────────────────────────────────────────────────────────────

  static pw.Widget _sectionTitle(
    String title,
    pw.Font fontBold,
    PdfColor green,
    PdfColor greenLight,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: greenLight,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(title,
          style: pw.TextStyle(font: fontBold, fontSize: 12, color: green)),
    );
  }

  // ── Data row ─────────────────────────────────────────────────────────────────

  static pw.Widget _row(
    String label,
    String value,
    pw.Font font,
    pw.Font fontBold,
    PdfColor bgGray, {
    bool isAlt = false,
    bool isBold = false,
  }) {
    return pw.Container(
      color: isAlt ? bgGray : PdfColors.white,
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: font, fontSize: 11, color: PdfColor.fromHex('#374151'))),
          pw.Text(value,
              style: pw.TextStyle(
                font: isBold ? fontBold : font,
                fontSize: isBold ? 12 : 11,
                color: isBold
                    ? PdfColor.fromHex('#1B7D40')
                    : PdfColors.black,
              )),
        ],
      ),
    );
  }

  // ── Project section ───────────────────────────────────────────────────────────

  static pw.Widget _projectSection(
    MaterialEstimate e,
    pw.Font font,
    pw.Font fontBold,
    PdfColor green,
    PdfColor greenLight,
    PdfColor bgGray,
  ) {
    final proj = e.project;
    final rows = [
      ['Ten cong trinh', proj.name.isEmpty ? 'Chua dat ten' : proj.name],
      ['Loai nha', proj.houseType.label],
      ['Kich thuoc', '${proj.width.toStringAsFixed(1)} m x ${proj.length.toStringAsFixed(1)} m'],
      ['So tang', '${proj.floors} tang'],
      ['Dien tich san/tang', '${e.floorArea.toStringAsFixed(1)} m2'],
      ['Tong dien tich san', '${e.totalArea.toStringAsFixed(1)} m2'],
    ];
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('THONG TIN CONG TRINH', fontBold, green, greenLight),
        ...rows.asMap().entries.map((entry) => _row(
              entry.value[0], entry.value[1], font, fontBold, bgGray,
              isAlt: entry.key.isEven)),
      ],
    );
  }

  // ── Layout diagram section ────────────────────────────────────────────────────
  // Text labels are pw.Text widgets (need Context); only geometry goes in painter.

  static pw.Widget _layoutSection(
    MaterialEstimate e,
    pw.Font font,
    pw.Font fontBold,
    PdfColor green,
    PdfColor greenLight,
  ) {
    final proj = e.project;
    final dimStyle = pw.TextStyle(font: font, fontSize: 8, color: green);
    final grayStyle = pw.TextStyle(font: font, fontSize: 7, color: PdfColors.grey);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('SO DO MAT BANG (TANG TRET)', fontBold, green, greenLight),
        // Width label
        pw.Center(
          child: pw.Text(
            '<-- ${proj.width.toStringAsFixed(1)} m -->',
            style: dimStyle,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // North indicator
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('N', style: grayStyle),
                pw.Text('^', style: grayStyle),
              ],
            ),
            pw.SizedBox(width: 6),
            // Floor plan drawing
            pw.Expanded(
              child: pw.SizedBox(
                height: 120,
                child: pw.CustomPaint(
                  painter: (canvas, size) {
                    _drawFloorPlan(canvas, size, proj.width, proj.length, green);
                  },
                ),
              ),
            ),
            pw.SizedBox(width: 4),
            // Length label (rotated)
            pw.Transform.rotateBox(
              angle: 3.14159 / 2,
              child: pw.Text(
                '<-- ${proj.length.toStringAsFixed(1)} m -->',
                style: dimStyle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static void _drawFloorPlan(
    PdfGraphics canvas,
    PdfPoint size,
    double houseW,
    double houseL,
    PdfColor green,
  ) {
    const margin = 8.0;
    final drawW = size.x - margin * 2;
    final drawH = size.y - margin * 2;

    // Scale keeping aspect ratio
    final aspect = houseW / houseL;
    double rectW, rectH;
    if (aspect > drawW / drawH) {
      rectW = drawW;
      rectH = drawW / aspect;
    } else {
      rectH = drawH;
      rectW = drawH * aspect;
    }

    final left   = (size.x - rectW) / 2;
    final top    = (size.y - rectH) / 2;
    final right  = left + rectW;
    final bottom = top + rectH;

    // Floor fill
    canvas
      ..setFillColor(PdfColor.fromHex('#F0FFF4'))
      ..drawRect(left, top, rectW, rectH)
      ..fillPath();

    // Inner room dividers
    final divY = top + rectH * 0.42;
    final divX = left + rectW * 0.55;
    canvas
      ..setStrokeColor(PdfColor.fromHex('#86EFAC'))
      ..setLineWidth(1)
      ..drawLine(left + 2, divY, right - 2, divY)
      ..strokePath();
    canvas
      ..setStrokeColor(PdfColor.fromHex('#86EFAC'))
      ..setLineWidth(1)
      ..drawLine(divX, top + 2, divX, divY)
      ..strokePath();

    // Windows
    _drawWindow(canvas, left, top + rectH * 0.25, true);
    _drawWindow(canvas, right, top + rectH * 0.25, true);
    _drawWindow(canvas, left + rectW * 0.25, top, false);

    // Door gap + leaf on bottom wall center
    final doorW = rectW * 0.15;
    final doorLeft = left + (rectW - doorW) / 2;
    final doorRight = doorLeft + doorW;
    canvas
      ..setStrokeColor(PdfColors.white)
      ..setLineWidth(4)
      ..drawLine(doorLeft, bottom, doorRight, bottom)
      ..strokePath();
    canvas
      ..setStrokeColor(PdfColor.fromHex('#E07B2C'))
      ..setLineWidth(1.5)
      ..drawLine(doorLeft, bottom, doorLeft, bottom - doorW)
      ..strokePath();
    // Door arc (quarter circle)
    canvas
      ..setStrokeColor(PdfColor.fromHex('#E07B2C'))
      ..setLineWidth(1)
      ..drawEllipse(doorLeft, bottom - doorW, doorW, doorW)
      ..strokePath();

    // Outer walls (on top)
    canvas
      ..setStrokeColor(green)
      ..setLineWidth(3)
      ..drawRect(left, top, rectW, rectH)
      ..strokePath();
  }

  static void _drawWindow(
    PdfGraphics canvas,
    double wx,
    double wy,
    bool vertical,
  ) {
    const wSize = 10.0;
    const wDepth = 4.0;
    canvas.setStrokeColor(PdfColor.fromHex('#3B82F6'));
    canvas.setLineWidth(2);
    if (vertical) {
      canvas.drawRect(wx - wDepth / 2, wy - wSize / 2, wDepth, wSize);
    } else {
      canvas.drawRect(wx - wSize / 2, wy - wDepth / 2, wSize, wDepth);
    }
    canvas.strokePath();
  }

  // ── Material section ──────────────────────────────────────────────────────────

  static pw.Widget _materialSection(
    MaterialEstimate e,
    pw.Font font,
    pw.Font fontBold,
    PdfColor green,
    PdfColor greenLight,
    PdfColor bgGray,
  ) {
    final rows = [
      ['Thep', '${_num.format(e.steel.toInt())} kg'],
      ['Be tong', '${e.concrete.toStringAsFixed(2)} m3'],
      ['Xi mang', '${e.cement.toInt()} tui (50 kg/tui)'],
      ['Cat', '${e.sand.toStringAsFixed(2)} m3'],
      ['Da dam', '${e.stone.toStringAsFixed(2)} m3'],
      ['Gach nung', '${_num.format(e.bricks)} vien'],
    ];
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('VAT LIEU UOC TINH', fontBold, green, greenLight),
        ...rows.asMap().entries.map((entry) => _row(
              entry.value[0], entry.value[1], font, fontBold, bgGray,
              isAlt: entry.key.isEven)),
      ],
    );
  }

  // ── Cost section ──────────────────────────────────────────────────────────────

  static pw.Widget _costSection(
    MaterialEstimate e,
    pw.Font font,
    pw.Font fontBold,
    PdfColor green,
    PdfColor greenLight,
    PdfColor bgGray,
    PdfColor orange,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('UOC TINH CHI PHI', fontBold, green, greenLight),
        _row('Phan tho (ket cau)',
            '${_vnd.format(e.structuralCost.toInt())} d', font, fontBold, bgGray, isAlt: false),
        _row('Phan hoan thien',
            '${_vnd.format(e.finishingCost.toInt())} d', font, fontBold, bgGray, isAlt: true),
        pw.Divider(thickness: 1, color: PdfColor.fromHex('#E5E7EB')),
        _row('TONG CONG', '${_vnd.format(e.totalCost.toInt())} d',
            font, fontBold, bgGray, isBold: true),
      ],
    );
  }

  // ── Disclaimer & footer ───────────────────────────────────────────────────────

  static pw.Widget _disclaimer(pw.Font font, PdfColor textSec, PdfColor orange) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFF7F0'),
        border: pw.Border(left: pw.BorderSide(color: orange, width: 3)),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text(
        '* So lieu chi mang tinh chat tham khao. Khong thay the tu van ky thuat cua ky su xay dung chuyen nghiep.',
        style: pw.TextStyle(font: font, fontSize: 9, color: textSec),
      ),
    );
  }

  static pw.Widget _footer(pw.Font font, PdfColor textSec) {
    final date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('BuildHome VN',
            style: pw.TextStyle(font: font, fontSize: 9, color: textSec)),
        pw.Text('Ngay xuat: $date',
            style: pw.TextStyle(font: font, fontSize: 9, color: textSec)),
      ],
    );
  }
}
