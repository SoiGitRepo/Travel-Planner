import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// 在地图上方渲染“选中 Place”的独立放大图标与地名（与地图缩放分离）
class PlaceOverlayLayer extends ConsumerStatefulWidget {
  const PlaceOverlayLayer({super.key});

  @override
  ConsumerState<PlaceOverlayLayer> createState() => _PlaceOverlayLayerState();
}

class _PlaceOverlayLayerState extends ConsumerState<PlaceOverlayLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _scale = Tween<double>(begin: 0.9, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedPlaceProvider);
    final pos = ref.watch(selectedOverlayPosProvider);

    // 没有选中项或没有像素坐标时不绘制
    if (selected == null || pos == null) return const SizedBox.shrink();

    // 每次选中变化时触发一次放大动画
    _controller.forward(from: 0);

    // 以像素坐标为锚点，向上偏移，使文字显示在标记上方
    const double iconSize = 32;
    const double gap = 6;
    final double left = pos.x - iconSize / 2;
    final double top = pos.y - iconSize - gap - 20; // 20 预留给文字高度的一半

    final label = selected.title;

    return IgnorePointer(
      child: Positioned(
        left: left,
        top: top,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Opacity(
              opacity: 0.95,
              child: Transform.scale(
                scale: _scale.value,
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.orange.withValues(alpha: 0.4), blurRadius: 12),
                        ],
                      ),
                      child: const Icon(Icons.place, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
