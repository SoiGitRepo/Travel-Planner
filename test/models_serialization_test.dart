import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:travel_planner/core/models/latlng_point.dart';
import 'package:travel_planner/core/models/node.dart';
import 'package:travel_planner/core/models/plan.dart';
import 'package:travel_planner/core/models/plan_group.dart';
import 'package:travel_planner/core/models/transport_mode.dart';
import 'package:travel_planner/core/models/transport_segment.dart';

void main() {
  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(TransportModeAdapter().typeId)) {
      Hive.registerAdapter(TransportModeAdapter());
    }
    if (!Hive.isAdapterRegistered(LatLngPointAdapter().typeId)) {
      Hive.registerAdapter(LatLngPointAdapter());
    }
    if (!Hive.isAdapterRegistered(NodeAdapter().typeId)) {
      Hive.registerAdapter(NodeAdapter());
    }
    if (!Hive.isAdapterRegistered(TransportSegmentAdapter().typeId)) {
      Hive.registerAdapter(TransportSegmentAdapter());
    }
    if (!Hive.isAdapterRegistered(PlanAdapter().typeId)) {
      Hive.registerAdapter(PlanAdapter());
    }
    if (!Hive.isAdapterRegistered(PlanGroupAdapter().typeId)) {
      Hive.registerAdapter(PlanGroupAdapter());
    }
  });

  test('PlanGroup serialize/deserialize', () async {
    final box = await Hive.openBox<PlanGroup>('pg');
    const n1 = Node(id: 'n1', title: 'A', point: LatLngPoint(1, 2));
    const n2 = Node(id: 'n2', title: 'B', point: LatLngPoint(3, 4));
    const seg = TransportSegment(
      id: 's1',
      fromNodeId: 'n1',
      toNodeId: 'n2',
      mode: TransportMode.walking,
      userDurationMinutes: 10,
      estimatedDurationMinutes: 12,
      distanceMeters: 123.4,
      path: [LatLngPoint(1, 2), LatLngPoint(2, 3), LatLngPoint(3, 4)],
    );
    final plan = Plan(
        id: 'p1', date: DateTime(2025, 1, 1), nodes: [n1, n2], segments: [seg]);
    final group = PlanGroup(id: 'g1', name: '我的行程', plans: [plan]);
    await box.put('k', group);

    final loaded = box.get('k');
    expect(loaded, isNotNull);
    expect(loaded!.plans.first.nodes.length, 2);
    expect(loaded.plans.first.segments.first.mode, TransportMode.walking);
  });
}
