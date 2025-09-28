import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// 在地图上方渲染“选中 Place”的独立放大图标与地名（与地图缩放分离）
class PlaceOverlayLayer extends ConsumerWidget {
  const PlaceOverlayLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedPlaceProvider);
    final pos = ref.watch(selectedOverlayPosProvider);
    if (selected == null || pos == null) return const SizedBox.shrink();

    // 以像素坐标为锚点，向上偏移，使文字显示在标记上方
    const double iconSize = 32;
    const double gap = 6;
    final double left = pos.x - iconSize / 2;
    final double top = pos.y - iconSize - gap - 20;

    return IgnorePointer(
      child: Positioned(
        left: left,
        top: top,
        child: Opacity(
          opacity: 0.95,
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
                  selected.title,
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
      ),
    );
  }
}
