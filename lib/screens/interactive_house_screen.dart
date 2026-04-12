import 'dart:async';

import 'package:flutter/material.dart';

import '../data/interactive_house_data.dart';
import '../models/component_estimate.dart';
import '../models/house_component.dart';
import '../services/component_calculator_service.dart';
import '../theme/app_theme.dart';
import '../widgets/component_result_sheet.dart';
import '../widgets/interactive_house_painter.dart';

class InteractiveHouseScreen extends StatefulWidget {
  const InteractiveHouseScreen({super.key});

  @override
  State<InteractiveHouseScreen> createState() => _InteractiveHouseScreenState();
}

class _InteractiveHouseScreenState extends State<InteractiveHouseScreen> {
  InteractiveHouseStyle _style = InteractiveHouseStyle.thaiRoof1Floor;
  List<HouseComponent> _components = [];
  String? _selectedComponentId;
  bool _isLoading = false;

  // Debounce timer to avoid rapid API calls
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadComponents();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _loadComponents() {
    setState(() {
      _components = InteractiveHouseData.componentsFor(_style);
      _selectedComponentId = null;
    });
  }

  void _onStyleChanged(InteractiveHouseStyle? style) {
    if (style == null || style == _style) return;
    setState(() => _style = style);
    _loadComponents();
  }

  void _onComponentTapped(HouseComponent component) {
    // Debounce: ignore rapid re-taps within 350 ms
    if (_debounce?.isActive ?? false) return;
    _debounce = Timer(const Duration(milliseconds: 350), () {});

    setState(() {
      _selectedComponentId = component.id;
      _isLoading = true;
    });

    ComponentCalculatorService.calculate(component).then((estimate) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showResult(estimate);
    }).onError((_, __) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _selectedComponentId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tính toán. Vui lòng thử lại.')),
      );
    });
  }

  Future<void> _showResult(ComponentEstimate estimate) async {
    await ComponentResultSheet.show(context, estimate);
    if (mounted) {
      setState(() => _selectedComponentId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem Nhà Tương Tác'),
        backgroundColor: AppColors.green500,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _StyleSelector(
            selected: _style,
            onChanged: _onStyleChanged,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HouseViewCard(
                    style: _style,
                    components: _components,
                    selectedComponentId: _selectedComponentId,
                    isLoading: _isLoading,
                    onComponentTapped: _onComponentTapped,
                  ),
                  const SizedBox(height: 16),
                  _ComponentLegend(
                    components: _components,
                    selectedId: _selectedComponentId,
                    onTap: _onComponentTapped,
                  ),
                  const SizedBox(height: 12),
                  _HintBanner(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Style selector tabs ───────────────────────────────────────────────────────

class _StyleSelector extends StatelessWidget {
  const _StyleSelector({required this.selected, required this.onChanged});
  final InteractiveHouseStyle selected;
  final ValueChanged<InteractiveHouseStyle?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.green500,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Row(
          children: InteractiveHouseStyle.values
              .map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _StyleChip(
                      style: s,
                      isSelected: s == selected,
                      onTap: () => onChanged(s),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _StyleChip extends StatelessWidget {
  const _StyleChip({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });
  final InteractiveHouseStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          style.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.green500 : Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── House view card ───────────────────────────────────────────────────────────

class _HouseViewCard extends StatelessWidget {
  const _HouseViewCard({
    required this.style,
    required this.components,
    required this.selectedComponentId,
    required this.isLoading,
    required this.onComponentTapped,
  });
  final InteractiveHouseStyle style;
  final List<HouseComponent> components;
  final String? selectedComponentId;
  final bool isLoading;
  final ValueChanged<HouseComponent> onComponentTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.home_work_rounded,
                      color: AppColors.green500, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Nhấn vào từng bộ phận để xem vật liệu',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  if (isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.green500,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            InteractiveHouseView(
              style: style,
              components: components,
              selectedComponentId: selectedComponentId,
              onComponentTapped: onComponentTapped,
              height: 300,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Component legend chips ────────────────────────────────────────────────────

class _ComponentLegend extends StatelessWidget {
  const _ComponentLegend({
    required this.components,
    required this.selectedId,
    required this.onTap,
  });
  final List<HouseComponent> components;
  final String? selectedId;
  final ValueChanged<HouseComponent> onTap;

  @override
  Widget build(BuildContext context) {
    // Deduplicate — window_front can appear twice in regions
    final seen = <String>{};
    final unique =
        components.where((c) => seen.add(c.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bộ phận công trình',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: unique
              .map((c) => _LegendChip(
                    component: c,
                    isSelected: c.id == selectedId,
                    onTap: () => onTap(c),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.component,
    required this.isSelected,
    required this.onTap,
  });
  final HouseComponent component;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green500 : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.green500 : AppColors.divider,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.green500.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _groupIcon(component.group),
              size: 13,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              component.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _groupIcon(ComponentGroup group) => switch (group) {
        ComponentGroup.roof => Icons.roofing_rounded,
        ComponentGroup.structure => Icons.foundation_rounded,
        ComponentGroup.wallSystem => Icons.door_front_door_rounded,
        ComponentGroup.exterior => Icons.park_rounded,
      };
}

// ── Hint banner ───────────────────────────────────────────────────────────────

class _HintBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.orange100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.orange500, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Số liệu tính theo diện tích mặc định 6m × 10m. '
              'Dùng "Tính Vật Liệu" để nhập kích thước thực tế.',
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
}
