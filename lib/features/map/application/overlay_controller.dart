
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/providers.dart';
import '../../../core/utils/haversine.dart';
import '../../../core/services/places_service.dart' as places;
import '../view/providers.dart';
import '../../../core/models/latlng_point.dart' as model;

class OverlayController {
  OverlayController(this.ref);
  final Ref ref;

  Future<void> refreshFromCurrentView() async {
    final c = ref.read(mapControllerProvider);
    if (c == null) return;
    final bounds = ref.read(visibleRegionProvider);
    final pos = ref.read(cameraPositionProvider);
    if (bounds == null) return;

    final center = LatLng(
      (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
      (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
    );
    final r1 = haversine(center.latitude, center.longitude,
        bounds.northeast.latitude, bounds.northeast.longitude);
    final r2 = haversine(center.latitude, center.longitude,
        bounds.southwest.latitude, bounds.southwest.longitude);
    final radius = (0.5 * (r1 + r2)).clamp(100.0, 2500.0).toInt();

    // 按缩放控制预期数量上限
    final z = pos?.zoom ?? 14.0;
    int maxCount;
    if (z < 11) {
      maxCount = 20;
    } else if (z < 13) {
      maxCount = 30;
    } else if (z < 15) {
      maxCount = 45;
    } else if (z < 17) {
      maxCount = 60;
    } else {
      maxCount = 80;
    }

    // 节流：小幅移动或缩放微调且在短时间内，不触发请求（直接复用已有 overlayPlaces）
    final last = ref.read(overlayRefreshStateProvider);
    final now = DateTime.now();
    if (last != null) {
      final moved = haversine(center.latitude, center.longitude,
          last.center.latitude, last.center.longitude);
      final zoomDelta = (z - last.zoom).abs();
      final sinceMs = now.difference(last.at).inMilliseconds;
      if (sinceMs < 1200 && moved < (radius * 0.15) && zoomDelta < 0.25) {
        return;
      }
    }

    // 缓存优先：按量化中心/缩放/半径 生成 key
    String keyFor(double lat, double lng, double zoom, int r) {
      final qLat = lat.toStringAsFixed(3);
      final qLng = lng.toStringAsFixed(3);
      final zBucket = zoom.floor();
      final rBucket = ((r / 100).round() * 100);
      return 'z:$zBucket;lat:$qLat;lng:$qLng;r:$rBucket';
    }

    final cache = ref.read(overlayCacheProvider);
    final key = keyFor(center.latitude, center.longitude, z, radius);
    final hit = cache[key];
    const ttl = Duration(seconds: 30);
    if (hit != null && now.difference(hit.at) < ttl) {
      ref.read(overlayPlacesProvider.notifier).state = hit.items;
      ref.read(overlayRefreshStateProvider.notifier).state =
          OverlayRefreshState(center: center, zoom: z, at: now);
      return;
    }

    final repo = ref.read(placesRepositoryProvider);
    final either = await repo
        .searchNearby(
          model.LatLngPoint(center.latitude, center.longitude),
          radiusMeters: radius,
        )
        .run();
    final items = either.getOrElse((_) => <places.PlaceItem>[]).toList(growable: true);

    // 综合排序（与原逻辑一致）
    double typeWeight(List<String> types) {
      const weights = {
        'tourist_attraction': 1.0,
        'point_of_interest': 0.6,
        'museum': 0.9,
        'park': 0.8,
        'art_gallery': 0.8,
        'restaurant': 0.6,
        'cafe': 0.5,
        'shopping_mall': 0.5,
      };
      double w = 0.0;
      for (final t in types) {
        w = w < (weights[t] ?? 0.0) ? (weights[t] ?? 0.0) : w;
      }
      return w;
    }

    double scoreFor(dynamic a) {
      final d = haversine(center.latitude, center.longitude, a.location.lat, a.location.lng);
      final rating = (a.rating ?? 0.0).clamp(0.0, 5.0);
      final urt = (a.userRatingsTotal ?? 0);
      final typeW = typeWeight(a.types);
      final pop = rating * 2.0 + (urt > 0 ? (1.0 * (urt.toDouble()).clamp(0, 5000) / 5000.0) : 0.0);
      final distPenalty = (d / (radius.toDouble() + 1)).clamp(0.0, 1.0);
      return pop + typeW - distPenalty;
    }

    items.sort((a, b) => scoreFor(b).compareTo(scoreFor(a)));
    final trimmed = items.take(maxCount * 2).toList(growable: false);
    ref.read(overlayPlacesProvider.notifier).state = trimmed;

    // 写入缓存与刷新状态
    final newCache = {...cache, key: OverlayCacheEntry(trimmed, now)};
    ref.read(overlayCacheProvider.notifier).state = newCache;
    ref.read(overlayRefreshStateProvider.notifier).state =
        OverlayRefreshState(center: center, zoom: z, at: now);
  }
}

final overlayControllerProvider = Provider<OverlayController>((ref) => OverlayController(ref));
