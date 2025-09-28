import 'package:hive/hive.dart';

import '../../../core/models/plan.dart';
import '../../../core/models/plan_group.dart';
import '../../../core/storage/hive_boxes.dart';

class PlanRepository {
  static const _defaultKey = 'default';
  static const _currentGroupIdKey = 'current_group_id';

  Box<PlanGroup> get _box => HiveBoxes.planGroupsBox;
  Box get _settings => HiveBoxes.settingsBox;

  // 供测试覆写的缺省加载方法：默认委托到 loadOrCreateCurrent
  Future<PlanGroup> loadOrCreateDefault() async {
    return loadOrCreateCurrent();
  }

  Future<PlanGroup> loadOrCreateCurrent() async {
    // 优先使用 settings 中保存的当前分组
    final currentId = _settings.get(_currentGroupIdKey) as String?;
    if (currentId != null && _box.containsKey(currentId)) {
      return _box.get(currentId)!;
    }
    // 若 settings 未设置，尝试使用已有分组中的第一个
    if (_box.isNotEmpty) {
      final firstKey = _box.keys.first as String;
      _settings.put(_currentGroupIdKey, firstKey);
      return _box.get(firstKey)!;
    }
    // 若无任何分组，创建默认分组
    final today = DateTime.now();
    final plan = Plan(
      id: _id(),
      date: DateTime(today.year, today.month, today.day),
      nodes: const [],
      segments: const [],
    );
    final group = PlanGroup(id: _defaultKey, name: '我的行程', plans: [plan]);
    await _box.put(group.id, group);
    await _settings.put(_currentGroupIdKey, group.id);
    return group;
  }

  Future<void> save(PlanGroup group) async {
    await _box.put(group.id, group);
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  // --- 分组管理 ---
  List<PlanGroup> getAllGroups() => _box.values.toList(growable: false);

  String? getCurrentGroupId() => _settings.get(_currentGroupIdKey) as String?;

  Future<void> setCurrentGroupId(String id) async {
    if (_box.containsKey(id)) {
      await _settings.put(_currentGroupIdKey, id);
    }
  }

  Future<PlanGroup> createGroup(String name) async {
    final today = DateTime.now();
    final plan = Plan(
      id: _id(),
      date: DateTime(today.year, today.month, today.day),
      nodes: const [],
      segments: const [],
    );
    final id = _id();
    final group = PlanGroup(id: id, name: name, plans: [plan]);
    await _box.put(id, group);
    // 不自动切换，调用方可根据需要切换
    return group;
  }

  Future<PlanGroup?> renameGroup(String id, String newName) async {
    final g = _box.get(id);
    if (g == null) return null;
    final ng = PlanGroup(id: g.id, name: newName, plans: g.plans);
    await _box.put(id, ng);
    return ng;
  }

  Future<void> deleteGroup(String id) async {
    await _box.delete(id);
    final current = getCurrentGroupId();
    if (current == id) {
      // 切换到任意剩余分组或创建默认
      if (_box.isNotEmpty) {
        final firstKey = _box.keys.first as String;
        await _settings.put(_currentGroupIdKey, firstKey);
      } else {
        await _settings.delete(_currentGroupIdKey);
        await loadOrCreateCurrent();
      }
    }
  }
}
