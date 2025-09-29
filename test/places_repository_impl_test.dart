import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/core/models/latlng_point.dart';
import 'package:travel_planner/core/services/places_service.dart';
import 'package:travel_planner/features/map/data/places_remote_data_source.dart';
import 'package:travel_planner/features/map/data/places_repository_impl.dart';

class _FakeRemote extends PlacesRemoteDataSource {
  _FakeRemote() : super(dio: Dio(), apiKey: 'key');

  @override
  bool get enabled => true;

  @override
  Future<List<PlaceItem>> searchText(String query, {LatLngPoint? near, int? radiusMeters}) async {
    return [
      const PlaceItem(
        id: 'remote_1',
        name: 'Remote Result',
        location: LatLngPoint(1, 2),
      ),
    ];
  }

  @override
  Future<List<PlaceItem>> searchNearby(LatLngPoint center, {int radiusMeters = 300, String? keyword}) async {
    return [
      const PlaceItem(
        id: 'nearby_1',
        name: 'Nearby',
        location: LatLngPoint(1, 2),
      ),
    ];
  }

  @override
  Future<PlaceDetails?> fetchPlaceDetails(String placeId) async {
    return const PlaceDetails(id: 'id', name: 'name');
  }
}

void main() {
  test('PlacesRepositoryImpl prefers remote data source when enabled', () async {
    final repo = PlacesRepositoryImpl(const PlacesService(), remote: _FakeRemote());

    final listEither = await repo.searchText('anything').run();
    final list = listEither.getOrElse((_) => <PlaceItem>[]);
    expect(list, isNotEmpty);
    expect(list.first.id, 'remote_1');

    final nearbyEither = await repo.searchNearby(const LatLngPoint(0, 0)).run();
    final nearby = nearbyEither.getOrElse((_) => <PlaceItem>[]);
    expect(nearby, isNotEmpty);
    expect(nearby.first.id, 'nearby_1');

    final detailsEither = await repo.fetchPlaceDetails('xxx').run();
    final details = detailsEither.getOrElse((_) => null);
    expect(details, isNotNull);
    expect(details!.name, 'name');
  });
}
