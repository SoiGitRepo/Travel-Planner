import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/route_service.dart';
import 'services/google_route_service.dart';
import 'services/places_service.dart';
import '../features/plan/data/plan_repository.dart';
import '../features/map/data/places_repository_impl.dart';
import '../features/map/domain/places_repository.dart';

final routeServiceProvider = Provider<RouteService>((ref) {
  return GoogleRouteService();
});

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return PlanRepository();
});

final placesServiceProvider = Provider<PlacesService>((ref) {
  return const PlacesService();
});

// Places 仓库（基于现有 PlacesService 封装），供应用层/展示层注入使用
final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  final svc = ref.watch(placesServiceProvider);
  return PlacesRepositoryImpl(svc);
});
