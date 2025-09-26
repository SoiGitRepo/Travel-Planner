import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:travel_planner/core/widgets/glassy/glassy.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/latlng_point.dart' as model;
import '../../plan/presentation/plan_controller.dart';
import 'providers.dart';
import 'timeline_panel.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final _sheetController = DraggableScrollableController();
  Timer? _fitDebounce;
  // 去除拖动结束后的二次动画，改为在接近吸附档位时直接使用动画，避免“两段式”停顿
  DateTime? _lastAnimateAt; // 上一次使用 animate 的时间
  double _lastSheetSize = 0.2; // 记录上一次的面板比例
  static const _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco default
    zoom: 12,
  );

  // 注意：不要在 initState 使用 ref.listen（Riverpod 限制）。

  @override
  void initState() {
    super.initState();
    _initMapProvider();
    _sheetController.addListener(() {
      final size = _sheetController.size; // 0-1
      ref.read(sheetFractionProvider.notifier).state = size;
      // 拖动中节流触发视野适配：接近吸附档位时直接用动画，否则根据变化幅度与节流使用 move
      _fitDebounce?.cancel();
      _fitDebounce = Timer(const Duration(milliseconds: 90), () {
        final delta = (size - _lastSheetSize).abs();
        final now = DateTime.now();
        final since = _lastAnimateAt == null
            ? const Duration(milliseconds: 999)
            : now.difference(_lastAnimateAt!);
        const snaps = [0.12, 0.6, 0.9];
        final nearSnap = snaps.any((s) => (size - s).abs() < 0.02);
        final shouldAnimate =
            nearSnap || delta > 0.08 || since.inMilliseconds > 320;
        _fitToNodes(context, animate: shouldAnimate);
        if (shouldAnimate) {
          _lastAnimateAt = now;
        }
        _lastSheetSize = size;
      });
    });
  }

  @override
  void dispose() {
    _fitDebounce?.cancel();
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _initMapProvider() async {
    // 仅 Android 设备有效，iOS/Web 直接使用 Google 地图
    try {
      final availability = await GoogleApiAvailability.instance
          .checkGooglePlayServicesAvailability();
      final useAmap = availability != GooglePlayServicesAvailability.success;
      if (mounted) {
        // 切换到高德（占位）或谷歌
        ref.read(useAmapProvider.notifier).state = useAmap;
      }
    } catch (_) {
      // 检测失败时，保持默认（使用 Google），避免影响开发
    }
  }

  Future<void> _fitToNodes(BuildContext context, {bool animate = true}) async {
    final controller = ref.read(mapControllerProvider);
    final planAsync = ref.read(planControllerProvider);
    if (controller == null || !planAsync.hasValue) return;
    final plan = planAsync.value!.currentPlan;
    final nodes = plan.nodes;
    final segs = plan.segments;

    // 收集所有需要纳入视野的点：节点坐标 + 所有路线折线点
    final pts = <LatLng>[];
    for (final n in nodes) {
      pts.add(LatLng(n.point.lat, n.point.lng));
    }
    for (final s in segs) {
      final path = s.path ?? const [];
      for (final p in path) {
        pts.add(LatLng(p.lat, p.lng));
      }
    }

    if (pts.isEmpty) {
      final update = CameraUpdate.newCameraPosition(_initialPosition);
      if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
      return;
    }
    if (pts.length == 1) {
      final update = CameraUpdate.newCameraPosition(
          CameraPosition(target: pts.first, zoom: 14));
      if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
      return;
    }

    var minLat = pts.first.latitude;
    var maxLat = pts.first.latitude;
    var minLng = pts.first.longitude;
    var maxLng = pts.first.longitude;
    for (final p in pts) {
      minLat = p.latitude < minLat ? p.latitude : minLat;
      maxLat = p.latitude > maxLat ? p.latitude : maxLat;
      minLng = p.longitude < minLng ? p.longitude : minLng;
      maxLng = p.longitude > maxLng ? p.longitude : maxLng;
    }

    // 基于底部面板高度，计算需要的“可见比例”，确保所有点都显示在 (地图高度 - 面板高度) 内；
    // 做法：按 1/(可见比例) 扩大内容纵向范围，并将中心按面板占比向上偏移。
    final fraction = ref.read(sheetFractionProvider).clamp(0.0, 0.95);
    final latSpan = (maxLat - minLat).abs();
    final safeSpan = latSpan < 1e-5 ? 1e-3 : latSpan; // 防止过小导致过度放大
    final visibleRatio =
        (0.85 - fraction).clamp(0.2, 0.9); // 最少给 20% 可见空间，避免无穷放大
    final expandFactor = 1.0 / visibleRatio;
    final targetSpan = safeSpan * expandFactor;
    final grow = targetSpan - safeSpan;
    // 以“向上扩”为主，下方保留少量余量
    minLat -= grow * 0.15;
    maxLat += grow * 0.85;
    // 根据面板高度，将相机中心向下偏移（使内容在屏幕上整体上移，远离底部遮挡）
    final shiftLat = targetSpan * (fraction * 0.9); // 0~0.475倍span
    minLat -= shiftLat;
    maxLat -= shiftLat;

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    try {
      final update = CameraUpdate.newLatLngBounds(bounds, 64);
      if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
    } catch (_) {
      // 某些平台在首次渲染或地图尚未布局完成时会抛错，降级为移动中心点
      final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
      final update = CameraUpdate.newLatLng(center);
      if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
    }
  }

  Future<void> _onLongPress(LatLng point) async {
    final mode = ref.read(transportModeProvider);
    await ref.read(planControllerProvider.notifier).addNodeAt(
          model.LatLngPoint(point.latitude, point.longitude),
          mode: mode,
        );
    unawaited(_fitToNodes(context));
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(planControllerProvider);
    final useAmap = ref.watch(useAmapProvider);

    final markers = <Marker>{};
    final polylines = <Polyline>{};

    planAsync.whenData((s) {
      final nodes = s.currentPlan.nodes;
      for (var i = 0; i < nodes.length; i++) {
        final n = nodes[i];
        markers.add(Marker(
          markerId: MarkerId(n.id),
          position: LatLng(n.point.lat, n.point.lng),
          infoWindow: InfoWindow(title: n.title),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          onTap: () {
            ref.read(selectedPlaceProvider.notifier).state = SelectedPlace(
              nodeId: n.id,
              title: n.title,
              point: n.point,
            );
          },
        ));
      }
      for (final seg in s.currentPlan.segments) {
        final pts = seg.path ?? [];
        if (pts.length >= 2) {
          polylines.add(Polyline(
            polylineId: PolylineId(seg.id),
            points: pts.map((e) => LatLng(e.lat, e.lng)).toList(),
            color: Colors.indigo,
            width: 5,
          ));
        }
      }
    });

    final mapWidget = useAmap
        ? Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.map, color: Colors.white70, size: 48),
                SizedBox(height: 12),
                Text(
                  '当前设备不支持谷歌服务，已切换高德地图（占位）',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  '请稍后在配置中补充高德 API Key 后启用真实地图渲染',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : GoogleMap(
            initialCameraPosition: _initialPosition,
            myLocationButtonEnabled: true,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            markers: markers,
            polylines: polylines,
            onMapCreated: (controller) {
              ref.read(mapControllerProvider.notifier).state = controller;
            },
            onTap: (latLng) {
              ref.read(selectedPlaceProvider.notifier).state = SelectedPlace(
                title: '所选位置',
                point: model.LatLngPoint(latLng.latitude, latLng.longitude),
              );
            },
            onLongPress: _onLongPress,
          );
    return Scaffold(
      body: Stack(
        children: [
          mapWidget,
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black87,
                shadowColor: Colors.transparent,
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _fitToNodes(context),
              icon: const Icon(Icons.center_focus_strong),
              label: const Text('适配视野'),
            ).glassy(
              borderRadius: 12,
              // glassContainsChild: true,
              settings: const LiquidGlassSettings(
                blur: 1,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 12,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black87,
                shadowColor: Colors.transparent,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.push('/search'),
              icon: const Icon(Icons.search),
              label: const Text('搜索'),
            ).glassy(
              borderRadius: 12,
              settings: const LiquidGlassSettings(
                blur: 1,
              ),
            ),
          ),
          TimelinePanel(controller: _sheetController),
          if (planAsync.isLoading)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
