import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/map/view/map_page.dart';
import '../features/plan/presentation/group_manager_page.dart';
import '../features/search/search_page.dart';
import 'routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: Routes.map,
        name: RouteNames.map,
        builder: (context, state) => const MapPage(),
      ),
      GoRoute(
        path: Routes.groups,
        name: RouteNames.groups,
        builder: (context, state) => const GroupManagerPage(),
      ),
      GoRoute(
        path: Routes.search,
        name: RouteNames.search,
        builder: (context, state) => const SearchPage(),
      ),
    ],
  );
});
