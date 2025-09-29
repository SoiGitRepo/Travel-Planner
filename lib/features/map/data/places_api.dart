import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'dto/place_dto.dart';

part 'places_api.g.dart';

@RestApi(baseUrl: 'https://maps.googleapis.com/maps/api/place')
abstract class PlacesApi {
  factory PlacesApi(Dio dio, {String baseUrl}) = _PlacesApi;

  @GET('/textsearch/json')
  Future<HttpResponse<TextSearchResponseDto>> textSearch(
    @Queries() Map<String, dynamic> queries,
  );

  @GET('/nearbysearch/json')
  Future<HttpResponse<NearbySearchResponseDto>> nearbySearch(
    @Queries() Map<String, dynamic> queries,
  );

  @GET('/details/json')
  Future<HttpResponse<DetailsResponseDto>> details(
    @Queries() Map<String, dynamic> queries,
  );
}
