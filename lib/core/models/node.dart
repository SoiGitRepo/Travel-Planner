import 'package:hive/hive.dart';
import 'latlng_point.dart';

class Node {
  final String id;
  final String title;
  final LatLngPoint point;
  final DateTime? scheduledTime;
  final int? stayDurationMinutes; // 在该节点的停留时长

  const Node({
    required this.id,
    required this.title,
    required this.point,
    this.scheduledTime,
    this.stayDurationMinutes,
  });
}

class NodeAdapter extends TypeAdapter<Node> {
  @override
  final int typeId = 3;

  @override
  Node read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final point = reader.read() as LatLngPoint;
    final hasTime = reader.readBool();
    final time =
        hasTime ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
    final hasStay = reader.readBool();
    final stay = hasStay ? reader.readInt() : null;
    return Node(
        id: id,
        title: title,
        point: point,
        scheduledTime: time,
        stayDurationMinutes: stay);
  }

  @override
  void write(BinaryWriter writer, Node obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.title)
      ..write(obj.point)
      ..writeBool(obj.scheduledTime != null);
    if (obj.scheduledTime != null) {
      writer.writeInt(obj.scheduledTime!.millisecondsSinceEpoch);
    }
    writer.writeBool(obj.stayDurationMinutes != null);
    if (obj.stayDurationMinutes != null) {
      writer.writeInt(obj.stayDurationMinutes!);
    }
  }
}
