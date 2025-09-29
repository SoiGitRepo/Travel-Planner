import 'package:fpdart/fpdart.dart';
import 'package:travel_planner/core/errors/failure.dart';
import 'package:travel_planner/core/models/latlng_point.dart';
import 'package:travel_planner/core/services/places_service.dart' show PlaceItem, PlaceDetails;
import 'package:travel_planner/features/map/domain/places_repository.dart';
import 'package:travel_planner/features/map/domain/places_repository_fx.dart';

class PlacesRepositoryFxImpl implements PlacesRepositoryFx {
  final PlacesRepository _repo; // 复用现有实现（含 Retrofit/回退）
  const PlacesRepositoryFxImpl(this._repo);

  @override
  TEither<List<PlaceItem>> searchText(String query, {LatLngPoint? near, int? radiusMeters}) {
    return TaskEither.tryCatch(
      () => _repo.searchText(query, near: near, radiusMeters: radiusMeters),
      (e, s) => UnknownFailure('searchText failed', cause: e, stackTrace: s),
    );
  }

  @override
  TEither<List<PlaceItem>> searchNearby(LatLngPoint center, {int radiusMeters = 300, String? keyword}) {
    return TaskEither.tryCatch(
      () => _repo.searchNearby(center, radiusMeters: radiusMeters, keyword: keyword),
      (e, s) => UnknownFailure('searchNearby failed', cause: e, stackTrace: s),
    );
  }

  @override
  TEither<PlaceDetails?> fetchPlaceDetails(String placeId) {
    return TaskEither.tryCatch(
      () => _repo.fetchPlaceDetails(placeId),
      (e, s) => UnknownFailure('fetchPlaceDetails failed', cause: e, stackTrace: s),
    );
  }
}
