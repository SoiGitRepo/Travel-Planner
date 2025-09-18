import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/latlng_point.dart';
import '../../../core/models/node.dart';
import '../../../core/models/plan.dart';
import '../../../core/models/plan_group.dart';
import '../../../core/models/transport_mode.dart';
import '../../../core/models/transport_segment.dart';
import '../../../core/providers.dart';
import '../../plan/data/plan_repository.dart';

class PlanState {
  final PlanGroup group;
  final int currentPlanIndex;
  const PlanState({required this.group, required this.currentPlanIndex});

  Plan get currentPlan => group.plans[currentPlanIndex];

  PlanState copyWith({PlanGroup? group, int? currentPlanIndex}) =>
      PlanState(group: group ?? this.group, currentPlanIndex: currentPlanIndex ?? this.currentPlanIndex);
}

final planControllerProvider = AsyncNotifierProvider<PlanController, PlanState>(PlanController.new);

class PlanController extends AsyncNotifier<PlanState> {
  late final PlanRepository _repo;

  @override
  Future<PlanState> build() async {
    _repo = ref.read(planRepositoryProvider);
    final group = await _repo.loadOrCreateDefault();
    return PlanState(group: group, currentPlanIndex: 0);
  }

  Future<void> selectPlan(int index) async {
    final s = state.valueOrNull;
    if (s == null || index < 0 || index >= s.group.plans.length) return;
    state = AsyncData(s.copyWith(currentPlanIndex: index));
  }

  Future<void> addNodeAt(LatLngPoint point, {String? title, TransportMode mode = TransportMode.walking}) async {
    final s = state.valueOrNull;
    if (s == null) return;
    final plan = s.currentPlan;
    final nodes = List<Node>.from(plan.nodes);
    final newNode = Node(
      id: _id(),
      title: title ?? '节点 ${nodes.length + 1}',
      point: point,
    );
    nodes.add(newNode);

    final segments = List<TransportSegment>.from(plan.segments);
    if (nodes.length >= 2) {
      final last = nodes[nodes.length - 2];
      final route = await ref.read(routeServiceProvider).getRoute(
            origin: last.point,
            destination: point,
            mode: mode,
          );
      segments.add(TransportSegment(
        id: _id(),
        fromNodeId: last.id,
        toNodeId: newNode.id,
        mode: mode,
        userDurationMinutes: null,
        estimatedDurationMinutes: route.estimatedDurationMinutes,
        distanceMeters: route.distanceMeters,
        path: route.path,
      ));
    }

    final newPlan = Plan(id: plan.id, date: plan.date, nodes: nodes, segments: segments);
    final newPlans = List<Plan>.from(s.group.plans);
    newPlans[s.currentPlanIndex] = newPlan;
    final newGroup = PlanGroup(id: s.group.id, name: s.group.name, plans: newPlans);

    // 先保存基础结构
    await _repo.save(newGroup);
    // 自动排程（填充默认到达与停留）
    final scheduledGroup = await _recalcScheduleForGroup(newGroup, s.currentPlanIndex);
    state = AsyncData(PlanState(group: scheduledGroup, currentPlanIndex: s.currentPlanIndex));
  }

  Future<void> createPlanForDate(DateTime date) async {
    final s = state.valueOrNull;
    if (s == null) return;
    final normalized = DateTime(date.year, date.month, date.day);
    // 如果已存在同日计划则直接选中
    final existingIndex = s.group.plans.indexWhere((p) =>
        p.date.year == normalized.year && p.date.month == normalized.month && p.date.day == normalized.day);
    if (existingIndex >= 0) {
      state = AsyncData(s.copyWith(currentPlanIndex: existingIndex));
      return;
    }
    final newPlan = Plan(id: _id(), date: normalized, nodes: const [], segments: const []);
    final newPlans = List<Plan>.from(s.group.plans)..add(newPlan);
    final newGroup = PlanGroup(id: s.group.id, name: s.group.name, plans: newPlans);
    await _repo.save(newGroup);
    state = AsyncData(PlanState(group: newGroup, currentPlanIndex: newPlans.length - 1));
  }

  Future<void> setSegmentUserDuration({required String segmentId, int? minutes}) async {
    final s = state.valueOrNull;
    if (s == null) return;
    final plan = s.currentPlan;
    final segIndex = plan.segments.indexWhere((e) => e.id == segmentId);
    if (segIndex < 0) return;
    final updatedSeg = plan.segments[segIndex]
        .copyWith(userDurationMinutes: minutes, clearUserDuration: minutes == null);
    final newSegments = List<TransportSegment>.from(plan.segments);
    newSegments[segIndex] = updatedSeg;
    final newPlan = Plan(id: plan.id, date: plan.date, nodes: plan.nodes, segments: newSegments);
    final newPlans = List<Plan>.from(s.group.plans)..[s.currentPlanIndex] = newPlan;
    final newGroup = PlanGroup(id: s.group.id, name: s.group.name, plans: newPlans);
    await _repo.save(newGroup);
    // 添加节点后执行自动排程（默认 08:00 与默认停留 60 分钟，未设置到达时间的按上一个节点+停留+交通计算）
    final scheduledGroup = await _recalcScheduleForGroup(newGroup, s.currentPlanIndex);
    state = AsyncData(PlanState(group: scheduledGroup, currentPlanIndex: s.currentPlanIndex));
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> updateNodeSchedule({
    required String nodeId,
    DateTime? arrivalTime,
    int? stayMinutes,
    bool clearArrival = false,
    bool clearStay = false,
  }) async {
    final s = state.valueOrNull;
    if (s == null) return;
    final plan = s.currentPlan;
    final nodes = List<Node>.from(plan.nodes);
    final idx = nodes.indexWhere((n) => n.id == nodeId);
    if (idx < 0) return;
    final old = nodes[idx];
    final updated = Node(
      id: old.id,
      title: old.title,
      point: old.point,
      scheduledTime: clearArrival ? null : (arrivalTime ?? old.scheduledTime),
      stayDurationMinutes: clearStay ? null : (stayMinutes ?? old.stayDurationMinutes),
    );
    nodes[idx] = updated;
    final newPlan = Plan(id: plan.id, date: plan.date, nodes: nodes, segments: plan.segments);
    final newPlans = List<Plan>.from(s.group.plans)..[s.currentPlanIndex] = newPlan;
    final newGroup = PlanGroup(id: s.group.id, name: s.group.name, plans: newPlans);
    await _repo.save(newGroup);
    // 添加节点后自动排程（首节点默认 08:00；默认停留 60 分钟；其后根据上一个节点+停留+交通时间计算）
    final scheduled = await _recalcScheduleForGroup(newGroup, s.currentPlanIndex);
    state = AsyncData(PlanState(group: scheduled, currentPlanIndex: s.currentPlanIndex));
  }
  
  Future<void> deleteNode(String nodeId) async {
    final s = state.valueOrNull;
    if (s == null) return;
    final plan = s.currentPlan;
    final nodes = List<Node>.from(plan.nodes);
    final idx = nodes.indexWhere((n) => n.id == nodeId);
    if (idx < 0) return;
    final removed = nodes.removeAt(idx);

    final segments = List<TransportSegment>.from(plan.segments)
      ..removeWhere((seg) => seg.fromNodeId == removed.id || seg.toNodeId == removed.id);

    if (idx - 1 >= 0 && idx < nodes.length) {
      final prev = nodes[idx - 1];
      final next = nodes[idx];
      TransportMode mode = TransportMode.walking;
      for (final seg in plan.segments) {
        if (seg.toNodeId == removed.id && seg.fromNodeId == prev.id) { mode = seg.mode; break; }
        if (seg.fromNodeId == removed.id && seg.toNodeId == next.id) { mode = seg.mode; break; }
      }
      final route = await ref.read(routeServiceProvider).getRoute(
        origin: prev.point,
        destination: next.point,
        mode: mode,
      );
      segments.add(TransportSegment(
        id: _id(),
        fromNodeId: prev.id,
        toNodeId: next.id,
        mode: mode,
        estimatedDurationMinutes: route.estimatedDurationMinutes,
        distanceMeters: route.distanceMeters,
        path: route.path,
      ));
    }

    final newPlan = Plan(id: plan.id, date: plan.date, nodes: nodes, segments: segments);
    final newPlans = List<Plan>.from(s.group.plans)..[s.currentPlanIndex] = newPlan;
    final newGroup = PlanGroup(id: s.group.id, name: s.group.name, plans: newPlans);
    await _repo.save(newGroup);
    final scheduled = await _recalcScheduleForGroup(newGroup, s.currentPlanIndex);
    state = AsyncData(PlanState(group: scheduled, currentPlanIndex: s.currentPlanIndex));
  }

  Future<void> setSegmentMode({required String segmentId, required TransportMode mode}) async {
    final s = state.valueOrNull;
    if (s == null) return;
    final plan = s.currentPlan;
    final idx = plan.segments.indexWhere((e) => e.id == segmentId);
    if (idx < 0) return;
    final seg = plan.segments[idx];
    final route = await ref.read(routeServiceProvider).getRoute(
      origin: _nodeById(plan, seg.fromNodeId).point,
      destination: _nodeById(plan, seg.toNodeId).point,
      mode: mode,
    );
    final newSeg = seg.copyWith(
      mode: mode,
      estimatedDurationMinutes: route.estimatedDurationMinutes,
      distanceMeters: route.distanceMeters,
      path: route.path,
    );
    final newSegments = List<TransportSegment>.from(plan.segments);
    newSegments[idx] = newSeg;
    final newPlan = Plan(id: plan.id, date: plan.date, nodes: plan.nodes, segments: newSegments);
    final newPlans = List<Plan>.from(s.group.plans)..[s.currentPlanIndex] = newPlan;
    final newGroup = PlanGroup(id: s.group.id, name: s.group.name, plans: newPlans);
    await _repo.save(newGroup);
    final scheduled = await _recalcScheduleForGroup(newGroup, s.currentPlanIndex);
    state = AsyncData(PlanState(group: scheduled, currentPlanIndex: s.currentPlanIndex));
  }

  Node _nodeById(Plan plan, String id) => plan.nodes.firstWhere((n) => n.id == id);

  Future<PlanGroup> _recalcScheduleForGroup(PlanGroup group, int currentIndex) async {
    final plan = group.plans[currentIndex];
    final nodes = List<Node>.from(plan.nodes);
    if (nodes.isEmpty) return group;

    DateTime? lastArrival;
    for (var i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      // 保留首节点：若未设置则默认 08:00；后续节点的到达时间始终用推导结果覆盖，确保与上游变更保持一致
      // 停留：保留用户已设置的值，否则默认 60 分钟
      int stay = n.stayDurationMinutes ?? 60;

      DateTime arrival;
      if (i == 0) {
        arrival = n.scheduledTime ?? DateTime(plan.date.year, plan.date.month, plan.date.day, 8, 0);
      } else {
        final prev = nodes[i - 1];
        // 找到相邻段
        TransportSegment? seg;
        for (final s in plan.segments) {
          if (s.fromNodeId == prev.id && s.toNodeId == n.id) { seg = s; break; }
        }
        final prevStay = prev.stayDurationMinutes ?? 60;
        final travel = (seg?.userDurationMinutes ?? seg?.estimatedDurationMinutes) ?? 0;
        // 从上一节点的"最终到达时间"推进
        final base = lastArrival ?? prev.scheduledTime ?? DateTime(plan.date.year, plan.date.month, plan.date.day, 8, 0);
        arrival = base.add(Duration(minutes: prevStay + travel));
      }

      nodes[i] = Node(
        id: n.id,
        title: n.title,
        point: n.point,
        scheduledTime: i == 0 ? arrival : arrival, // i>0 一律覆盖
        stayDurationMinutes: stay,
      );
      lastArrival = nodes[i].scheduledTime;
    }

    final newPlan = Plan(id: plan.id, date: plan.date, nodes: nodes, segments: plan.segments);
    final newPlans = List<Plan>.from(group.plans)..[currentIndex] = newPlan;
    final newGroup = PlanGroup(id: group.id, name: group.name, plans: newPlans);
    await _repo.save(newGroup);
    return newGroup;
  }
}
