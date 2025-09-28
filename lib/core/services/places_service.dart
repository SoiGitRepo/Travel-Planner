import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show HandshakeException;
import 'package:http/http.dart' as http;

import '../models/latlng_point.dart';

class PlaceItem {
  final String id;
  final String name;
  final String? address;
  final LatLngPoint location;
  final double? rating; // 0~5
  final int? userRatingsTotal;
  final List<String> types;
  final int? priceLevel; // 0~4
  const PlaceItem({
    required this.id,
    required this.name,
    required this.location,
    this.address,
    this.rating,
    this.userRatingsTotal,
    this.types = const [],
    this.priceLevel,
  });
}

class PlaceDetails {
  final String id;
  final String name;
  final String? address;
  final LatLngPoint? location;
  final double? rating;
  final int? userRatingsTotal;
  final List<String> types;
  final int? priceLevel;
  final String? phone;
  final String? website;
  final List<String> openingWeekdayText; // 营业时间（逐日）
  final List<String> photoUrls; // 直接可用的照片 URL（使用 Places Photos API）

  const PlaceDetails({
    required this.id,
    required this.name,
    this.address,
    this.location,
    this.rating,
    this.userRatingsTotal,
    this.types = const [],
    this.priceLevel,
    this.phone,
    this.website,
    this.openingWeekdayText = const [],
    this.photoUrls = const [],
  });
}

class PlacesService {
  const PlacesService();

  String? get _apiKey =>
      dotenv.env['GOOGLE_PLACES_API_KEY'] ??
      dotenv.env['GOOGLE_DIRECTIONS_API_KEY'];

  Future<List<PlaceItem>> searchText(String query,
      {LatLngPoint? near, int? radiusMeters}) async {
    if (_apiKey == null || _apiKey!.isEmpty) return const [];

    final params = <String, String>{
      'query': query,
      'key': _apiKey!,
      'language': 'zh-CN',
    };
    if (near != null) {
      params['location'] = '${near.lat},${near.lng}';
      params['radius'] = (radiusMeters != null && radiusMeters > 0)
          ? radiusMeters.toString()
          : '30000';
    }

    final uri = Uri.https(
        'maps.googleapis.com', '/maps/api/place/textsearch/json', params);
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return const [];
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final results = (data['results'] as List?) ?? const [];
      return results.map((e) {
        final m = e as Map<String, dynamic>;
        final id = (m['place_id'] as String?) ?? '';
        final name = (m['name'] as String?) ?? '未命名';
        final addr = m['formatted_address'] as String?;
        final geo = (m['geometry'] as Map<String, dynamic>?)?['location']
            as Map<String, dynamic>?;
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
    } on HandshakeException {
      return const [];
    } on Exception {
      return const [];
    }
  }

  Future<List<PlaceItem>> searchNearby(LatLngPoint center,
      {int radiusMeters = 300, String? keyword}) async {
    if (_apiKey == null || _apiKey!.isEmpty) return const [];
    final params = <String, String>{
      'key': _apiKey!,
      'location': '${center.lat},${center.lng}',
      'radius': radiusMeters.toString(),
      'language': 'zh-CN',
    };
    if (keyword != null && keyword.trim().isNotEmpty) {
      params['keyword'] = keyword.trim();
    }
    final uri = Uri.https(
        'maps.googleapis.com', '/maps/api/place/nearbysearch/json', params);
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return const [];
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final results = (data['results'] as List?) ?? const [];
      return results.map((e) {
        final m = e as Map<String, dynamic>;
        final id = (m['place_id'] as String?) ?? '';
        final name = (m['name'] as String?) ?? '未命名';
        final addr = m['vicinity'] as String?;
        final geo = (m['geometry'] as Map<String, dynamic>?)?['location']
            as Map<String, dynamic>?;
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
    } on HandshakeException {
      return const [];
    } on Exception {
      return const [];
    }
  }

  Future<PlaceDetails?> fetchPlaceDetails(String placeId) async {
    if (_apiKey == null || _apiKey!.isEmpty) return null;
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
    final params = <String, String>{
      'key': _apiKey!,
      'place_id': placeId,
      'fields': fields,
      'language': 'zh-CN',
    };
    final uri = Uri.https(
        'maps.googleapis.com', '/maps/api/place/details/json', params);
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return null;
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final result = (data['result'] as Map<String, dynamic>?);
      if (result == null) return null;
      final id = (result['place_id'] as String?) ?? placeId;
      final name = (result['name'] as String?) ?? '未命名';
      final addr = result['formatted_address'] as String?;
      final geo = (result['geometry'] as Map<String, dynamic>?)?['location']
          as Map<String, dynamic>?;
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
      final weekday = ((result['opening_hours']
                  as Map<String, dynamic>?)?['weekday_text'] as List?)
              ?.map((e) => e.toString())
              .toList(growable: false) ??
          const [];
      final photos = ((result['photos'] as List?) ?? const [])
          .cast<Map<String, dynamic>>();

      final photoUrls = <String>[];
      for (final p in photos) {
        final ref = p['photo_reference'] as String?;
        if (ref == null || ref.isEmpty) continue;
        final maxWidth = (p['width'] as num?)?.toInt() ?? 800;
        final photoParams = {
          'maxwidth': maxWidth.toString(),
          'photo_reference': ref,
          'key': _apiKey!,
        };
        final u = Uri.https(
            'maps.googleapis.com', '/maps/api/place/photo', photoParams);
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
    } on HandshakeException {
      return null;
    } on Exception {
      return null;
    }
  }
}
