import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:travel_planner/core/errors/failure.dart';
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
  TEither<List<PlaceItem>> searchText(
    String query, {
    LatLngPoint? near,
    int? radiusMeters,
  }) {
    return TaskEither<Failure, List<PlaceItem>>.tryCatch(
      () async {
        if (_remote?.enabled == true) {
          final r = await _remote!.searchText(query, near: near, radiusMeters: radiusMeters);
          if (r.isNotEmpty) return r;
        }
        return _svc.searchText(query, near: near, radiusMeters: radiusMeters);
      },
      (e, s) => _mapError('searchText', e, s),
    );
  }

  @override
  TEither<List<PlaceItem>> searchNearby(
    LatLngPoint center, {
    int radiusMeters = 300,
    String? keyword,
  }) {
    return TaskEither<Failure, List<PlaceItem>>.tryCatch(
      () async {
        if (_remote?.enabled == true) {
          final r = await _remote!.searchNearby(center, radiusMeters: radiusMeters, keyword: keyword);
          if (r.isNotEmpty) return r;
        }
        return _svc.searchNearby(center, radiusMeters: radiusMeters, keyword: keyword);
      },
      (e, s) => _mapError('searchNearby', e, s),
    );
  }

  @override
  TEither<PlaceDetails?> fetchPlaceDetails(String placeId) {
    return TaskEither<Failure, PlaceDetails?>.tryCatch(
      () async {
        if (_remote?.enabled == true) {
          final r = await _remote!.fetchPlaceDetails(placeId);
          if (r != null) return r;
        }
        return _svc.fetchPlaceDetails(placeId);
      },
      (e, s) => _mapError('fetchPlaceDetails', e, s),
    );
  }

  Failure _mapError(String scope, Object e, StackTrace s) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
        return NetworkFailure('网络连接失败（$scope）', cause: e, stackTrace: s);
      }
      final code = e.response?.statusCode;
      return ApiFailure('接口错误（$scope）', statusCode: code, cause: e, stackTrace: s);
    }
    return UnknownFailure('未知错误（$scope）', cause: e, stackTrace: s);
  }
}
