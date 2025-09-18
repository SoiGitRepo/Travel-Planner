import 'package:hive/hive.dart';
import 'plan.dart';

class PlanGroup {
  final String id;
  final String name;
  final List<Plan> plans; // 多天计划集合

  const PlanGroup({
    required this.id,
    required this.name,
    required this.plans,
  });
}

class PlanGroupAdapter extends TypeAdapter<PlanGroup> {
  @override
  final int typeId = 6;

  @override
  PlanGroup read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final count = reader.readInt();
    final plans = List<Plan>.generate(count, (_) => reader.read() as Plan);
    return PlanGroup(id: id, name: name, plans: plans);
  }

  @override
  void write(BinaryWriter writer, PlanGroup obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeInt(obj.plans.length);
    for (final p in obj.plans) {
      writer.write(p);
    }
  }
}
