import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:travel_planner/core/models/latlng_point.dart';
import 'package:travel_planner/core/models/plan.dart';
import 'package:travel_planner/core/models/plan_group.dart';
import 'package:travel_planner/core/models/transport_mode.dart';
import 'package:travel_planner/core/providers.dart';
import 'package:travel_planner/core/services/route_service.dart';
import 'package:travel_planner/features/plan/data/plan_repository.dart';
import 'package:travel_planner/features/plan/presentation/plan_controller.dart';

class _FakeRepo extends PlanRepository {
  PlanGroup? _group;
  _FakeRepo();

  @override
  Future<PlanGroup> loadOrCreateDefault() async {
    if (_group != null) return _group!;
    final today = DateTime(2025, 1, 1);
    final plan = Plan(
        id: 'p1',
        date: DateTime(today.year, today.month, today.day),
        nodes: const [],
        segments: const []);
    _group = PlanGroup(id: 'g1', name: '测试', plans: [plan]);
    return _group!;
  }

  @override
  Future<void> save(PlanGroup group) async {
    _group = group;
  }
}

class _FakeRouteService implements RouteService {
  // 固定返回 15 分钟、1km 的直线
  int minutes;
  _FakeRouteService({this.minutes = 15});

  @override
  Future<RouteResult> getRoute(
      {required LatLngPoint origin,
      required LatLngPoint destination,
      required TransportMode mode}) async {
    return RouteResult(
      path: [origin, destination],
      estimatedDurationMinutes: minutes,
      distanceMeters: 1000,
    );
  }
}

void main() {
  test('前序节点/段变更会联动更新后续节点到达时间', () async {
    final repo = _FakeRepo();
    final route = _FakeRouteService(minutes: 15);

    final container = ProviderContainer(overrides: [
      planRepositoryProvider.overrideWithValue(repo),
      routeServiceProvider.overrideWithValue(route),
    ]);
    addTearDown(container.dispose);

    final controller = container.read(planControllerProvider.notifier);
    final state1 = await container.read(planControllerProvider.future);
    expect(state1.currentPlan.nodes, isEmpty);

    // 添加三个节点：A、B、C
    await controller.addNodeAt(const LatLngPoint(1, 1),
        title: 'A', mode: TransportMode.walking);
    await controller.addNodeAt(const LatLngPoint(1.1, 1.1),
        title: 'B', mode: TransportMode.walking);
    await controller.addNodeAt(const LatLngPoint(1.2, 1.2),
        title: 'C', mode: TransportMode.walking);
    final afterAdd = container.read(planControllerProvider).value!;
    final plan = afterAdd.currentPlan;
    expect(plan.nodes.length, 3);
    expect(plan.segments.length, 2);

    final a = plan.nodes[0];
    final b = plan.nodes[1];
    final c = plan.nodes[2];

    // 首节点默认 08:00
    final eight =
        DateTime(plan.date.year, plan.date.month, plan.date.day, 8, 0);
    expect(a.scheduledTime, isNotNull);
    expect(a.scheduledTime!.hour, 8);
    expect(a.stayDurationMinutes ?? 60, 60);

    // B = 08:00 + 60 + 15 = 09:15
    expect(b.scheduledTime, equals(eight.add(const Duration(minutes: 75))));
    // C = B + 60 + 15 = 10:30
    expect(c.scheduledTime, equals(eight.add(const Duration(minutes: 150))));

    // 修改第一段“我的时长”为 30 分钟，后续到达应更新：
    final segAB = plan.segments.first;
    await controller.setSegmentUserDuration(segmentId: segAB.id, minutes: 30);

    final afterUserDur =
        container.read(planControllerProvider).value!.currentPlan;
    final b2 = afterUserDur.nodes[1];
    final c2 = afterUserDur.nodes[2];
    expect(b2.scheduledTime,
        equals(eight.add(const Duration(minutes: 90)))); // 08:00 + 60 + 30
    expect(c2.scheduledTime,
        equals(eight.add(const Duration(minutes: 165)))); // 09:30 + 60 + 15

    // 修改 A 的到达=10:00、停留=30，则：
    // B = 10:00 + 30 + 30 = 11:00
    // C = 11:00 + 60 + 15 = 12:15
    await controller.updateNodeSchedule(
      nodeId: afterUserDur.nodes[0].id,
      arrivalTime: DateTime(afterUserDur.date.year, afterUserDur.date.month,
          afterUserDur.date.day, 10, 0),
      stayMinutes: 30,
    );
    final afterNodeChange =
        container.read(planControllerProvider).value!.currentPlan;
    expect(
        afterNodeChange.nodes[1].scheduledTime,
        equals(DateTime(afterUserDur.date.year, afterUserDur.date.month,
            afterUserDur.date.day, 11, 0)));
    expect(
        afterNodeChange.nodes[2].scheduledTime,
        equals(DateTime(afterUserDur.date.year, afterUserDur.date.month,
            afterUserDur.date.day, 12, 15)));
  });
}
