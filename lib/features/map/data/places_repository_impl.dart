import 'package:travel_planner/core/models/latlng_point.dart';
import 'package:travel_planner/core/services/places_service.dart'
    show PlaceItem, PlaceDetails, PlacesService;
import 'package:travel_planner/features/map/domain/places_repository.dart';

/// Places 仓库实现：基于现有的 PlacesService 进行封装
class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesService _svc;
  const PlacesRepositoryImpl(this._svc);

  @override
  Future<List<PlaceItem>> searchText(
    String query, {
    LatLngPoint? near,
    int? radiusMeters,
  }) async {
    return _svc.searchText(query, near: near, radiusMeters: radiusMeters);
  }

  @override
  Future<List<PlaceItem>> searchNearby(
    LatLngPoint center, {
    int radiusMeters = 300,
    String? keyword,
  }) async {
    return _svc.searchNearby(center, radiusMeters: radiusMeters, keyword: keyword);
  }

  @override
  Future<PlaceDetails?> fetchPlaceDetails(String placeId) async {
    return _svc.fetchPlaceDetails(placeId);
  }
}
