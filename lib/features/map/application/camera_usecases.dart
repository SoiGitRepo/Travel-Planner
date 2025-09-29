import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/models/latlng_point.dart' as model;
import '../../plan/presentation/plan_controller.dart';
import '../view/providers.dart';

class CameraUsecase {
  CameraUsecase(this.ref);
  final Ref ref;

  Future<void> focusPlacePanelAware(model.LatLngPoint p, {double zoom = 16, bool animate = true}) async {
    final c = ref.read(mapControllerProvider);
    if (c == null) return;
    final fraction = ref.read(sheetFractionProvider).clamp(0.0, 0.95);
    final latSpan = 360 / pow(2, zoom);
    final shiftLat = latSpan * (fraction / 2.0);
    final center = LatLng(p.lat - shiftLat, p.lng);
    final update = CameraUpdate.newCameraPosition(CameraPosition(target: center, zoom: zoom));
    if (animate) {
      await c.animateCamera(update);
    } else {
      await c.moveCamera(update);
    }
  }

  Future<void> fitToNodes({bool animate = true}) async {
    final controller = ref.read(mapControllerProvider);
    final planAsync = ref.read(planControllerProvider);
    if (controller == null || !planAsync.hasValue) return;
    final plan = planAsync.value!.currentPlan;
    final nodes = plan.nodes;
    final segs = plan.segments;

    final pts = <LatLng>[];
    for (final n in nodes) {
      pts.add(LatLng(n.point.lat, n.point.lng));
    }
    for (final s in segs) {
      final path = s.path ?? const [];
      for (final p in path) {
        pts.add(LatLng(p.lat, p.lng));
      }
    }

    if (pts.isEmpty) {
      const initial = CameraPosition(target: LatLng(37.7749, -122.4194), zoom: 12);
      final update = CameraUpdate.newCameraPosition(initial);
      if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
      return;
    }
    if (pts.length == 1) {
      final update = CameraUpdate.newCameraPosition(CameraPosition(target: pts.first, zoom: 14));
      if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
      return;
    }

    var minLat = pts.first.latitude;
    var maxLat = pts.first.latitude;
    var minLng = pts.first.longitude;
    var maxLng = pts.first.longitude;
    for (final p in pts) {
      minLat = p.latitude < minLat ? p.latitude : minLat;
      maxLat = p.latitude > maxLat ? p.latitude : maxLat;
      minLng = p.longitude < minLng ? p.longitude : minLng;
      maxLng = p.longitude > maxLng ? p.longitude : maxLng;
    }

    final fraction = ref.read(sheetFractionProvider).clamp(0.0, 0.95);
    final latSpan = (maxLat - minLat).abs();
    final safeSpan = latSpan < 1e-5 ? 1e-3 : latSpan;
    final visibleRatio = (0.85 - fraction).clamp(0.2, 0.9);
    final expandFactor = 1.0 / visibleRatio;
    final targetSpan = safeSpan * expandFactor;
    final grow = targetSpan - safeSpan;
    minLat -= grow * 0.15;
    maxLat += grow * 0.85;
    final shiftLat = targetSpan * (fraction * 0.9);
    minLat -= shiftLat;
    maxLat -= shiftLat;

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    try {
      final update = CameraUpdate.newLatLngBounds(bounds, 64);
      if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
    } catch (_) {
      final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
      final update = CameraUpdate.newLatLng(center);
      if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
    }
  }
}

final cameraUsecaseProvider = Provider<CameraUsecase>((ref) => CameraUsecase(ref));
