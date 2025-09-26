import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/route_service.dart';
import 'services/google_route_service.dart';
import 'services/places_service.dart';
import '../features/plan/data/plan_repository.dart';

final routeServiceProvider = Provider<RouteService>((ref) {
  return GoogleRouteService();
});

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return PlanRepository();
});

final placesServiceProvider = Provider<PlacesService>((ref) {
  return const PlacesService();
});
