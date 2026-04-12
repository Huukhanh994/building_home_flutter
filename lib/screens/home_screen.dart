import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import 'calculator_screen.dart';
import 'history_screen.dart';
import 'interactive_house_screen.dart';
import 'photo_calculator_screen.dart';
import 'templates_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeroHeader(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionLabel('Bắt Đầu Ngay'),
                const SizedBox(height: 10),
                _ActionCard(
                  icon: Icons.calculate_outlined,
                  title: 'Tính Vật Liệu',
                  subtitle: 'Ước tính xi măng, sắt thép, cát, đá',
                  color: AppColors.green500,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CalculatorScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.camera_alt_rounded,
                  title: 'Chụp Ảnh Công Trình',
                  subtitle: 'Chụp hoặc chọn ảnh nhà, nhập kích thước & tính',
                  color: const Color(0xFF0284C7),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PhotoCalculatorScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.grid_view_rounded,
                  title: 'Mẫu Nhà Đẹp',
                  subtitle: 'Nhà cấp 4, 2 tầng, biệt thự, nhà phố',
                  color: AppColors.orange500,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TemplatesScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.touch_app_rounded,
                  title: 'Nhà Tương Tác',
                  subtitle: 'Chạm vào bộ phận để xem vật liệu & chi phí',
                  color: const Color(0xFF7C3AED),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const InteractiveHouseScreen()),
                  ),
                ),
                const SizedBox(height: 20),
                _buildStatsBanner(context),
                const SizedBox(height: 16),
                _buildDisclaimer(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero Header ──────────────────────────────────────────────────────────────

  SliverAppBar _buildHeroHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BuildHome VN',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Trợ lý xây dựng thông minh',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.home_work_rounded,
                        size: 56,
                        color: Colors.white24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Text(
          'BuildHome VN',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Colors.white),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
      backgroundColor: AppColors.green500,
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded, color: Colors.white),
          tooltip: 'Lịch sử dự toán',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          ),
        ),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildStatsBanner(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _statItem('7+', 'Mẫu Thiết Kế'),
          const _Divider(),
          _statItem('5', 'Loại Công Trình'),
          const _Divider(),
          _statItem('📷', 'Chụp Ảnh'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.green500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

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
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.orange500,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Số liệu tính toán chỉ mang tính tham khảo. Vui lòng tham vấn kỹ sư trước khi thi công.',
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

// ── Action Card ──────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Divider ───────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.divider,
    );
  }
}
