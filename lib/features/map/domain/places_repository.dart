import 'package:travel_planner/core/models/latlng_point.dart';
import 'package:travel_planner/core/services/places_service.dart' show PlaceItem, PlaceDetails;
import 'package:travel_planner/core/errors/failure.dart';

/// 地图-地点查询仓库契约（fpdart：显式错误建模）
abstract class PlacesRepository {
  /// 关键字搜索（可选附近范围）
  TEither<List<PlaceItem>> searchText(
    String query, {
    LatLngPoint? near,
    int? radiusMeters,
  });

  /// 附近检索（用于地图覆盖层）
  TEither<List<PlaceItem>> searchNearby(
    LatLngPoint center, {
    int radiusMeters = 300,
    String? keyword,
  });

  /// 详情查询
  TEither<PlaceDetails?> fetchPlaceDetails(String placeId);
}
