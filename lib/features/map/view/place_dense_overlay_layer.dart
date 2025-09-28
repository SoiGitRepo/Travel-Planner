import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/models/latlng_point.dart' as model;
import 'providers.dart';

/// 密集覆盖层：在地图上方渲染一定数量的小图标与地名（与地图缩放分离）
class PlaceDenseOverlayLayer extends ConsumerWidget {
  const PlaceDenseOverlayLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(overlayRenderItemsProvider);
    final shift = ref.watch(overlayShiftProvider);
    if (items.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[];
    for (final it in items) {
      final x = it.pos.x;
      final y = it.pos.y;
      final left = x + shift.x - 36; // 让标记稍微居中
      final top = y + shift.y - 54; // 文字在上，icon 在下
      children.add(
        Positioned(
          left: left,
          top: top,
          child: _AnimatedDenseItem(
            placeName: it.place.name,
            onTap: () async {
              // 选中并相机聚焦
              ref.read(selectedPlaceProvider.notifier).state = SelectedPlace(
                placeId: it.place.id,
                title: it.place.name,
                point: model.LatLngPoint(it.place.location.lat, it.place.location.lng),
              );
              ref.read(panelPageProvider.notifier).state = PanelPage.detail;
              final c = ref.read(mapControllerProvider);
              if (c != null) {
                try {
                  await c.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: LatLng(it.place.location.lat, it.place.location.lng), zoom: 16),
                    ),
                  );
                  // 同步选中像素位置
                  final sc = await c.getScreenCoordinate(LatLng(it.place.location.lat, it.place.location.lng));
                  ref.read(selectedOverlayPosProvider.notifier).state = OverlayPos(sc.x.toDouble(), sc.y.toDouble());
                } catch (_) {}
              }
            },
          ),
        ),
      );
    }

    return IgnorePointer(
      ignoring: false,
      child: Stack(children: children),
    );
  }
}

class _AnimatedDenseItem extends StatefulWidget {
  final String placeName;
  final VoidCallback onTap;
  const _AnimatedDenseItem({required this.placeName, required this.onTap});

  @override
  State<_AnimatedDenseItem> createState() => _AnimatedDenseItemState();
}

class _AnimatedDenseItemState extends State<_AnimatedDenseItem> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _offset = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const iconSize = 20.0;
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 1)),
                    ],
                  ),
                  child: Text(
                    widget.placeName,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: const BoxDecoration(color: Colors.indigo, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(Icons.location_on, size: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
