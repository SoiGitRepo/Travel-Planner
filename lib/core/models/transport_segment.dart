import 'package:hive/hive.dart';
import 'transport_mode.dart';
import 'latlng_point.dart';

class TransportSegment {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final TransportMode mode;
  final int? userDurationMinutes; // 用户自定义时长，优先
  final int? estimatedDurationMinutes; // 地图预估时长
  final double? distanceMeters;
  final List<LatLngPoint>? path;

  const TransportSegment({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.mode,
    this.userDurationMinutes,
    this.estimatedDurationMinutes,
    this.distanceMeters,
    this.path,
  });

  TransportSegment copyWith({
    String? id,
    String? fromNodeId,
    String? toNodeId,
    TransportMode? mode,
    int? userDurationMinutes,
    bool clearUserDuration = false,
    int? estimatedDurationMinutes,
    double? distanceMeters,
    List<LatLngPoint>? path,
  }) {
    return TransportSegment(
      id: id ?? this.id,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      mode: mode ?? this.mode,
      userDurationMinutes: clearUserDuration
          ? null
          : (userDurationMinutes ?? this.userDurationMinutes),
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      path: path ?? this.path,
    );
  }
}

class TransportSegmentAdapter extends TypeAdapter<TransportSegment> {
  @override
  final int typeId = 4;

  @override
  TransportSegment read(BinaryReader reader) {
    final id = reader.readString();
    final fromNodeId = reader.readString();
    final toNodeId = reader.readString();
    // 重要：与 write 中的 writer.write(obj.mode) 对应，
    // 嵌套类型统一使用 reader.read() 以消费 typeId。
    final mode = reader.read() as TransportMode;
    final hasUser = reader.readBool();
    final userDur = hasUser ? reader.readInt() : null;
    final hasEst = reader.readBool();
    final estDur = hasEst ? reader.readInt() : null;
    final hasDist = reader.readBool();
    final dist = hasDist ? reader.readDouble() : null;
    final hasPath = reader.readBool();
    List<LatLngPoint>? path;
    if (hasPath) {
      final len = reader.readInt();
      // 与 write 中的 writer.write(p) 保持一致，使用 reader.read()
      path = List.generate(len, (_) => reader.read() as LatLngPoint);
    }
    return TransportSegment(
      id: id,
      fromNodeId: fromNodeId,
      toNodeId: toNodeId,
      mode: mode,
      userDurationMinutes: userDur,
      estimatedDurationMinutes: estDur,
      distanceMeters: dist,
      path: path,
    );
  }

  @override
  void write(BinaryWriter writer, TransportSegment obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.fromNodeId)
      ..writeString(obj.toNodeId)
      ..write(obj.mode)
      ..writeBool(obj.userDurationMinutes != null);
    if (obj.userDurationMinutes != null)
      writer.writeInt(obj.userDurationMinutes!);
    writer.writeBool(obj.estimatedDurationMinutes != null);
    if (obj.estimatedDurationMinutes != null)
      writer.writeInt(obj.estimatedDurationMinutes!);
    writer.writeBool(obj.distanceMeters != null);
    if (obj.distanceMeters != null) writer.writeDouble(obj.distanceMeters!);
    if (obj.path != null) {
      writer
        ..writeBool(true)
        ..writeInt(obj.path!.length);
      for (final p in obj.path!) {
        writer.write(p);
      }
    } else {
      writer.writeBool(false);
    }
  }
}
