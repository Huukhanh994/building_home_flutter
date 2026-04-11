import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/template_data.dart';
import '../models/house_template.dart';
import '../models/house_type.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import 'template_detail_screen.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  HouseType? _selectedType;
  String _searchText = '';

  static final _vnd = NumberFormat('#,###', 'vi_VN');

  List<HouseTemplate> get _filtered {
    return allTemplates.where((t) {
      final matchType = _selectedType == null || t.type == _selectedType;
      final matchSearch = _searchText.isEmpty ||
          t.name.toLowerCase().contains(_searchText.toLowerCase()) ||
          t.roofStyle.toLowerCase().contains(_searchText.toLowerCase());
      return matchType && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mẫu Nhà Đẹp')),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTypeFilter(),
          Expanded(
            child: _filtered.isEmpty
                ? _buildEmptyState(context)
                : _buildList(context),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Tìm mẫu nhà...',
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
        ),
        onChanged: (v) => setState(() => _searchText = v),
      ),
    );
  }

  // ── Type Filter ───────────────────────────────────────────────────────────

  Widget _buildTypeFilter() {
    return SizedBox(
      height: 48,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          _chip('Tất cả', null),
          ...HouseType.values.map((t) => _chip(t.label, t)),
        ],
      ),
    );
  }

  Widget _chip(String label, HouseType? type) {
    final selected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? AppColors.green500 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _TemplateCard(
        template: _filtered[i],
        vnd: _vnd,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => TemplateDetailScreen(template: _filtered[i])),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.home_outlined,
              size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text('Không tìm thấy mẫu nhà',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => setState(() {
              _selectedType = null;
              _searchText = '';
            }),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Xoá bộ lọc'),
          ),
        ],
      ),
    );
  }
}

// ── Template Card ────────────────────────────────────────────────────────────

class _TemplateCard extends StatelessWidget {
  final HouseTemplate template;
  final NumberFormat vnd;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.vnd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Row(
          children: [
            // Thumbnail placeholder
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.green500, AppColors.green400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(template.type.icon, color: Colors.white, size: 30),
                  const SizedBox(height: 4),
                  Text(
                    template.roofStyle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _badge(Icons.square_foot_outlined,
                          '${template.area.toInt()} m²'),
                      const SizedBox(width: 8),
                      _badge(Icons.business_outlined,
                          '${template.floors} tầng'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${vnd.format(template.estimatedCost.toInt())} đ',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.green500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 2),
        Text(text,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
