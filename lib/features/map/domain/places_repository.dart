import 'package:travel_planner/core/models/latlng_point.dart';
import 'package:travel_planner/core/services/places_service.dart' show PlaceItem, PlaceDetails;

/// 地图-地点查询仓库契约
abstract class PlacesRepository {
  /// 关键字搜索（可选附近范围）
  Future<List<PlaceItem>> searchText(
    String query, {
    LatLngPoint? near,
    int? radiusMeters,
  });

  /// 附近检索（用于地图覆盖层）
  Future<List<PlaceItem>> searchNearby(
    LatLngPoint center, {
    int radiusMeters = 300,
    String? keyword,
  });

  /// 详情查询
  Future<PlaceDetails?> fetchPlaceDetails(String placeId);
}
