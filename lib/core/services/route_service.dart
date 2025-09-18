import '../models/latlng_point.dart';
import '../models/transport_mode.dart';

class RouteResult {
  final List<LatLngPoint> path;
  final int? estimatedDurationMinutes;
  final double? distanceMeters;
  const RouteResult({
    required this.path,
    this.estimatedDurationMinutes,
    this.distanceMeters,
  });
}

abstract class RouteService {
  Future<RouteResult> getRoute({
    required LatLngPoint origin,
    required LatLngPoint destination,
    required TransportMode mode,
  });
}
