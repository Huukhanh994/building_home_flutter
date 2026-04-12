import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../models/material_estimate.dart';
import '../services/history_service.dart';
import '../services/pdf_exporter.dart';
import '../services/premium_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/house_layout_painter.dart';

class ResultsScreen extends StatefulWidget {
  final MaterialEstimate estimate;

  const ResultsScreen({super.key, required this.estimate});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  static final _vnd = NumberFormat('#,###', 'vi_VN');
  static final _num = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    HistoryService.save(widget.estimate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết Quả'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Xuất PDF',
            onPressed: () => _handleExport(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryCard(context),
            const SizedBox(height: 14),
            HouseLayoutCard.fromHouseType(
              houseWidth: widget.estimate.project.width,
              houseLength: widget.estimate.project.length,
              floors: widget.estimate.project.floors,
              houseType: widget.estimate.project.houseType,
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
    final proj = widget.estimate.project;
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
                Icon(proj.houseType.icon,
                    color: AppColors.green500, size: 36),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _metricItem(context,
                    '${proj.width}×${proj.length} m', 'Rộng × Dài'),
                _vDivider(),
                _metricItem(
                    context,
                    '${widget.estimate.floorArea.toStringAsFixed(1)} m²',
                    'Sàn/tầng'),
                _vDivider(),
                _metricItem(
                    context,
                    '${widget.estimate.totalArea.toStringAsFixed(1)} m²',
                    'Tổng sàn'),
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
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 32, color: AppColors.divider);

  // ── Materials ─────────────────────────────────────────────────────────────

  Widget _buildMaterialCard(BuildContext context) {
    final e = widget.estimate;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(context, 'Vật Liệu Ước Tính', Icons.hardware_outlined),
          const SizedBox(height: 12),
          _matRow(Icons.settings_outlined, 'Thép',
              '${_num.format(e.steel.toInt())} kg', Colors.grey),
          _matRow(Icons.water_drop_outlined, 'Bê tông',
              '${e.concrete.toStringAsFixed(2)} m³', Colors.blue),
          _matRow(Icons.inventory_2_outlined, 'Xi măng',
              '${e.cement.toInt()} túi (50 kg)', Colors.brown),
          _matRow(Icons.waves_outlined, 'Cát',
              '${e.sand.toStringAsFixed(2)} m³', Colors.amber),
          _matRow(Icons.circle_outlined, 'Đá dăm',
              '${e.stone.toStringAsFixed(2)} m³', Colors.blueGrey),
          _matRow(Icons.grid_on_outlined, 'Gạch nung',
              '${_num.format(e.bricks)} viên', AppColors.orange500),
        ],
      ),
    );
  }

  Widget _matRow(
      IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Costs ─────────────────────────────────────────────────────────────────

  Widget _buildCostCard(BuildContext context) {
    final e = widget.estimate;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(context, 'Chi Phí Ước Tính',
              Icons.monetization_on_outlined),
          const SizedBox(height: 12),
          _costRow('Phần thô (kết cấu)', e.structuralCost, bold: false),
          _costRow('Phần hoàn thiện', e.finishingCost, bold: false),
          const Divider(height: 20, color: AppColors.divider),
          _costRow('Tổng cộng', e.totalCost, bold: true),
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

  // ── Export ────────────────────────────────────────────────────────────────

  Widget _buildExportButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _handleExport(context),
      icon: const Icon(Icons.upload_file_rounded),
      label: const Text('Xuất Báo Cáo PDF'),
    );
  }

  Future<void> _handleExport(BuildContext context) async {
    final isPremium = await PremiumService.instance.isPremium();
    if (!context.mounted) return;
    if (!isPremium) {
      _showPaywall(context);
      return;
    }
    await _exportPdf(context);
  }

  Future<void> _exportPdf(BuildContext context) async {
    try {
      final bytes = await PdfExporter.generate(widget.estimate);
      if (!context.mounted) return;
      await Printing.sharePdf(
          bytes: bytes, filename: 'buildhome_estimate.pdf');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xuất PDF: $e')),
      );
    }
  }

  void _showPaywall(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _PaywallSheet(),
    );
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

// ── Paywall bottom sheet ──────────────────────────────────────────────────────

class _PaywallSheet extends StatelessWidget {
  const _PaywallSheet();

  static const _features = [
    'Xuất báo cáo PDF chuyên nghiệp',
    'Lưu & so sánh nhiều dự toán',
    'Hệ số giá theo vùng miền',
    'Bản vẽ mặt bằng chi tiết theo mẫu',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.green100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: AppColors.green500, size: 32),
            ),
            const SizedBox(height: 16),
            Text('BuildHome Premium',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Mở khóa toàn bộ tính năng chuyên nghiệp',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ..._features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.green500, size: 18),
                    const SizedBox(width: 10),
                    Text(f,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _PurchaseButton(),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Để sau'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Purchase button (stateful for loading state) ──────────────────────────────

class _PurchaseButton extends StatefulWidget {
  @override
  State<_PurchaseButton> createState() => _PurchaseButtonState();
}

class _PurchaseButtonState extends State<_PurchaseButton> {
  bool _loading = false;

  Future<void> _onTap() async {
    setState(() => _loading = true);
    try {
      final success = await PremiumService.instance.purchase();
      if (!mounted) return;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Không thể kết nối cửa hàng. Vui lòng thử lại sau.')),
        );
      }
      // On success the purchase stream handles the unlock and the user
      // will see premium content once the sheet is dismissed.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : _onTap,
        child: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text('Nâng Cấp Premium'),
      ),
    );
  }
}
