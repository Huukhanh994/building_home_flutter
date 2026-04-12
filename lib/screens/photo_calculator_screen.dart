import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/house_type.dart';
import '../models/project_model.dart';
import '../models/region.dart';
import '../services/material_calculator.dart';
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import 'results_screen.dart';

class PhotoCalculatorScreen extends StatefulWidget {
  const PhotoCalculatorScreen({super.key});

  @override
  State<PhotoCalculatorScreen> createState() => _PhotoCalculatorScreenState();
}

class _PhotoCalculatorScreenState extends State<PhotoCalculatorScreen> {
  File? _image;
  bool _picking = false;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _widthCtrl  = TextEditingController();
  final _lengthCtrl = TextEditingController();
  int _floors       = 1;
  HouseType _type   = HouseType.twoStory;
  Region _region    = Region.other;

  @override
  void initState() {
    super.initState();
    PreferencesService.getLastRegion()
        .then((r) { if (mounted) setState(() => _region = r); });
  }

  double? get _width  => double.tryParse(_widthCtrl.text);
  double? get _length => double.tryParse(_lengthCtrl.text);
  bool get _canCalc   => _image != null && (_width ?? 0) > 0 && (_length ?? 0) > 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _widthCtrl.dispose();
    _lengthCtrl.dispose();
    super.dispose();
  }

  // ── Image picking ─────────────────────────────────────────────────────────

  Future<void> _pick(ImageSource source) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (xFile != null && mounted) {
        setState(() => _image = File(xFile.path));
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể truy cập: ${e.message}')),
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final project = ProjectModel(
      name: _nameCtrl.text.trim(),
      width: _width!,
      length: _length!,
      floors: _floors,
      houseType: _type,
      region: _region,
    );
    final estimate = MaterialCalculator.calculate(project);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultsScreen(estimate: estimate)),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chụp Ảnh & Tính Toán')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPhotoSection(),
              const SizedBox(height: 16),
              if (_image != null) ...[
                _buildDimensionsCard(),
                const SizedBox(height: 16),
                _buildCalculateButton(),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Photo section ─────────────────────────────────────────────────────────

  Widget _buildPhotoSection() {
    if (_image == null) return _buildPickerPrompt();
    return _buildImagePreview();
  }

  Widget _buildPickerPrompt() {
    return AppCard(
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.green100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 40,
              color: AppColors.green500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Chụp hoặc chọn ảnh công trình',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Dùng ảnh làm tham chiếu khi nhập kích thước',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _PickerButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Chụp Ảnh',
                  color: AppColors.green500,
                  loading: _picking,
                  onTap: () => _pick(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PickerButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Thư Viện',
                  color: AppColors.orange500,
                  loading: _picking,
                  onTap: () => _pick(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.file(
              _image!,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.green500, size: 16),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Ảnh đã chọn — nhập kích thước bên dưới',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
                TextButton.icon(
                  onPressed: _picking ? null : () => _showSourceSheet(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Đổi'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.green500,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppColors.green500),
              title: const Text('Chụp ảnh mới'),
              onTap: () {
                Navigator.pop(context);
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.orange500),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pick(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Dimensions card ───────────────────────────────────────────────────────

  Widget _buildDimensionsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Tên Công Trình (tuỳ chọn)'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameCtrl,
            decoration:
                const InputDecoration(hintText: 'VD: Nhà anh Tùng, Ba Vì'),
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 20),
          _label('Kích Thước Mặt Bằng (m)'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _dimField(_widthCtrl, 'Chiều rộng')),
              const SizedBox(width: 12),
              Expanded(child: _dimField(_lengthCtrl, 'Chiều dài')),
            ],
          ),

          const SizedBox(height: 20),
          _label('Số Tầng'),
          const SizedBox(height: 6),
          _buildFloorStepper(),

          const SizedBox(height: 20),
          _label('Loại Công Trình'),
          const SizedBox(height: 8),
          ...HouseType.values.map((t) => _buildTypeRow(t)),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      );

  Widget _dimField(TextEditingController ctrl, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: '0.0'),
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
          ],
          onChanged: (_) => setState(() {}),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Bắt buộc';
            final d = double.tryParse(v);
            if (d == null || d <= 0) return 'Nhập số > 0';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFloorStepper() {
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
          _stepBtn(Icons.remove,
              _floors > 1 ? () => setState(() => _floors--) : null),
          const SizedBox(width: 12),
          _stepBtn(Icons.add,
              _floors < 10 ? () => setState(() => _floors++) : null),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback? onTap) {
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

  Widget _buildTypeRow(HouseType type) {
    final selected = _type == type;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.green100 : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border.all(color: AppColors.green500, width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              Icon(type.icon,
                  color: selected
                      ? AppColors.green500
                      : AppColors.textSecondary,
                  size: 22),
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
                      '${(type.costPerM2 / 1000000).toStringAsFixed(0)}tr/m²',
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

  Widget _buildCalculateButton() {
    return ElevatedButton.icon(
      onPressed: _canCalc ? _calculate : null,
      icon: const Icon(Icons.functions_rounded),
      label: const Text('Tính Ngay'),
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey,
      ),
    );
  }
}

// ── Picker button widget ──────────────────────────────────────────────────────

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  const _PickerButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: loading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
