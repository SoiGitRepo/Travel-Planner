import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:travel_planner/core/widgets/glassy/glassy.dart';
import 'package:google_api_availability/google_api_availability.dart';
// import 'package:go_router/go_router.dart';

import '../../../core/models/latlng_point.dart' as model;
import '../../../core/providers.dart';
import '../../../core/utils/haversine.dart';
import '../../plan/presentation/plan_controller.dart';
import 'providers.dart';
import 'timeline_panel.dart';
import 'marker_icons.dart';

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
  // 覆盖层已移除，不再需要移动中的像素布局节流
  static const _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco default
    zoom: 12,
  );

  //  Google Map样式（隐藏 POI 图层）
  //
  static const _mapStyleDefault =
      '[{"featureType":"poi","elementType":"labels","stylers":[{"visibility":"off"}]}]';

  // 自定义图标缓存（按主类型）
  final Map<String, BitmapDescriptor> _typeIconCache = {};
  final Set<String> _pendingIconKeys = {};

  String _mainTypeKey(List<String> types) {
    if (types.contains('tourist_attraction')) return 'tourist_attraction';
    if (types.contains('museum')) return 'museum';
    if (types.contains('art_gallery')) return 'art_gallery';
    if (types.contains('park')) return 'park';
    if (types.contains('restaurant')) return 'restaurant';
    if (types.contains('cafe')) return 'cafe';
    if (types.contains('shopping_mall')) return 'shopping_mall';
    return 'default';
  }

  Future<void> _focusPlacePanelAware(model.LatLngPoint p,
      {double zoom = 16, bool animate = true}) async {
    final c = ref.read(mapControllerProvider);
    if (c == null) return;
    final fraction = ref.read(sheetFractionProvider).clamp(0.0, 0.95);
    // 基于 zoom 估算纬度跨度，避免依赖受面板遮挡影响的 visibleRegion
    final currentZoom = ref.read(cameraPositionProvider)?.zoom ?? 14.0;
    final latSpan = 360 / pow(2, currentZoom);
    final visibleRatio = (0.85 - fraction).clamp(0.2, 0.9);
    final targetSpan = latSpan * (1.0 / visibleRatio);
    final shiftLat = targetSpan * (fraction * 0.9);
    final center = LatLng(p.lat - shiftLat, p.lng);
    final update = CameraUpdate.newCameraPosition(
        CameraPosition(target: center, zoom: zoom));
    if (animate) {
      await c.animateCamera(update);
    } else {
      await c.moveCamera(update);
    }
  }

  (IconData, Color) _iconForType(String key) {
    switch (key) {
      case 'tourist_attraction':
        return (Icons.attractions, Colors.orange);
      case 'museum':
        return (Icons.museum, Colors.brown);
      case 'art_gallery':
        return (Icons.brush, Colors.deepPurple);
      case 'park':
        return (Icons.park, Colors.green);
      case 'restaurant':
        return (Icons.restaurant, Colors.redAccent);
      case 'cafe':
        return (Icons.local_cafe, Colors.brown);
      case 'shopping_mall':
        return (Icons.local_mall, Colors.indigo);
      default:
        return (Icons.place, Colors.blueGrey);
    }
  }

  Future<void> _ensureIconBuilt(String key) async {
    if (_typeIconCache.containsKey(key) || _pendingIconKeys.contains(key))
      return;
    _pendingIconKeys.add(key);
    final (iconData, bg) = _iconForType(key);
    final bmp = await MarkerIconFactory.create(
        icon: iconData, background: bg, foreground: Colors.white, size: 112);
    _typeIconCache[key] = bmp;
    _pendingIconKeys.remove(key);
    if (mounted) setState(() {});
  }

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
        // 仅在时间轴页面自动适配整计划
        if (ref.read(panelPageProvider) == PanelPage.timeline) {
          _fitToNodes(context, animate: shouldAnimate);
        }
        if (shouldAnimate) {
          _lastAnimateAt = now;
        }
        _lastSheetSize = size;
      });
    });
  }

  // 根据相机状态与可见范围刷新附近 places（用于 Marker 展示）
  Future<void> _refreshOverlayPlaces(BuildContext context) async {
    final c = ref.read(mapControllerProvider);
    if (c == null) return;
    final bounds = ref.read(visibleRegionProvider);
    final pos = ref.read(cameraPositionProvider);
    if (bounds == null) return;

    final center = LatLng(
      (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
      (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
    );
    final r1 = haversine(center.latitude, center.longitude,
        bounds.northeast.latitude, bounds.northeast.longitude);
    final r2 = haversine(center.latitude, center.longitude,
        bounds.southwest.latitude, bounds.southwest.longitude);
    final radius = (0.5 * (r1 + r2)).clamp(100.0, 2500.0).toInt();

    // 按缩放控制预期数量上限
    final z = pos?.zoom ?? 14.0;
    int maxCount;
    if (z < 11) {
      maxCount = 20;
    } else if (z < 13) {
      maxCount = 30;
    } else if (z < 15) {
      maxCount = 45;
    } else if (z < 17) {
      maxCount = 60;
    } else {
      maxCount = 80;
    }

    // 节流：小幅移动或缩放微调且在短时间内，不触发请求（直接复用已有 overlayPlaces）
    final last = ref.read(overlayRefreshStateProvider);
    final now = DateTime.now();
    if (last != null) {
      final moved = haversine(center.latitude, center.longitude,
          last.center.latitude, last.center.longitude);
      final zoomDelta = (z - last.zoom).abs();
      final sinceMs = now.difference(last.at).inMilliseconds;
      if (sinceMs < 1200 && moved < (radius * 0.15) && zoomDelta < 0.25) {
        // 距离移动很小 + 缩放变化很小 + 时间很短：跳过网络请求
        return;
      }
    }

    // 缓存优先：按量化中心/缩放/半径 生成 key
    String _keyFor(double lat, double lng, double zoom, int r) {
      final qLat = lat.toStringAsFixed(3);
      final qLng = lng.toStringAsFixed(3);
      final zBucket = zoom.floor();
      final rBucket = ((r / 100).round() * 100);
      return 'z:$zBucket;lat:$qLat;lng:$qLng;r:$rBucket';
    }

    final cache = ref.read(overlayCacheProvider);
    final key = _keyFor(center.latitude, center.longitude, z, radius);
    final hit = cache[key];
    const ttl = Duration(seconds: 30);
    if (hit != null && now.difference(hit.at) < ttl) {
      ref.read(overlayPlacesProvider.notifier).state = hit.items;
      // 更新刷新状态，但不触发网络
      ref.read(overlayRefreshStateProvider.notifier).state =
          OverlayRefreshState(center: center, zoom: z, at: now);
      return;
    }

    final ps = ref.read(placesServiceProvider);
    final items = await ps.searchNearby(
      model.LatLngPoint(center.latitude, center.longitude),
      radiusMeters: radius,
    );
    // 综合排序：评分/评价数/类型权重为主，距离为次
    double _typeWeight(List<String> types) {
      const weights = {
        'tourist_attraction': 1.0,
        'point_of_interest': 0.6,
        'museum': 0.9,
        'park': 0.8,
        'art_gallery': 0.8,
        'restaurant': 0.6,
        'cafe': 0.5,
        'shopping_mall': 0.5,
      };
      double w = 0.0;
      for (final t in types) {
        w = w < (weights[t] ?? 0.0) ? (weights[t] ?? 0.0) : w;
      }
      return w;
    }

    double _scoreFor(a) {
      final d = haversine(
          center.latitude, center.longitude, a.location.lat, a.location.lng);
      final rating = (a.rating ?? 0.0).clamp(0.0, 5.0);
      final urt = (a.userRatingsTotal ?? 0);
      final typeW = _typeWeight(a.types);
      final pop = rating * 2.0 +
          (urt > 0 ? (1.0 * (urt.toDouble()).clamp(0, 5000) / 5000.0) : 0.0);
      final distPenalty = (d / (radius.toDouble() + 1)).clamp(0.0, 1.0);
      return pop + typeW - distPenalty; // 值越大越靠前
    }

    items.sort((a, b) => _scoreFor(b).compareTo(_scoreFor(a)));
    final trimmed = items.take(maxCount * 2).toList(growable: false);
    ref.read(overlayPlacesProvider.notifier).state = trimmed;
    // 写入缓存与刷新状态
    final newCache = {...cache, key: OverlayCacheEntry(trimmed, now)};
    ref.read(overlayCacheProvider.notifier).state = newCache;
    ref.read(overlayRefreshStateProvider.notifier).state =
        OverlayRefreshState(center: center, zoom: z, at: now);
  }

  // 不再进行像素布局：覆盖层已移除

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
        mode: mode);
    // 仅时间轴页自动适配整计划
    if (ref.read(panelPageProvider) == PanelPage.timeline) {
      unawaited(_fitToNodes(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(planControllerProvider);
    final useAmap = ref.watch(useAmapProvider);
    final searchResults = ref.watch(searchResultsProvider);
    final selected = ref.watch(selectedPlaceProvider);
    // 覆盖层已移除

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
          icon: BitmapDescriptor.defaultMarkerWithHue(
            (selected?.nodeId == n.id)
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueAzure,
          ),
          onTap: () {
            ref.read(selectedPlaceProvider.notifier).state = SelectedPlace(
              nodeId: n.id,
              title: n.title,
              point: n.point,
            );
            ref.read(panelPageProvider.notifier).state = PanelPage.detail;
            // 面板移动到 60% 中档位置
            unawaited(_sheetController.animateTo(
              0.6,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
            ));
            // 立即相机聚焦并放大（面板感知中心），高亮并显示信息窗
            final c = ref.read(mapControllerProvider);
            if (c != null) {
              unawaited(_focusPlacePanelAware(n.point, zoom: 16));
              // 尝试显示信息窗
              unawaited(Future.delayed(const Duration(milliseconds: 50), () {
                c.showMarkerInfoWindow(MarkerId(n.id));
              }));
            }
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

    // 附近 Place（通过 Places API 获取）标记
    final nearbyPlaces = ref.watch(overlayPlacesProvider);
    for (final p in nearbyPlaces) {
      final typeKey = _mainTypeKey(p.types);
      final custom = _typeIconCache[typeKey];
      if (custom == null) {
        unawaited(_ensureIconBuilt(typeKey));
      }
      markers.add(Marker(
        markerId: MarkerId('nearby_${p.id}'),
        position: LatLng(p.location.lat, p.location.lng),
        infoWindow: InfoWindow(title: p.name),
        icon: (custom ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose)),
        onTap: () {
          ref.read(selectedPlaceProvider.notifier).state = SelectedPlace(
            placeId: p.id,
            title: p.name,
            point: model.LatLngPoint(p.location.lat, p.location.lng),
          );
          ref.read(panelPageProvider.notifier).state = PanelPage.detail;
          // 面板移动到 60% 中档位置
          unawaited(_sheetController.animateTo(
            0.6,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          ));
          final c = ref.read(mapControllerProvider);
          if (c != null) {
            unawaited(_focusPlacePanelAware(
                model.LatLngPoint(p.location.lat, p.location.lng),
                zoom: 16));
            unawaited(Future.delayed(const Duration(milliseconds: 50), () {
              c.showMarkerInfoWindow(MarkerId('nearby_${p.id}'));
            }));
          }
        },
      ));
    }

    // 搜索结果标记
    for (final p in searchResults) {
      final typeKey = _mainTypeKey(p.types);
      final custom = _typeIconCache[typeKey];
      // 异步准备图标（未完成前回退默认）
      if (custom == null) {
        // 不阻塞 UI，生成后刷新
        unawaited(_ensureIconBuilt(typeKey));
      }
      markers.add(Marker(
        markerId: MarkerId('search_${p.id}'),
        position: LatLng(p.location.lat, p.location.lng),
        infoWindow: InfoWindow(title: p.name),
        icon: (selected?.placeId == p.id)
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
            : (custom ??
                BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRose)),
        onTap: () {
          ref.read(selectedPlaceProvider.notifier).state = SelectedPlace(
            placeId: p.id,
            title: p.name,
            point: model.LatLngPoint(p.location.lat, p.location.lng),
          );
          ref.read(panelPageProvider.notifier).state = PanelPage.detail;
          // 面板移动到 60% 中档位置
          unawaited(_sheetController.animateTo(
            0.6,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          ));
          // 立即相机聚焦并放大（面板感知中心），显示信息窗
          final c = ref.read(mapControllerProvider);
          if (c != null) {
            unawaited(_focusPlacePanelAware(
                model.LatLngPoint(p.location.lat, p.location.lng),
                zoom: 16));
            unawaited(Future.delayed(const Duration(milliseconds: 50), () {
              c.showMarkerInfoWindow(MarkerId('search_${p.id}'));
            }));
          }
        },
      ));
    }

    final mapWidget = useAmap
        ? Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
            buildingsEnabled: true,
            indoorViewEnabled: true,
            initialCameraPosition: _initialPosition,
            myLocationButtonEnabled: true,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            style: _mapStyleDefault,
            markers: markers,
            polylines: polylines,
            onMapCreated: (controller) {
              ref.read(mapControllerProvider.notifier).state = controller;
              // 应用默认样式（不隐藏 POI）
              () async {
                try {
                  await controller.setMapStyle(_mapStyleDefault);
                } catch (_) {}
              }();
              // 初始化可见区域
              Future.delayed(const Duration(milliseconds: 50), () async {
                try {
                  final bounds = await controller.getVisibleRegion();
                  if (mounted) {
                    ref.read(visibleRegionProvider.notifier).state = bounds;
                  }
                } catch (_) {}
              });
            },
            onCameraMove: (pos) async {
              ref.read(cameraPositionProvider.notifier).state = pos;
            },
            onCameraIdle: () async {
              final controller = ref.read(mapControllerProvider);
              if (controller != null) {
                try {
                  final bounds = await controller.getVisibleRegion();
                  ref.read(visibleRegionProvider.notifier).state = bounds;
                } catch (_) {}
              }
              // 相机空闲后刷新附近 Places（用于 Marker 展示）
              await _refreshOverlayPlaces(context);
            },
            onTap: (latLng) async {
              // 清空选中，关闭 InfoWindow
              ref.read(selectedPlaceProvider.notifier).state = null;
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
          // 覆盖层控制按钮移除
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
