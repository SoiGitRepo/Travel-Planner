import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../models/latlng_point.dart';
import '../models/transport_mode.dart';
import 'route_service.dart';

class GoogleRouteService implements RouteService {
  GoogleRouteService();

  String? get _apiKey => dotenv.env['GOOGLE_DIRECTIONS_API_KEY'];

  @override
  Future<RouteResult> getRoute({
    required LatLngPoint origin,
    required LatLngPoint destination,
    required TransportMode mode,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      // No API key configured, return straight line path without estimate
      return RouteResult(path: [origin, destination]);
    }

    final modeStr = switch (mode) {
      TransportMode.driving => 'driving',
      TransportMode.walking => 'walking',
      TransportMode.transit => 'transit',
    };

    final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.lat},${origin.lng}&destination=${destination.lat},${destination.lng}&mode=$modeStr&key=$_apiKey');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      return RouteResult(path: [origin, destination]);
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    if ((data['routes'] as List).isEmpty) {
      return RouteResult(path: [origin, destination]);
    }
    final route = (data['routes'] as List).first as Map<String, dynamic>;
    final overview = route['overview_polyline'] as Map<String, dynamic>;
    final pointsStr = overview['points'] as String;
    final polyPoints = PolylinePoints().decodePolyline(pointsStr);
    final path = polyPoints
        .map((p) => LatLngPoint(p.latitude, p.longitude))
        .toList(growable: false);

    int? estMinutes;
    double? distanceMeters;
    try {
      final legs = route['legs'] as List;
      if (legs.isNotEmpty) {
        final leg = legs.first as Map<String, dynamic>;
        final dur = leg['duration'] as Map<String, dynamic>?;
        final dist = leg['distance'] as Map<String, dynamic>?;
        if (dur != null) {
          estMinutes = ((dur['value'] as num) / 60).round();
        }
        if (dist != null) {
          distanceMeters = (dist['value'] as num).toDouble();
        }
      }
    } catch (_) {}

    return RouteResult(
      path: path.isNotEmpty ? path : [origin, destination],
      estimatedDurationMinutes: estMinutes,
      distanceMeters: distanceMeters,
    );
  }
}
