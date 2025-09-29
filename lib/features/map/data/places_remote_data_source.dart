import 'package:dio/dio.dart';
import 'dart:developer' as dev;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'places_api.dart';
import 'dto/place_dto.dart';

import '../../../core/models/latlng_point.dart';
import '../../../core/services/places_service.dart' show PlaceItem, PlaceDetails;

class PlacesRemoteDataSource {
  final Dio dio;
  final String? apiKey;
  final PlacesApi? api; // 可选的 Retrofit 客户端
  const PlacesRemoteDataSource({required this.dio, required this.apiKey, this.api});

  factory PlacesRemoteDataSource.fromEnv(Dio dio) {
    final key = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? dotenv.env['GOOGLE_DIRECTIONS_API_KEY'];
    return PlacesRemoteDataSource(dio: dio, apiKey: key, api: null);
  }

  factory PlacesRemoteDataSource.withRetrofit(Dio dio) {
    final key = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? dotenv.env['GOOGLE_DIRECTIONS_API_KEY'];
    return PlacesRemoteDataSource(dio: dio, apiKey: key, api: PlacesApi(dio));
  }

  bool get enabled => apiKey != null && apiKey!.isNotEmpty;

  Future<List<PlaceItem>> searchText(String query, {LatLngPoint? near, int? radiusMeters}) async {
    if (!enabled) return const [];
    final radius = (radiusMeters != null && radiusMeters > 0) ? radiusMeters : 30000;
    final queries = <String, dynamic>{
      'query': query,
      'key': apiKey,
      'language': 'zh-CN',
      if (near != null) 'location': '${near.lat},${near.lng}',
      if (near != null) 'radius': radius,
    };
    try {
      if (api != null) {
        final resp = await api!.textSearch(queries);
        final results = resp.data.results;
        return results.map(_toPlaceItem).toList(growable: false);
      }
      // 回退：Dio 直调
      final resp = await dio.get(
        'https://maps.googleapis.com/maps/api/place/textsearch/json',
        queryParameters: queries,
      );
      if (resp.statusCode != 200) return const [];
      final data = resp.data as Map<String, dynamic>;
      final results = (data['results'] as List?) ?? const [];
      return results.map((e) {
        final m = (e as Map).cast<String, dynamic>();
        final id = (m['place_id'] as String?) ?? '';
        final name = (m['name'] as String?) ?? '未命名';
        final addr = m['formatted_address'] as String?;
        final geo = (m['geometry'] as Map<String, dynamic>?)?['location'] as Map<String, dynamic>?;
        final lat = (geo?['lat'] as num?)?.toDouble() ?? 0;
        final lng = (geo?['lng'] as num?)?.toDouble() ?? 0;
        final rating = (m['rating'] as num?)?.toDouble();
        final urt = (m['user_ratings_total'] as num?)?.toInt();
        final types = ((m['types'] as List?) ?? const [])
            .map((e) => (e as String?) ?? '')
            .where((s) => s.isNotEmpty)
            .toList(growable: false);
        final price = (m['price_level'] as num?)?.toInt();
        return PlaceItem(
          id: id,
          name: name,
          address: addr,
          location: LatLngPoint(lat, lng),
          rating: rating,
          userRatingsTotal: urt,
          types: types,
          priceLevel: price,
        );
      }).toList(growable: false);
    } catch (e, st) {
      dev.log('PlacesRemoteDataSource.searchText error: $e', name: 'places', stackTrace: st);
      return const [];
    }
  }

  Future<List<PlaceItem>> searchNearby(LatLngPoint center, {int radiusMeters = 300, String? keyword}) async {
    if (!enabled) return const [];
    final queries = <String, dynamic>{
      'key': apiKey,
      'location': '${center.lat},${center.lng}',
      'radius': radiusMeters,
      'language': 'zh-CN',
      if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
    };
    try {
      if (api != null) {
        final resp = await api!.nearbySearch(queries);
        return resp.data.results.map(_toPlaceItem).toList(growable: false);
      }
      final resp = await dio.get(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
        queryParameters: queries,
      );
      if (resp.statusCode != 200) return const [];
      final data = resp.data as Map<String, dynamic>;
      final results = (data['results'] as List?) ?? const [];
      return results.map((e) {
        final m = (e as Map).cast<String, dynamic>();
        final id = (m['place_id'] as String?) ?? '';
        final name = (m['name'] as String?) ?? '未命名';
        final addr = m['vicinity'] as String?;
        final geo = (m['geometry'] as Map<String, dynamic>?)?['location'] as Map<String, dynamic>?;
        final lat = (geo?['lat'] as num?)?.toDouble() ?? 0;
        final lng = (geo?['lng'] as num?)?.toDouble() ?? 0;
        final rating = (m['rating'] as num?)?.toDouble();
        final urt = (m['user_ratings_total'] as num?)?.toInt();
        final types = ((m['types'] as List?) ?? const [])
            .map((e) => (e as String?) ?? '')
            .where((s) => s.isNotEmpty)
            .toList(growable: false);
        final price = (m['price_level'] as num?)?.toInt();
        return PlaceItem(
          id: id,
          name: name,
          address: addr,
          location: LatLngPoint(lat, lng),
          rating: rating,
          userRatingsTotal: urt,
          types: types,
          priceLevel: price,
        );
      }).toList(growable: false);
    } catch (e, st) {
      dev.log('PlacesRemoteDataSource.searchNearby error: $e', name: 'places', stackTrace: st);
      return const [];
    }
  }

  Future<PlaceDetails?> fetchPlaceDetails(String placeId) async {
    if (!enabled) return null;
    final fields = [
      'place_id',
      'name',
      'formatted_address',
      'geometry/location',
      'rating',
      'user_ratings_total',
      'types',
      'price_level',
      'formatted_phone_number',
      'website',
      'opening_hours/weekday_text',
      'photos',
    ].join(',');
    final queries = <String, dynamic>{
      'key': apiKey,
      'place_id': placeId,
      'fields': fields,
      'language': 'zh-CN',
    };
    try {
      if (api != null) {
        final resp = await api!.details(queries);
        final dto = resp.data.result;
        if (dto == null) return null;
        return _toPlaceDetails(dto);
      }
      // 回退：Dio 直调
      final resp = await dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: queries,
      );
      if (resp.statusCode != 200) return null;
      final data = resp.data as Map<String, dynamic>;
      final result = (data['result'] as Map<String, dynamic>?);
      if (result == null) return null;
      final id = (result['place_id'] as String?) ?? placeId;
      final name = (result['name'] as String?) ?? '未命名';
      final addr = result['formatted_address'] as String?;
      final geo = (result['geometry'] as Map<String, dynamic>?)?['location'] as Map<String, dynamic>?;
      final lat = (geo?['lat'] as num?)?.toDouble();
      final lng = (geo?['lng'] as num?)?.toDouble();
      final rating = (result['rating'] as num?)?.toDouble();
      final urt = (result['user_ratings_total'] as num?)?.toInt();
      final types = ((result['types'] as List?) ?? const [])
          .map((e) => (e as String?) ?? '')
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
      final price = (result['price_level'] as num?)?.toInt();
      final phone = result['formatted_phone_number'] as String?;
      final website = result['website'] as String?;
      final weekday = ((result['opening_hours'] as Map<String, dynamic>?)?['weekday_text'] as List?)
              ?.map((e) => e.toString())
              .toList(growable: false) ??
          const [];

      final photos = ((result['photos'] as List?) ?? const []).cast<Map<String, dynamic>>();
      final photoUrls = <String>[];
      for (final p in photos) {
        final ref = p['photo_reference'] as String?;
        if (ref == null || ref.isEmpty) continue;
        final maxWidth = (p['width'] as num?)?.toInt() ?? 800;
        final u = Uri.https('maps.googleapis.com', '/maps/api/place/photo', {
          'maxwidth': maxWidth.toString(),
          'photo_reference': ref,
          'key': apiKey!,
        });
        photoUrls.add(u.toString());
        if (photoUrls.length >= 8) break;
      }

      return PlaceDetails(
        id: id,
        name: name,
        address: addr,
        location: (lat != null && lng != null) ? LatLngPoint(lat, lng) : null,
        rating: rating,
        userRatingsTotal: urt,
        types: types,
        priceLevel: price,
        phone: phone,
        website: website,
        openingWeekdayText: weekday,
        photoUrls: photoUrls,
      );
    } catch (e, st) {
      dev.log('PlacesRemoteDataSource.fetchPlaceDetails error: $e', name: 'places', stackTrace: st);
      return null;
    }
  }

  // --- DTO 映射 ---
  PlaceItem _toPlaceItem(PlaceItemDto dto) {
    final loc = dto.geometry?.location;
    return PlaceItem(
      id: dto.placeId,
      name: dto.name,
      address: dto.formattedAddress ?? dto.vicinity,
      location: LatLngPoint((loc?.lat ?? 0).toDouble(), (loc?.lng ?? 0).toDouble()),
      rating: dto.rating,
      userRatingsTotal: dto.userRatingsTotal,
      types: dto.types,
      priceLevel: dto.priceLevel,
    );
  }

  PlaceDetails _toPlaceDetails(PlaceDetailsDto dto) {
    final loc = dto.geometry?.location;
    // 照片 URL 拼装
    final urls = <String>[];
    for (final p in dto.photos) {
      final ref = p.photoReference;
      if (ref == null || ref.isEmpty) continue;
      final maxWidth = p.width ?? 800;
      final u = Uri.https('maps.googleapis.com', '/maps/api/place/photo', {
        'maxwidth': maxWidth.toString(),
        'photo_reference': ref,
        'key': apiKey!,
      });
      urls.add(u.toString());
      if (urls.length >= 8) break;
    }
    return PlaceDetails(
      id: dto.placeId,
      name: dto.name,
      address: dto.formattedAddress,
      location: (loc != null) ? LatLngPoint(loc.lat, loc.lng) : null,
      rating: dto.rating,
      userRatingsTotal: dto.userRatingsTotal,
      types: dto.types,
      priceLevel: dto.priceLevel,
      phone: dto.formattedPhoneNumber,
      website: dto.website,
      openingWeekdayText: dto.openingHours?.weekdayText ?? const [],
      photoUrls: urls,
    );
  }
}
