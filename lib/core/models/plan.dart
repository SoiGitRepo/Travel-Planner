import 'package:hive/hive.dart';
import 'node.dart';
import 'transport_segment.dart';

class Plan {
  final String id;
  final DateTime date; // 单天计划
  final List<Node> nodes;
  final List<TransportSegment> segments;

  const Plan({
    required this.id,
    required this.date,
    required this.nodes,
    required this.segments,
  });
}

class PlanAdapter extends TypeAdapter<Plan> {
  @override
  final int typeId = 5;

  @override
  Plan read(BinaryReader reader) {
    final id = reader.readString();
    final dateMs = reader.readInt();
    final nodeCount = reader.readInt();
    final nodes = List<Node>.generate(nodeCount, (_) => reader.read() as Node);
    final segCount = reader.readInt();
    final segments = List<TransportSegment>.generate(
        segCount, (_) => reader.read() as TransportSegment);
    return Plan(
      id: id,
      date: DateTime.fromMillisecondsSinceEpoch(dateMs),
      nodes: nodes,
      segments: segments,
    );
  }

  @override
  void write(BinaryWriter writer, Plan obj) {
    writer
      ..writeString(obj.id)
      ..writeInt(DateTime(obj.date.year, obj.date.month, obj.date.day)
          .millisecondsSinceEpoch)
      ..writeInt(obj.nodes.length);
    for (final n in obj.nodes) {
      writer.write(n);
    }
    writer.writeInt(obj.segments.length);
    for (final s in obj.segments) {
      writer.write(s);
    }
  }
}
