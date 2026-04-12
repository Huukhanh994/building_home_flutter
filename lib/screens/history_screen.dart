import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/material_estimate.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import 'results_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static final _vnd = NumberFormat('#,###', 'vi_VN');
  static final _date = DateFormat('dd/MM/yyyy HH:mm');

  List<MaterialEstimate> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await HistoryService.load();
    if (mounted) setState(() { _items = items; _loading = false; });
  }

  Future<void> _delete(int index) async {
    await HistoryService.remove(index);
    setState(() => _items.removeAt(index));
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá toàn bộ lịch sử?'),
        content: const Text('Không thể hoàn tác.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Huỷ')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xoá',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await HistoryService.clear();
      setState(() => _items = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Dự Toán'),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Xoá tất cả',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? _buildEmpty(context)
              : _buildList(context),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history_rounded,
              size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text('Chưa có dự toán nào',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 6),
          Text('Tính xong sẽ tự động lưu ở đây',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _HistoryCard(
        estimate: _items[i],
        vnd: _vnd,
        date: _date,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ResultsScreen(estimate: _items[i])),
        ),
        onDelete: () => _delete(i),
      ),
    );
  }
}

// ── History card ──────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.estimate,
    required this.vnd,
    required this.date,
    required this.onTap,
    required this.onDelete,
  });

  final MaterialEstimate estimate;
  final NumberFormat vnd;
  final DateFormat date;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final proj = estimate.project;
    return Dismissible(
      key: ValueKey(proj.createdAt.toIso8601String()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.red),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: AppCard(
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.green100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(proj.houseType.icon,
                    color: AppColors.green500, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proj.name.isEmpty ? 'Công trình' : proj.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${proj.houseType.label} · ${proj.floors} tầng · '
                      '${proj.width}×${proj.length} m',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vnd.format(estimate.totalCost.toInt())} đ',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.green500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary),
                  const SizedBox(height: 4),
                  Text(
                    date.format(proj.createdAt),
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
