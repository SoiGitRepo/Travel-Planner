import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:travel_planner/core/widgets/glassy/glassy.dart';
import 'package:google_api_availability/google_api_availability.dart';
// import 'package:go_router/go_router.dart';

import '../../../core/models/latlng_point.dart' as model;
import '../../plan/presentation/plan_controller.dart';
import 'providers.dart';
import 'timeline_panel.dart';
import 'marker_icons.dart';
import '../application/overlay_controller.dart';
import '../application/camera_usecases.dart';

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
    await ref
        .read(cameraUsecaseProvider)
        .focusPlacePanelAware(p, zoom: zoom, animate: animate);
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
    if (_typeIconCache.containsKey(key) || _pendingIconKeys.contains(key)) {
      return;
    }
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
          _fitToNodes(animate: shouldAnimate);
        }
        if (shouldAnimate) {
          _lastAnimateAt = now;
        }
        _lastSheetSize = size;
      });
    });
  }

  // 根据相机状态与可见范围刷新附近 places（用于 Marker 展示）
  Future<void> _refreshOverlayPlaces() async {
    await ref.read(overlayControllerProvider).refreshFromCurrentView();
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

  Future<void> _fitToNodes({bool animate = true}) async {
    await ref.read(cameraUsecaseProvider).fitToNodes(animate: animate);
  }

  Future<void> _onLongPress(LatLng point) async {
    final mode = ref.read(transportModeProvider);
    await ref.read(planControllerProvider.notifier).addNodeAt(
        model.LatLngPoint(point.latitude, point.longitude),
        mode: mode);
    // 仅时间轴页自动适配整计划
    if (ref.read(panelPageProvider) == PanelPage.timeline) {
      unawaited(_fitToNodes());
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
          onTap: () async {
            ref.read(selectedPlaceProvider.notifier).state = SelectedPlace(
              nodeId: n.id,
              title: n.title,
              point: n.point,
            );
            ref.read(panelPageProvider.notifier).state = PanelPage.detail;
            // 面板移动到 60% 中档位置
            await _sheetController.animateTo(
              0.6,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
            );
            // 立即相机聚焦并放大（面板感知中心），高亮并显示信息窗
            final c = ref.read(mapControllerProvider);
            if (c != null) {
              await _focusPlacePanelAware(n.point, zoom: 16);
              // 尝试显示信息窗
              c.showMarkerInfoWindow(MarkerId(n.id));
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
        onTap: () async {
          ref.read(selectedPlaceProvider.notifier).state = SelectedPlace(
            placeId: p.id,
            title: p.name,
            point: model.LatLngPoint(p.location.lat, p.location.lng),
          );
          ref.read(panelPageProvider.notifier).state = PanelPage.detail;
          // 面板移动到 60% 中档位置
          await _sheetController.animateTo(
            0.6,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          );
          final c = ref.read(mapControllerProvider);
          if (c != null) {
            await _focusPlacePanelAware(
                model.LatLngPoint(p.location.lat, p.location.lng),
                zoom: 16);
            c.showMarkerInfoWindow(MarkerId('nearby_${p.id}'));
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
        onTap: () async {
          ref.read(selectedPlaceProvider.notifier).state = SelectedPlace(
            placeId: p.id,
            title: p.name,
            point: model.LatLngPoint(p.location.lat, p.location.lng),
          );
          ref.read(panelPageProvider.notifier).state = PanelPage.detail;
          // 面板移动到 60% 中档位置
          await _sheetController.animateTo(
            0.6,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          );
          // 立即相机聚焦并放大（面板感知中心），显示信息窗
          final c = ref.read(mapControllerProvider);
          if (c != null) {
            await _focusPlacePanelAware(
                model.LatLngPoint(p.location.lat, p.location.lng),
                zoom: 16);
            c.showMarkerInfoWindow(MarkerId('search_${p.id}'));
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
              await _refreshOverlayPlaces();
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
              onPressed: () => _fitToNodes(),
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
