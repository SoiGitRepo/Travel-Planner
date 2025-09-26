import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/map/view/map_page.dart';
import '../features/plan/presentation/group_manager_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'map',
        builder: (context, state) => const MapPage(),
      ),
      GoRoute(
        path: '/groups',
        name: 'groups',
        builder: (context, state) => const GroupManagerPage(),
      ),
    ],
  );
});
