import 'package:travel_planner/core/models/latlng_point.dart';
import 'package:travel_planner/core/services/places_service.dart'
    show PlaceItem, PlaceDetails, PlacesService;
import 'package:travel_planner/features/map/domain/places_repository.dart';
import 'places_remote_data_source.dart';

/// Places 仓库实现：基于现有的 PlacesService 进行封装
class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesService _svc;
  final PlacesRemoteDataSource? _remote;
  const PlacesRepositoryImpl(this._svc, {PlacesRemoteDataSource? remote})
      : _remote = remote;

  @override
  Future<List<PlaceItem>> searchText(
    String query, {
    LatLngPoint? near,
    int? radiusMeters,
  }) async {
    if (_remote?.enabled == true) {
      final r = await _remote!.searchText(query, near: near, radiusMeters: radiusMeters);
      if (r.isNotEmpty) return r;
    }
    return _svc.searchText(query, near: near, radiusMeters: radiusMeters);
  }

  @override
  Future<List<PlaceItem>> searchNearby(
    LatLngPoint center, {
    int radiusMeters = 300,
    String? keyword,
  }) async {
    if (_remote?.enabled == true) {
      final r = await _remote!.searchNearby(center, radiusMeters: radiusMeters, keyword: keyword);
      if (r.isNotEmpty) return r;
    }
    return _svc.searchNearby(center, radiusMeters: radiusMeters, keyword: keyword);
  }

  @override
  Future<PlaceDetails?> fetchPlaceDetails(String placeId) async {
    if (_remote?.enabled == true) {
      final r = await _remote!.fetchPlaceDetails(placeId);
      if (r != null) return r;
    }
    return _svc.fetchPlaceDetails(placeId);
  }
}
