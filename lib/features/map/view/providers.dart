import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/models/latlng_point.dart' as model;
import '../../../core/models/transport_mode.dart';
import '../../../core/services/places_service.dart' show PlaceItem;

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
// 当前相机位置（用于覆盖层定位与密度控制）
final cameraPositionProvider = StateProvider<CameraPosition?>((ref) => null);
// 选中 Place 的屏幕像素位置（用于覆盖层定位）
class OverlayPos {
  final double x;
  final double y;
  const OverlayPos(this.x, this.y);
}
final selectedOverlayPosProvider = StateProvider<OverlayPos?>((ref) => null);

// 密集覆盖层候选 place 列表（按相机缩放/范围动态刷新）
final overlayPlacesProvider = StateProvider<List<PlaceItem>>((ref) => const []);

// 用于渲染的覆盖层条目（已包含像素坐标与碰撞裁剪后的结果）
class OverlayRenderItem {
  final PlaceItem place;
  final OverlayPos pos;
  const OverlayRenderItem({required this.place, required this.pos});
}
final overlayRenderItemsProvider = StateProvider<List<OverlayRenderItem>>((ref) => const []);

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
