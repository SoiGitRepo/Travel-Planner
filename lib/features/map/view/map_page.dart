import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

class MapPage extends HookConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 基础常量
    const initialPosition = CameraPosition(
      target: LatLng(37.7749, -122.4194),
      zoom: 12,
    );
    const mapStyleDefault =
        '[{"featureType":"poi","elementType":"labels","stylers":[{"visibility":"off"}]}]';

    // hooks 状态
    final sheetController =
        useMemoized(() => DraggableScrollableController(), const []);
    final fitDebounce = useRef<Timer?>(null);
    final lastAnimateAt = useRef<DateTime?>(null);
    final lastSheetSize = useRef<double>(0.2);
    final typeIconCache = useState<Map<String, BitmapDescriptor>>({});
    final pendingIconKeys = useState<Set<String>>({});
    // 附近地点专用更小尺寸图标缓存
    final nearbyIconCache = useState<Map<String, BitmapDescriptor>>({});
    final pendingNearbyIconKeys = useState<Set<String>>({});

    String mainTypeKey(List<String> types) {
      if (types.contains('tourist_attraction')) return 'tourist_attraction';
      if (types.contains('museum')) return 'museum';
      if (types.contains('art_gallery')) return 'art_gallery';
      if (types.contains('park')) return 'park';
      if (types.contains('restaurant')) return 'restaurant';
      if (types.contains('cafe')) return 'cafe';
      if (types.contains('shopping_mall')) return 'shopping_mall';
      return 'default';
    }

    (IconData, Color) iconForType(String key) {
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

    Future<void> ensureIconBuilt(String key) async {
      if (typeIconCache.value.containsKey(key) ||
          pendingIconKeys.value.contains(key)) {
        return;
      }
      pendingIconKeys.value = {...pendingIconKeys.value, key};
      final (iconData, bg) = iconForType(key);
      final bmp = await MarkerIconFactory.create(
          icon: iconData, background: bg, foreground: Colors.white, size: 36);
      if (!context.mounted) return;
      final next = Map<String, BitmapDescriptor>.from(typeIconCache.value)
        ..[key] = bmp;
      typeIconCache.value = next;
      final nextPending = Set<String>.from(pendingIconKeys.value)..remove(key);
      pendingIconKeys.value = nextPending;
    }

    // 为附近地点生成更小的图标（例如 28px）
    Future<void> ensureNearbyIconBuilt(String key) async {
      if (nearbyIconCache.value.containsKey(key) ||
          pendingNearbyIconKeys.value.contains(key)) {
        return;
      }
      pendingNearbyIconKeys.value = {...pendingNearbyIconKeys.value, key};
      final (iconData, bg) = iconForType(key);
      final bmp = await MarkerIconFactory.create(
          icon: iconData, background: bg, foreground: Colors.white, size: 28);
      if (!context.mounted) return;
      final next = Map<String, BitmapDescriptor>.from(nearbyIconCache.value)
        ..[key] = bmp;
      nearbyIconCache.value = next;
      final nextPending = Set<String>.from(pendingNearbyIconKeys.value)
        ..remove(key);
      pendingNearbyIconKeys.value = nextPending;
    }

    Future<void> focusPlacePanelAware(model.LatLngPoint p,
        {double zoom = 16, bool animate = true}) async {
      await ref
          .read(cameraUsecaseProvider)
          .focusPlacePanelAware(p, zoom: zoom, animate: animate);
    }

    Future<void> fitToNodes({bool animate = true}) async {
      await ref.read(cameraUsecaseProvider).fitToNodes(animate: animate);
    }

    Future<void> refreshOverlayPlaces() async {
      await ref.read(overlayControllerProvider).refreshFromCurrentView();
    }

    Future<void> onLongPress(LatLng point) async {
      final mode = ref.read(transportModeProvider);
      await ref.read(planControllerProvider.notifier).addNodeAt(
            model.LatLngPoint(point.latitude, point.longitude),
            mode: mode,
          );
      if (ref.read(panelPageProvider) == PanelPage.timeline) {
        unawaited(fitToNodes());
      }
    }

    // 检测 Play Services 可用性并写入 Provider
    useEffect(() {
      () async {
        try {
          final availability = await GoogleApiAvailability.instance
              .checkGooglePlayServicesAvailability();
          final useAmap =
              availability != GooglePlayServicesAvailability.success;
          if (context.mounted) {
            ref.read(useAmapProvider.notifier).state = useAmap;
          }
        } catch (_) {}
      }();
      return null;
    }, const []);

    // 监听底部面板滚动，更新 fraction 与相机自适配
    useEffect(() {
      void listener() {
        final size = sheetController.size;
        ref.read(sheetFractionProvider.notifier).state = size;
        fitDebounce.value?.cancel();
        fitDebounce.value = Timer(const Duration(milliseconds: 90), () {
          final delta = (size - lastSheetSize.value).abs();
          final now = DateTime.now();
          final since = lastAnimateAt.value == null
              ? const Duration(milliseconds: 999)
              : now.difference(lastAnimateAt.value!);
          const snaps = [0.12, 0.6, 0.9];
          final nearSnap = snaps.any((s) => (size - s).abs() < 0.02);
          final shouldAnimate =
              nearSnap || delta > 0.08 || since.inMilliseconds > 320;
          if (ref.read(panelPageProvider) == PanelPage.timeline) {
            unawaited(fitToNodes(animate: shouldAnimate));
          }
          if (shouldAnimate) {
            lastAnimateAt.value = now;
          }
          lastSheetSize.value = size;
        });
      }

      sheetController.addListener(listener);
      return () {
        fitDebounce.value?.cancel();
        sheetController.removeListener(listener);
        sheetController.dispose();
      };
    }, [sheetController]);

    // 读取状态
    final planAsync = ref.watch(planControllerProvider);
    final useAmap = ref.watch(useAmapProvider);
    final searchResults = ref.watch(searchResultsProvider);
    final selected = ref.watch(selectedPlaceProvider);

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
            await sheetController.animateTo(0.6,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic);
            final c = ref.read(mapControllerProvider);
            if (c != null) {
              await focusPlacePanelAware(n.point, zoom: 16);
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

    // 附近 Place 标记
    final nearbyPlaces = ref.watch(overlayPlacesProvider);
    for (final p in nearbyPlaces) {
      final typeKey = mainTypeKey(p.types);
      final nearbyIcon = nearbyIconCache.value[typeKey];
      if (nearbyIcon == null) {
        unawaited(ensureNearbyIconBuilt(typeKey));
      }
      markers.add(Marker(
        markerId: MarkerId('nearby_${p.id}'),
        position: LatLng(p.location.lat, p.location.lng),
        infoWindow: InfoWindow(title: p.name),
        icon: (nearbyIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose)),
        onTap: () async {
          ref.read(selectedPlaceProvider.notifier).state = SelectedPlace(
            placeId: p.id,
            title: p.name,
            point: model.LatLngPoint(p.location.lat, p.location.lng),
          );
          ref.read(panelPageProvider.notifier).state = PanelPage.detail;
          await sheetController.animateTo(0.6,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic);
          final c = ref.read(mapControllerProvider);
          if (c != null) {
            await focusPlacePanelAware(
                model.LatLngPoint(p.location.lat, p.location.lng),
                zoom: 16);
            c.showMarkerInfoWindow(MarkerId('nearby_${p.id}'));
          }
        },
      ));
    }

    // 搜索结果标记
    for (final p in searchResults) {
      final typeKey = mainTypeKey(p.types);
      final custom = typeIconCache.value[typeKey];
      if (custom == null) {
        unawaited(ensureIconBuilt(typeKey));
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
          await sheetController.animateTo(0.6,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic);
          final c = ref.read(mapControllerProvider);
          if (c != null) {
            await focusPlacePanelAware(
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
                Text('当前设备不支持谷歌服务，已切换高德地图（占位）',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center),
                SizedBox(height: 8),
                Text('请稍后在配置中补充高德 API Key 后启用真实地图渲染',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                    textAlign: TextAlign.center),
              ],
            ),
          )
        : GoogleMap(
            buildingsEnabled: true,
            indoorViewEnabled: true,
            initialCameraPosition: initialPosition,
            myLocationButtonEnabled: true,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            style: mapStyleDefault,
            markers: markers,
            polylines: polylines,
            onMapCreated: (controller) {
              ref.read(mapControllerProvider.notifier).state = controller;
              Future.delayed(const Duration(milliseconds: 50), () async {
                try {
                  final bounds = await controller.getVisibleRegion();
                  if (context.mounted) {
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
              await refreshOverlayPlaces();
            },
            onTap: (latLng) async {
              ref.read(selectedPlaceProvider.notifier).state = null;
            },
            onLongPress: onLongPress,
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
              onPressed: () => fitToNodes(),
              icon: const Icon(Icons.center_focus_strong),
              label: const Text('适配视野'),
            ).glassy(
              borderRadius: 12,
              settings: const LiquidGlassSettings(blur: 1),
            ),
          ),
          TimelinePanel(controller: sheetController),
          if (planAsync.isLoading)
            const Positioned.fill(
              child: IgnorePointer(
                  child: Center(child: CircularProgressIndicator())),
            ),
        ],
      ),
    );
  }
}
