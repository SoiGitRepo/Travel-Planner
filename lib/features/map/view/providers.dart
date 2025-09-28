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
