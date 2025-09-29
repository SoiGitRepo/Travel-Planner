// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocationDto _$LocationDtoFromJson(Map<String, dynamic> json) => _LocationDto(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$LocationDtoToJson(_LocationDto instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };

_GeometryDto _$GeometryDtoFromJson(Map<String, dynamic> json) => _GeometryDto(
      location: LocationDto.fromJson(json['location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GeometryDtoToJson(_GeometryDto instance) =>
    <String, dynamic>{
      'location': instance.location,
    };

_PlaceItemDto _$PlaceItemDtoFromJson(Map<String, dynamic> json) =>
    _PlaceItemDto(
      placeId: json['place_id'] as String,
      name: json['name'] as String,
      formattedAddress: json['formatted_address'] as String?,
      vicinity: json['vicinity'] as String?,
      geometry: json['geometry'] == null
          ? null
          : GeometryDto.fromJson(json['geometry'] as Map<String, dynamic>),
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: (json['user_ratings_total'] as num?)?.toInt(),
      types:
          (json['types'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      priceLevel: (json['price_level'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PlaceItemDtoToJson(_PlaceItemDto instance) =>
    <String, dynamic>{
      'place_id': instance.placeId,
      'name': instance.name,
      'formatted_address': instance.formattedAddress,
      'vicinity': instance.vicinity,
      'geometry': instance.geometry,
      'rating': instance.rating,
      'user_ratings_total': instance.userRatingsTotal,
      'types': instance.types,
      'price_level': instance.priceLevel,
    };

_OpeningHoursDto _$OpeningHoursDtoFromJson(Map<String, dynamic> json) =>
    _OpeningHoursDto(
      weekdayText: (json['weekday_text'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$OpeningHoursDtoToJson(_OpeningHoursDto instance) =>
    <String, dynamic>{
      'weekday_text': instance.weekdayText,
    };

_PhotoDto _$PhotoDtoFromJson(Map<String, dynamic> json) => _PhotoDto(
      photoReference: json['photo_reference'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PhotoDtoToJson(_PhotoDto instance) => <String, dynamic>{
      'photo_reference': instance.photoReference,
      'width': instance.width,
      'height': instance.height,
    };

_PlaceDetailsDto _$PlaceDetailsDtoFromJson(Map<String, dynamic> json) =>
    _PlaceDetailsDto(
      placeId: json['place_id'] as String,
      name: json['name'] as String,
      formattedAddress: json['formatted_address'] as String?,
      geometry: json['geometry'] == null
          ? null
          : GeometryDto.fromJson(json['geometry'] as Map<String, dynamic>),
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: (json['user_ratings_total'] as num?)?.toInt(),
      types:
          (json['types'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      priceLevel: (json['price_level'] as num?)?.toInt(),
      formattedPhoneNumber: json['formatted_phone_number'] as String?,
      website: json['website'] as String?,
      openingHours: json['opening_hours'] == null
          ? null
          : OpeningHoursDto.fromJson(
              json['opening_hours'] as Map<String, dynamic>),
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => PhotoDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PhotoDto>[],
    );

Map<String, dynamic> _$PlaceDetailsDtoToJson(_PlaceDetailsDto instance) =>
    <String, dynamic>{
      'place_id': instance.placeId,
      'name': instance.name,
      'formatted_address': instance.formattedAddress,
      'geometry': instance.geometry,
      'rating': instance.rating,
      'user_ratings_total': instance.userRatingsTotal,
      'types': instance.types,
      'price_level': instance.priceLevel,
      'formatted_phone_number': instance.formattedPhoneNumber,
      'website': instance.website,
      'opening_hours': instance.openingHours,
      'photos': instance.photos,
    };

_TextSearchResponseDto _$TextSearchResponseDtoFromJson(
        Map<String, dynamic> json) =>
    _TextSearchResponseDto(
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => PlaceItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PlaceItemDto>[],
      status: json['status'] as String?,
    );

Map<String, dynamic> _$TextSearchResponseDtoToJson(
        _TextSearchResponseDto instance) =>
    <String, dynamic>{
      'results': instance.results,
      'status': instance.status,
    };

_NearbySearchResponseDto _$NearbySearchResponseDtoFromJson(
        Map<String, dynamic> json) =>
    _NearbySearchResponseDto(
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => PlaceItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PlaceItemDto>[],
      status: json['status'] as String?,
    );

Map<String, dynamic> _$NearbySearchResponseDtoToJson(
        _NearbySearchResponseDto instance) =>
    <String, dynamic>{
      'results': instance.results,
      'status': instance.status,
    };

_DetailsResponseDto _$DetailsResponseDtoFromJson(Map<String, dynamic> json) =>
    _DetailsResponseDto(
      result: json['result'] == null
          ? null
          : PlaceDetailsDto.fromJson(json['result'] as Map<String, dynamic>),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$DetailsResponseDtoToJson(_DetailsResponseDto instance) =>
    <String, dynamic>{
      'result': instance.result,
      'status': instance.status,
    };
