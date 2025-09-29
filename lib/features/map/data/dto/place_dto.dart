// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_dto.freezed.dart';
part 'place_dto.g.dart';

@freezed
abstract class LocationDto with _$LocationDto {
  const factory LocationDto({
    required double lat,
    required double lng,
  }) = _LocationDto;

  factory LocationDto.fromJson(Map<String, dynamic> json) => _$LocationDtoFromJson(json);
}

@freezed
abstract class GeometryDto with _$GeometryDto {
  const factory GeometryDto({
    required LocationDto location,
  }) = _GeometryDto;

  factory GeometryDto.fromJson(Map<String, dynamic> json) => _$GeometryDtoFromJson(json);
}

@freezed
abstract class PlaceItemDto with _$PlaceItemDto {
  const factory PlaceItemDto({
    @JsonKey(name: 'place_id') required String placeId,
    required String name,
    @JsonKey(name: 'formatted_address') String? formattedAddress,
    String? vicinity,
    GeometryDto? geometry,
    double? rating,
    @JsonKey(name: 'user_ratings_total') int? userRatingsTotal,
    @Default(<String>[]) List<String> types,
    @JsonKey(name: 'price_level') int? priceLevel,
  }) = _PlaceItemDto;

  factory PlaceItemDto.fromJson(Map<String, dynamic> json) => _$PlaceItemDtoFromJson(json);
}

@freezed
abstract class OpeningHoursDto with _$OpeningHoursDto {
  const factory OpeningHoursDto({
    @JsonKey(name: 'weekday_text') @Default(<String>[]) List<String> weekdayText,
  }) = _OpeningHoursDto;

  factory OpeningHoursDto.fromJson(Map<String, dynamic> json) => _$OpeningHoursDtoFromJson(json);
}

@freezed
abstract class PhotoDto with _$PhotoDto {
  const factory PhotoDto({
    @JsonKey(name: 'photo_reference') String? photoReference,
    int? width,
    int? height,
  }) = _PhotoDto;

  factory PhotoDto.fromJson(Map<String, dynamic> json) => _$PhotoDtoFromJson(json);
}

@freezed
abstract class PlaceDetailsDto with _$PlaceDetailsDto {
  const factory PlaceDetailsDto({
    @JsonKey(name: 'place_id') required String placeId,
    required String name,
    @JsonKey(name: 'formatted_address') String? formattedAddress,
    GeometryDto? geometry,
    double? rating,
    @JsonKey(name: 'user_ratings_total') int? userRatingsTotal,
    @Default(<String>[]) List<String> types,
    @JsonKey(name: 'price_level') int? priceLevel,
    @JsonKey(name: 'formatted_phone_number') String? formattedPhoneNumber,
    String? website,
    @JsonKey(name: 'opening_hours') OpeningHoursDto? openingHours,
    @Default(<PhotoDto>[]) List<PhotoDto> photos,
  }) = _PlaceDetailsDto;

  factory PlaceDetailsDto.fromJson(Map<String, dynamic> json) => _$PlaceDetailsDtoFromJson(json);
}

@freezed
abstract class TextSearchResponseDto with _$TextSearchResponseDto {
  const factory TextSearchResponseDto({
    @Default(<PlaceItemDto>[]) List<PlaceItemDto> results,
    String? status,
  }) = _TextSearchResponseDto;

  factory TextSearchResponseDto.fromJson(Map<String, dynamic> json) => _$TextSearchResponseDtoFromJson(json);
}

@freezed
abstract class NearbySearchResponseDto with _$NearbySearchResponseDto {
  const factory NearbySearchResponseDto({
    @Default(<PlaceItemDto>[]) List<PlaceItemDto> results,
    String? status,
  }) = _NearbySearchResponseDto;

  factory NearbySearchResponseDto.fromJson(Map<String, dynamic> json) => _$NearbySearchResponseDtoFromJson(json);
}

@freezed
abstract class DetailsResponseDto with _$DetailsResponseDto {
  const factory DetailsResponseDto({
    PlaceDetailsDto? result,
    String? status,
  }) = _DetailsResponseDto;

  factory DetailsResponseDto.fromJson(Map<String, dynamic> json) => _$DetailsResponseDtoFromJson(json);
}
