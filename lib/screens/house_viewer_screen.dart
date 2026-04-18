import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../models/house_model_dto.dart';
import '../services/buildhome_api_client.dart';
import '../theme/app_theme.dart';

class HouseViewerScreen extends StatefulWidget {
  const HouseViewerScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HouseViewerScreen> createState() => _HouseViewerScreenState();
}

class _HouseViewerScreenState extends State<HouseViewerScreen> {
  static const _jsChannel = 'FlutterBridge';

  List<HouseModelDto> _models = [];
  bool _loading = true;
  String? _fetchError;
  int _modelIndex = 0;
  bool _autoRotate = false;
  String? _selectedPart;

  final _apiClient = BuildhomeApiClient();

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _loadModels() async {
    setState(() {
      _loading = true;
      _fetchError = null;
    });
    try {
      final models = await _apiClient.fetchHouseModels();
      setState(() {
        _models = models;
        _modelIndex = widget.initialIndex.clamp(0, models.isEmpty ? 0 : models.length - 1);
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _fetchError = 'API error ${e.statusCode}: ${e.message}';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _fetchError = 'Lỗi: $e';
        _loading = false;
      });
    }
  }

  HouseModelDto? get _current =>
      _models.isEmpty ? null : _models[_modelIndex];

  void _onJsMessage(String message) {
    setState(() => _selectedPart = message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // ── Main content ─────────────────────────────────────────────
          if (_loading)
            const Center(child: CircularProgressIndicator(color: AppColors.green500))
          else if (_fetchError != null)
            _buildErrorState()
          else if (_models.isEmpty)
            _buildEmptyState()
          else
            _build3DViewer(),

          // ── Top bar (always visible) ─────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _TopBar(
                title: _current?.name ?? 'Xem Nhà 3D',
                onBack: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DViewer() {
    final model = _current!;
    return Stack(
      children: [
        // ── 3D Viewer ──────────────────────────────────────────────────
        Positioned.fill(
          child: ModelViewer(
            src: model.glbUrl,
            poster: model.thumbnailUrl,
            alt: model.name,
            cameraControls: true,
            touchAction: TouchAction.panY,
            autoRotate: _autoRotate,
            autoRotateDelay: 0,
            ar: false,
            disableZoom: false,
            javascriptChannels: {
              JavascriptChannel(
                _jsChannel,
                onMessageReceived: (msg) => _onJsMessage(msg.message),
              ),
            },
            onWebViewCreated: (controller) {
              controller.runJavaScript('''
                const mv = document.querySelector('model-viewer');
                if (mv) {
                  mv.addEventListener('click', (e) => {
                    const hit = mv.positionAndNormalFromPoint(e.clientX, e.clientY);
                    if (hit) {
                      const partName = hit.mesh ? hit.mesh.name : 'model';
                      $_jsChannel.postMessage(partName);
                    }
                  });
                }
              ''');
            },
            backgroundColor: const Color(0xFF0F172A),
          ),
        ),

        // ── Model selector ─────────────────────────────────────────────
        if (_models.length > 1)
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: _ModelSelectorBar(
              models: _models,
              selectedIndex: _modelIndex,
              onSelect: (i) => setState(() {
                _modelIndex = i;
                _selectedPart = null;
              }),
            ),
          ),

        // ── Camera controls ────────────────────────────────────────────
        Positioned(
          bottom: 24,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ControlButton(
                icon: _autoRotate
                    ? Icons.pause_circle_outline
                    : Icons.rotate_right,
                tooltip: _autoRotate ? 'Dừng xoay' : 'Tự xoay',
                onTap: () => setState(() => _autoRotate = !_autoRotate),
                active: _autoRotate,
              ),
              _ControlButton(
                icon: Icons.refresh,
                tooltip: 'Tải lại',
                onTap: _loadModels,
              ),
            ],
          ),
        ),

        // ── Selected part badge ────────────────────────────────────────
        if (_selectedPart != null)
          Positioned(
            bottom: _models.length > 1 ? 160 : 90,
            left: 0,
            right: 0,
            child: Center(child: _PartBadge(name: _selectedPart!)),
          ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Colors.white38, size: 64),
            const SizedBox(height: 16),
            Text(
              _fetchError!,
              style: const TextStyle(color: Colors.white60, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadModels,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green500,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.view_in_ar_outlined, color: Colors.white38, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Chưa có mô hình 3D nào.\nHãy upload file .glb từ backend.',
              style: TextStyle(color: Colors.white60, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadModels,
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green500,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.green500.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '3D',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ── Model Selector ────────────────────────────────────────────────────────────

class _ModelSelectorBar extends StatelessWidget {
  const _ModelSelectorBar({
    required this.models,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<HouseModelDto> models;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: models.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.green500
                    : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.green500 : Colors.white30,
                ),
              ),
              child: Text(
                models[i].name,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Control Button ────────────────────────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: active
                ? AppColors.green500
                : Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white30),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ── Part Badge ────────────────────────────────────────────────────────────────

class _PartBadge extends StatelessWidget {
  const _PartBadge({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xCC1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.green500.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.touch_app_rounded, color: AppColors.green500, size: 16),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
