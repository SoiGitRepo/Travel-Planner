import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/models/latlng_point.dart' as model;
import '../../../core/models/transport_mode.dart';
import '../../../core/services/places_service.dart' show PlaceItem;
import '../../../core/services/places_service.dart' as places;
import '../../../core/providers.dart';

final mapControllerProvider = StateProvider<GoogleMapController?>((ref) => null);
final transportModeProvider = StateProvider<TransportMode>((ref) => TransportMode.walking);
// 底部面板当前高度占屏幕高度的比例（0~1）
final sheetFractionProvider = StateProvider<double>((ref) => 0.2);
// 地图提供方切换：当 Google Play 服务不可用时切换为高德地图
final useAmapProvider = StateProvider<bool>((ref) => false);

// 底部面板当前页
enum PanelPage { timeline, search, detail }
final panelPageProvider = StateProvider<PanelPage>((ref) => PanelPage.timeline);

// 当前地图可见区域（用于限定搜索范围）
final visibleRegionProvider = StateProvider<LatLngBounds?>((ref) => null);
// 当前相机位置（用于附近 Marker 刷新）
final cameraPositionProvider = StateProvider<CameraPosition?>((ref) => null);

// 附近 place 列表（按相机缩放/范围动态刷新，用于 Marker 渲染）
final overlayPlacesProvider = StateProvider<List<PlaceItem>>((ref) => const []);

// 刷新节流状态（用于判断是否需要重新获取 Nearby）
class OverlayRefreshState {
  final LatLng center;
  final double zoom;
  final DateTime at;
  const OverlayRefreshState({required this.center, required this.zoom, required this.at});
}
final overlayRefreshStateProvider = StateProvider<OverlayRefreshState?>((ref) => null);

// 简单缓存（按量化后的中心+缩放+半径 key 缓存一段时间）
class OverlayCacheEntry {
  final List<PlaceItem> items;
  final DateTime at;
  const OverlayCacheEntry(this.items, this.at);
}
final overlayCacheProvider = StateProvider<Map<String, OverlayCacheEntry>>((ref) => <String, OverlayCacheEntry>{});

// Place 详情（评分/评论/照片等）
final placeDetailsProvider = FutureProvider.family<places.PlaceDetails?, String>((ref, placeId) async {
  final repo = ref.read(placesRepositoryProvider);
  try {
    return await repo.fetchPlaceDetails(placeId);
  } catch (_) {
    return null;
  }
});

class SelectedPlace {
  final String? nodeId; // 若为已在计划中的节点则有值
  final String? placeId; // 若来源于搜索结果则有值
  final String title;
  final model.LatLngPoint point;
  const SelectedPlace({this.nodeId, this.placeId, required this.title, required this.point});
}

final selectedPlaceProvider = StateProvider<SelectedPlace?>((ref) => null);

// 搜索结果（用于在地图上展示标记）
final searchResultsProvider = StateProvider<List<PlaceItem>>((ref) => const []);
