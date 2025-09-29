import 'package:travel_planner/core/errors/failure.dart';
import 'package:travel_planner/core/models/latlng_point.dart';
import 'package:travel_planner/core/services/places_service.dart' show PlaceItem, PlaceDetails;

/// 使用 fpdart 的显式错误建模版本（不影响现有 PlacesRepository）。
abstract class PlacesRepositoryFx {
  TEither<List<PlaceItem>> searchText(
    String query, {
    LatLngPoint? near,
    int? radiusMeters,
  });

  TEither<List<PlaceItem>> searchNearby(
    LatLngPoint center, {
    int radiusMeters = 300,
    String? keyword,
  });

  TEither<PlaceDetails?> fetchPlaceDetails(String placeId);
}
