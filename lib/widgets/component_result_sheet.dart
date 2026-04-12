import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/component_estimate.dart';
import '../models/house_component.dart';
import '../theme/app_theme.dart';

/// Bottom sheet displaying material and cost breakdown for a tapped component.
class ComponentResultSheet extends StatelessWidget {
  const ComponentResultSheet({
    super.key,
    required this.estimate,
  });

  final ComponentEstimate estimate;

  static Future<void> show(
      BuildContext context, ComponentEstimate estimate) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ComponentResultSheet(estimate: estimate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final comp = estimate.component;
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.90,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _DragHandle(),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  _Header(component: comp),
                  const SizedBox(height: 20),
                  _MaterialsCard(materials: estimate.materials),
                  const SizedBox(height: 12),
                  _CostCard(cost: estimate.cost),
                  const SizedBox(height: 12),
                  _MetaRow(version: estimate.calculationVersion),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Drag handle ───────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.component});
  final HouseComponent component;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.green100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_groupIcon(component.group),
              color: AppColors.green500, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                component.label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 2),
              Text(
                'Diện tích: ${component.area.toStringAsFixed(1)} ${component.unit}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _groupIcon(ComponentGroup group) => switch (group) {
        ComponentGroup.roof => Icons.roofing_rounded,
        ComponentGroup.structure => Icons.foundation_rounded,
        ComponentGroup.wallSystem => Icons.door_front_door_rounded,
        ComponentGroup.exterior => Icons.park_rounded,
      };
}

// ── Materials card ────────────────────────────────────────────────────────────

class _MaterialsCard extends StatelessWidget {
  const _MaterialsCard({required this.materials});
  final ComponentMaterials materials;

  @override
  Widget build(BuildContext context) {
    final rows = _nonZeroRows();
    if (rows.isEmpty) return const SizedBox.shrink();

    return _Card(
      title: 'Vật liệu',
      icon: Icons.inventory_2_outlined,
      child: Column(children: rows),
    );
  }

  List<Widget> _nonZeroRows() {
    final items = <_MatRow>[];
    if (materials.cement > 0) {
      items.add(_MatRow(
          label: 'Xi măng',
          value: '${materials.cement.toStringAsFixed(0)} bao'));
    }
    if (materials.sand > 0) {
      items.add(_MatRow(
          label: 'Cát',
          value: '${materials.sand.toStringAsFixed(1)} m³'));
    }
    if (materials.steel > 0) {
      items.add(_MatRow(
          label: 'Thép',
          value: '${(materials.steel / 1000).toStringAsFixed(2)} tấn'));
    }
    if (materials.brick > 0) {
      items.add(_MatRow(
          label: 'Gạch',
          value: '${_fmt(materials.brick)} viên'));
    }
    if (materials.concrete > 0) {
      items.add(_MatRow(
          label: 'Bê tông',
          value: '${materials.concrete.toStringAsFixed(1)} m³'));
    }
    if (materials.roofTile > 0) {
      items.add(_MatRow(
          label: 'Ngói',
          value: '${_fmt(materials.roofTile)} viên'));
    }
    return items;
  }

  String _fmt(double v) =>
      NumberFormat('#,###', 'vi_VN').format(v.round());
}

class _MatRow extends StatelessWidget {
  const _MatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Cost card ─────────────────────────────────────────────────────────────────

class _CostCard extends StatelessWidget {
  const _CostCard({required this.cost});
  final ComponentCost cost;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Chi phí (VND)',
      icon: Icons.payments_outlined,
      child: Column(
        children: [
          _CostRow(
              label: 'Vật liệu', value: cost.materialCost, isPrimary: false),
          _CostRow(label: 'Nhân công', value: cost.laborCost, isPrimary: false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _CostRow(label: 'Tổng cộng', value: cost.total, isPrimary: true),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow(
      {required this.label, required this.value, required this.isPrimary});
  final String label;
  final double value;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final formatted = _fmtVnd(value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isPrimary
                ? Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.green500)
                : Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            formatted,
            style: isPrimary
                ? Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.green500)
                : Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _fmtVnd(double v) {
    if (v >= 1000000000) {
      return '${(v / 1000000000).toStringAsFixed(2)} tỷ';
    }
    if (v >= 1000000) {
      return '${(v / 1000000).toStringAsFixed(1)}M';
    }
    return '${NumberFormat('#,###', 'vi_VN').format(v.round())} đ';
  }
}

// ── Meta row ──────────────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.version});
  final String version;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Phiên bản tính toán: $version · Chỉ mang tính tham khảo',
      style: Theme.of(context)
          .textTheme
          .labelSmall
          ?.copyWith(color: AppColors.textSecondary),
      textAlign: TextAlign.center,
    );
  }
}

// ── Reusable card ─────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.green500),
              const SizedBox(width: 6),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
