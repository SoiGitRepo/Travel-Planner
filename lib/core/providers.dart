import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'services/route_service.dart';
import 'services/google_route_service.dart';
import 'services/places_service.dart';
import '../features/plan/data/plan_repository.dart';
import '../features/map/data/places_repository_impl.dart';
import '../features/map/domain/places_repository.dart';
import 'network/dio_client.dart';
import '../features/map/data/places_remote_data_source.dart';
import '../features/map/domain/places_repository_fx.dart';
import '../features/map/data/places_repository_fx_impl.dart';

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
final dioProvider = Provider<Dio>((ref) => createDio());

final placesRemoteDataSourceProvider = Provider<PlacesRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  // 使用 Retrofit 客户端；数据源内部仍保留 Dio 直调回退
  return PlacesRemoteDataSource.withRetrofit(dio);
});

final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  final svc = ref.watch(placesServiceProvider);
  final remote = ref.watch(placesRemoteDataSourceProvider);
  return PlacesRepositoryImpl(svc, remote: remote);
});

/// fpdart 风格（TaskEither）仓库 Provider（包装现有仓库实现）
final placesRepositoryFxProvider = Provider<PlacesRepositoryFx>((ref) {
  final repo = ref.watch(placesRepositoryProvider);
  return PlacesRepositoryFxImpl(repo);
});

