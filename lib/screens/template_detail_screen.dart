import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/cost_config.dart';
import '../models/house_template.dart';
import '../services/blueprint_generator.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/house_layout_painter.dart';
import 'calculator_screen.dart';

class TemplateDetailScreen extends StatelessWidget {
  final HouseTemplate template;

  const TemplateDetailScreen({super.key, required this.template});

  static final _vnd = NumberFormat('#,###', 'vi_VN');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHero(context),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDescription(context),
                const SizedBox(height: 14),
                _buildSpecsGrid(context),
                const SizedBox(height: 14),
                _buildFeaturesCard(context),
                const SizedBox(height: 14),
                _buildBlueprintCard(context),
                const SizedBox(height: 14),
                _buildCostCard(context),
                const SizedBox(height: 16),
                _buildCtaButton(context),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────

  SliverAppBar _buildHero(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.green500, AppColors.green400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(template.type.icon, size: 72, color: Colors.white30),
                const SizedBox(height: 12),
                Text(
                  template.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    template.roofStyle,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        title: Text(
          template.name,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      backgroundColor: AppColors.green500,
    );
  }

  // ── Description ───────────────────────────────────────────────────────────

  Widget _buildDescription(BuildContext context) {
    return AppCard(
      child: Text(
        template.description,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  // ── Specs Grid ────────────────────────────────────────────────────────────

  Widget _buildSpecsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.0,
      children: [
        _specCell(context, Icons.square_foot_outlined,
            '${template.area.toInt()} m²', 'Diện tích'),
        _specCell(context, Icons.business_outlined,
            '${template.floors} tầng', 'Số tầng'),
        _specCell(
            context, template.type.icon, template.type.label, 'Loại nhà'),
        _specCell(
            context, Icons.roofing_outlined, template.roofStyle, 'Kiểu mái'),
      ],
    );
  }

  Widget _specCell(
      BuildContext context, IconData icon, String value, String label) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.green500, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Features ──────────────────────────────────────────────────────────────

  Widget _buildFeaturesCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.green500, size: 20),
              const SizedBox(width: 8),
              Text('Đặc Điểm Nổi Bật',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          ...template.features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.green500, size: 18),
                  const SizedBox(width: 8),
                  Text(f, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Blueprint ─────────────────────────────────────────────────────────────

  Widget _buildBlueprintCard(BuildContext context) {
    // Use the hand-crafted layout if available, fall back to auto-generated.
    final layout = template.blueprint ??
        BlueprintGenerator.forHouseType(template.type, template.floors);

    // Derive representative dimensions from template area and floor count
    final floorArea = template.area / template.floors;
    final width  = (floorArea / 1.5).clamp(4.0, 30.0);
    final length = (floorArea / width).clamp(4.0, 50.0);

    return HouseLayoutCard(
      layout: layout,
      houseWidth: width,
      houseLength: length,
    );
  }

  // ── Cost ──────────────────────────────────────────────────────────────────

  Widget _buildCostCard(BuildContext context) {
    final structural = template.estimatedCost * CostConfig.structuralFraction;
    final finishing  = template.estimatedCost * CostConfig.finishingFraction;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monetization_on_outlined,
                  color: AppColors.green500, size: 20),
              const SizedBox(width: 8),
              Text('Chi Phí Ước Tính',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          _costBar(context, 'Phần thô', structural, 0.6),
          const SizedBox(height: 10),
          _costBar(context, 'Phần hoàn thiện', finishing, 0.4),
          const Divider(height: 20, color: AppColors.divider),
          Row(
            children: [
              Expanded(
                child: Text('Tổng cộng',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              Text(
                '${_vnd.format(template.estimatedCost.toInt())} đ',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _costBar(
      BuildContext context, String label, double amount, double fraction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium),
            ),
            Text(
              '${_vnd.format(amount.toInt())} đ',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(builder: (_, constraints) {
          return Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                height: 6,
                width: constraints.maxWidth * fraction,
                decoration: BoxDecoration(
                  color: AppColors.green500,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  // ── CTA Button ────────────────────────────────────────────────────────────

  Widget _buildCtaButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Derive default width/length from template area using a 1:1.5 ratio.
        // Users can adjust in the calculator.
        final floorArea = template.area / template.floors;
        final width  = (floorArea / 1.5).floorToDouble().clamp(4.0, 30.0);
        final length = (floorArea / width).floorToDouble().clamp(4.0, 50.0);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CalculatorScreen(
              initialName: template.name,
              initialWidth: width,
              initialLength: length,
              initialFloors: template.floors,
              initialHouseType: template.type,
            ),
          ),
        );
      },
      icon: const Icon(Icons.functions_rounded),
      label: const Text('Tính Cho Kích Thước Của Bạn'),
    );
  }
}
