import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
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

class PlacesService {
  const PlacesService();

  String? get _apiKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? dotenv.env['GOOGLE_DIRECTIONS_API_KEY'];

  Future<List<PlaceItem>> searchText(String query, {LatLngPoint? near, int? radiusMeters}) async {
    // 无 Key 降级：返回空结果
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
          : '30000'; // 默认 30km
    }
    final uri = Uri.https('maps.googleapis.com', '/maps/api/place/textsearch/json', params);
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return const [];
    final data = json.decode(resp.body) as Map<String, dynamic>;
    final results = (data['results'] as List?) ?? const [];
    return results.map((e) {
      final m = e as Map<String, dynamic>;
      final id = (m['place_id'] as String?) ?? '';
      final name = (m['name'] as String?) ?? '未命名';
      final addr = m['formatted_address'] as String?;
      final geo = (m['geometry'] as Map<String, dynamic>?)?['location'] as Map<String, dynamic>?;
      final lat = (geo?['lat'] as num?)?.toDouble() ?? 0;
      final lng = (geo?['lng'] as num?)?.toDouble() ?? 0;
      final rating = (m['rating'] as num?)?.toDouble();
      final urt = (m['user_ratings_total'] as num?)?.toInt();
      final types = ((m['types'] as List?) ?? const []).map((e) => (e as String?) ?? '').where((s) => s.isNotEmpty).toList(growable: false);
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
  }

  /// 按位置附近检索 Place（Nearby Search）
  Future<List<PlaceItem>> searchNearby(LatLngPoint center, {int radiusMeters = 300, String? keyword}) async {
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
    final uri = Uri.https('maps.googleapis.com', '/maps/api/place/nearbysearch/json', params);
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return const [];
    final data = json.decode(resp.body) as Map<String, dynamic>;
    final results = (data['results'] as List?) ?? const [];
    return results.map((e) {
      final m = e as Map<String, dynamic>;
      final id = (m['place_id'] as String?) ?? '';
      final name = (m['name'] as String?) ?? '未命名';
      final addr = m['vicinity'] as String?;
      final geo = (m['geometry'] as Map<String, dynamic>?)?['location'] as Map<String, dynamic>?;
      final lat = (geo?['lat'] as num?)?.toDouble() ?? 0;
      final lng = (geo?['lng'] as num?)?.toDouble() ?? 0;
      final rating = (m['rating'] as num?)?.toDouble();
      final urt = (m['user_ratings_total'] as num?)?.toInt();
      final types = ((m['types'] as List?) ?? const []).map((e) => (e as String?) ?? '').where((s) => s.isNotEmpty).toList(growable: false);
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
  }
}
