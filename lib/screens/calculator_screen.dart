import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/house_type.dart';
import '../models/project_model.dart';
import '../services/material_calculator.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import 'results_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController   = TextEditingController();
  final _widthController  = TextEditingController();
  final _lengthController = TextEditingController();

  int _floors           = 1;
  HouseType _houseType  = HouseType.twoStory;

  double? get _width  => double.tryParse(_widthController.text);
  double? get _length => double.tryParse(_lengthController.text);

  bool get _isValid =>
      (_width ?? 0) > 0 && (_length ?? 0) > 0;

  double get _liveArea =>
      (_width ?? 0) * (_length ?? 0) * _floors;

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tính Vật Liệu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFormCard(context),
              const SizedBox(height: 16),
              _buildCalculateButton(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Form Card ─────────────────────────────────────────────────────────────

  Widget _buildFormCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project name
          _sectionLabel('Tên Công Trình (tuỳ chọn)'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'VD: Nhà anh Tùng, Ba Vì',
            ),
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 20),
          _sectionLabel('Kích Thước Mặt Bằng (m)'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _dimensionField(
                  controller: _widthController,
                  label: 'Chiều rộng',
                  hint: '0.0',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dimensionField(
                  controller: _lengthController,
                  label: 'Chiều dài',
                  hint: '0.0',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _sectionLabel('Số Tầng'),
          const SizedBox(height: 6),
          _buildFloorStepper(context),

          const SizedBox(height: 20),
          _sectionLabel('Loại Công Trình'),
          const SizedBox(height: 8),
          ...HouseType.values.map((type) => _buildHouseTypeRow(context, type)),

          // Live area preview
          if (_isValid) ...[
            const SizedBox(height: 16),
            _buildAreaPreview(context),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _dimensionField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
          ],
          onChanged: (_) => setState(() {}),
          validator: (v) {
            if (v == null || v.isEmpty) return null;
            final d = double.tryParse(v);
            if (d == null || d <= 0) return 'Nhập số > 0';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFloorStepper(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$_floors tầng${_floors == 1 ? '  (Nhà cấp 4 / trệt)' : ''}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          _stepBtn(
            icon: Icons.remove,
            onTap: _floors > 1 ? () => setState(() => _floors--) : null,
          ),
          const SizedBox(width: 12),
          _stepBtn(
            icon: Icons.add,
            onTap: _floors < 10 ? () => setState(() => _floors++) : null,
          ),
        ],
      ),
    );
  }

  Widget _stepBtn({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.green500 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildHouseTypeRow(BuildContext context, HouseType type) {
    final selected = _houseType == type;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _houseType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.green100
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border.all(color: AppColors.green500, width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                type.icon,
                color: selected ? AppColors.green500 : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? AppColors.green500
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${_formatVnd(type.costPerM2)}/m²',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.green500),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAreaPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.green100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.straighten_rounded,
              color: AppColors.green500, size: 18),
          const SizedBox(width: 8),
          Text('Tổng diện tích sàn: ',
              style: Theme.of(context).textTheme.bodyMedium),
          Text(
            '${_liveArea.toStringAsFixed(1)} m²',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.green500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── Calculate Button ──────────────────────────────────────────────────────

  Widget _buildCalculateButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isValid ? () => _calculate(context) : null,
      icon: const Icon(Icons.functions_rounded),
      label: const Text('Tính Ngay'),
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey,
      ),
    );
  }

  void _calculate(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final project = ProjectModel(
      name: _nameController.text.trim(),
      width: _width!,
      length: _length!,
      floors: _floors,
      houseType: _houseType,
    );
    final estimate = MaterialCalculator.calculate(project);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultsScreen(estimate: estimate)),
    );
  }

  String _formatVnd(double amount) {
    final value = amount.toInt();
    return '${value ~/ 1000000}tr';
  }
}
