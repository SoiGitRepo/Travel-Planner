import 'package:hive/hive.dart';

import '../../../core/models/plan.dart';
import '../../../core/models/plan_group.dart';
import '../../../core/storage/hive_boxes.dart';

class PlanRepository {
  static const _defaultKey = 'default';

  Box<PlanGroup> get _box => HiveBoxes.planGroupsBox;

  Future<PlanGroup> loadOrCreateDefault() async {
    if (_box.containsKey(_defaultKey)) {
      return _box.get(_defaultKey)!;
    }
    final today = DateTime.now();
    final plan = Plan(id: _id(), date: DateTime(today.year, today.month, today.day), nodes: const [], segments: const []);
    final group = PlanGroup(id: _defaultKey, name: '我的行程', plans: [plan]);
    await _box.put(_defaultKey, group);
    return group;
  }

  Future<void> save(PlanGroup group) async {
    await _box.put(_defaultKey, group);
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();
}
