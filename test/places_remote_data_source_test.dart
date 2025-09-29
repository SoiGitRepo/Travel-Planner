import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:travel_planner/core/models/latlng_point.dart';
import 'package:travel_planner/features/map/data/places_remote_data_source.dart';
import 'package:travel_planner/features/map/data/places_api.dart';
import 'package:travel_planner/features/map/data/dto/place_dto.dart';
import 'package:retrofit/retrofit.dart';

class _MockPlacesApi extends Mock implements PlacesApi {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('PlacesRemoteDataSource (Retrofit DTO mapping)', () {
    late Dio dio;
    late _MockPlacesApi api;
    late PlacesRemoteDataSource ds;

    setUp(() {
      dio = Dio();
      api = _MockPlacesApi();
      ds = PlacesRemoteDataSource(dio: dio, apiKey: 'test_key', api: api);
    });

    test('searchText maps PlaceItemDto -> PlaceItem', () async {
      const dto = PlaceItemDto(
        placeId: 'pid',
        name: 'The Place',
        formattedAddress: 'Addr',
        vicinity: null,
        geometry: GeometryDto(location: LocationDto(lat: 11.1, lng: 22.2)),
        rating: 4.5,
        userRatingsTotal: 120,
        types: ['tourist_attraction', 'point_of_interest'],
        priceLevel: 2,
      );
      final httpResp = HttpResponse<TextSearchResponseDto>(
        const TextSearchResponseDto(results: [dto], status: 'OK'),
        Response(requestOptions: RequestOptions(path: '/textsearch'), statusCode: 200),
      );
      when(() => api.textSearch(any())).thenAnswer((_) async => httpResp);

      final list = await ds.searchText('abc', near: const LatLngPoint(1, 2), radiusMeters: 300);
      expect(list.length, 1);
      final item = list.first;
      expect(item.id, 'pid');
      expect(item.name, 'The Place');
      expect(item.address, 'Addr');
      expect(item.location.lat, closeTo(11.1, 1e-6));
      expect(item.location.lng, closeTo(22.2, 1e-6));
      expect(item.rating, 4.5);
      expect(item.userRatingsTotal, 120);
      expect(item.types, contains('tourist_attraction'));
      expect(item.priceLevel, 2);
    });

    test('searchNearby maps PlaceItemDto with vicinity', () async {
      const dto = PlaceItemDto(
        placeId: 'nid',
        name: 'Nearby',
        formattedAddress: null,
        vicinity: 'Near Addr',
        geometry: GeometryDto(location: LocationDto(lat: 0.3, lng: 0.4)),
        rating: null,
        userRatingsTotal: null,
        types: ['cafe'],
        priceLevel: null,
      );
      final httpResp = HttpResponse<NearbySearchResponseDto>(
        const NearbySearchResponseDto(results: [dto], status: 'OK'),
        Response(requestOptions: RequestOptions(path: '/nearby'), statusCode: 200),
      );
      when(() => api.nearbySearch(any())).thenAnswer((_) async => httpResp);

      final list = await ds.searchNearby(const LatLngPoint(0, 0));
      expect(list, isNotEmpty);
      expect(list.first.address, 'Near Addr');
    });

    test('details maps PlaceDetailsDto -> PlaceDetails with photo urls', () async {
      const details = PlaceDetailsDto(
        placeId: 'did',
        name: 'Detail Place',
        formattedAddress: 'Full Addr',
        geometry: GeometryDto(location: LocationDto(lat: 9.9, lng: 8.8)),
        rating: 3.7,
        userRatingsTotal: 10,
        types: ['museum'],
        priceLevel: 1,
        formattedPhoneNumber: '123',
        website: 'https://example.com',
        openingHours: OpeningHoursDto(weekdayText: ['Mon: 9-18']),
        photos: [PhotoDto(photoReference: 'ref1', width: 640, height: 480)],
      );
      final httpResp = HttpResponse<DetailsResponseDto>(
        const DetailsResponseDto(result: details, status: 'OK'),
        Response(requestOptions: RequestOptions(path: '/details'), statusCode: 200),
      );
      when(() => api.details(any())).thenAnswer((_) async => httpResp);

      final d = await ds.fetchPlaceDetails('did');
      expect(d, isNotNull);
      expect(d!.name, 'Detail Place');
      expect(d.address, 'Full Addr');
      expect(d.location!.lat, closeTo(9.9, 1e-6));
      expect(d.photoUrls, isNotEmpty);
      expect(d.photoUrls.first, contains('/maps/api/place/photo'));
      expect(d.photoUrls.first, contains('photo_reference=ref1'));
      expect(d.photoUrls.first, contains('key=test_key'));
    });
  });
}
