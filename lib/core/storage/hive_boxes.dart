import 'package:hive_flutter/hive_flutter.dart';
import '../models/transport_mode.dart';
import '../models/latlng_point.dart';
import '../models/node.dart';
import '../models/transport_segment.dart';
import '../models/plan.dart';
import '../models/plan_group.dart';

class HiveBoxes {
  static const planGroups = 'plan_groups';

  static Box<PlanGroup> get planGroupsBox => Hive.box<PlanGroup>(planGroups);

  static Future<void> init() async {
    await Hive.initFlutter();

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

    try {
      await Hive.openBox<PlanGroup>(planGroups);
    } catch (e) {
      // 如果因为模型字段调整导致旧数据不兼容，清空本地 box 重新创建
      if (await Hive.boxExists(planGroups)) {
        await Hive.deleteBoxFromDisk(planGroups);
      }
      await Hive.openBox<PlanGroup>(planGroups);
    }
  }
}
