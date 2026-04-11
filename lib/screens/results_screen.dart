import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../models/material_estimate.dart';
import '../services/pdf_exporter.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/house_layout_painter.dart';

class ResultsScreen extends StatelessWidget {
  final MaterialEstimate estimate;

  const ResultsScreen({super.key, required this.estimate});

  static final _vnd = NumberFormat('#,###', 'vi_VN');
  static final _num = NumberFormat('#,###', 'vi_VN');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết Quả'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Xuất PDF',
            onPressed: () => _exportPdf(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryCard(context),
            const SizedBox(height: 14),
            HouseLayoutCard(
              houseWidth: estimate.project.width,
              houseLength: estimate.project.length,
              floors: estimate.project.floors,
            ),
            const SizedBox(height: 14),
            _buildMaterialCard(context),
            const SizedBox(height: 14),
            _buildCostCard(context),
            const SizedBox(height: 14),
            _buildDisclaimer(context),
            const SizedBox(height: 16),
            _buildExportButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Summary ───────────────────────────────────────────────────────────────

  Widget _buildSummaryCard(BuildContext context) {
    final proj = estimate.project;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proj.name.isEmpty ? 'Công trình của bạn' : proj.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${proj.houseType.label} · ${proj.floors} tầng',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Icon(proj.houseType.icon, color: AppColors.green500, size: 36),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _metricItem(context, '${proj.width}×${proj.length} m', 'Rộng × Dài'),
                _vDivider(),
                _metricItem(context, '${estimate.floorArea.toStringAsFixed(1)} m²', 'Sàn/tầng'),
                _vDivider(),
                _metricItem(context, '${estimate.totalArea.toStringAsFixed(1)} m²', 'Tổng sàn'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricItem(BuildContext context, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() {
    return Container(width: 1, height: 32, color: AppColors.divider);
  }

  // ── Materials ─────────────────────────────────────────────────────────────

  Widget _buildMaterialCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(context, 'Vật Liệu Ước Tính', Icons.hardware_outlined),
          const SizedBox(height: 12),
          _matRow(Icons.settings_outlined, 'Thép', '${_num.format(estimate.steel.toInt())} kg', Colors.grey),
          _matRow(Icons.water_drop_outlined, 'Bê tông', '${estimate.concrete.toStringAsFixed(2)} m³', Colors.blue),
          _matRow(Icons.inventory_2_outlined, 'Xi măng', '${estimate.cement.toInt()} túi (50 kg)', Colors.brown),
          _matRow(Icons.waves_outlined, 'Cát', '${estimate.sand.toStringAsFixed(2)} m³', Colors.amber),
          _matRow(Icons.circle_outlined, 'Đá dăm', '${estimate.stone.toStringAsFixed(2)} m³', Colors.blueGrey),
          _matRow(Icons.grid_on_outlined, 'Gạch nung', '${_num.format(estimate.bricks)} viên', AppColors.orange500),
        ],
      ),
    );
  }

  Widget _matRow(IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ── Costs ─────────────────────────────────────────────────────────────────

  Widget _buildCostCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(context, 'Chi Phí Ước Tính', Icons.monetization_on_outlined),
          const SizedBox(height: 12),
          _costRow('Phần thô (kết cấu)', estimate.structuralCost, bold: false),
          _costRow('Phần hoàn thiện', estimate.finishingCost, bold: false),
          const Divider(height: 20, color: AppColors.divider),
          _costRow('Tổng cộng', estimate.totalCost, bold: true),
        ],
      ),
    );
  }

  Widget _costRow(String label, double amount, {required bool bold}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: bold ? 15 : 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: bold ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '${_vnd.format(amount.toInt())} đ',
            style: TextStyle(
              fontSize: bold ? 16 : 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: bold ? AppColors.green500 : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Disclaimer ────────────────────────────────────────────────────────────

  Widget _buildDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.orange100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.orange500, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Số liệu chỉ mang tính tham khảo. Không thay thế tư vấn kỹ sư chuyên nghiệp.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.orange500),
            ),
          ),
        ],
      ),
    );
  }

  // ── Export button ─────────────────────────────────────────────────────────

  Widget _buildExportButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _exportPdf(context),
      icon: const Icon(Icons.upload_file_rounded),
      label: const Text('Xuất Báo Cáo PDF'),
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    try {
      final bytes = await PdfExporter.generate(estimate);
      if (!context.mounted) return;
      await Printing.sharePdf(bytes: bytes, filename: 'buildhome_estimate.pdf');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xuất PDF: $e')),
      );
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _cardHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.green500, size: 20),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
