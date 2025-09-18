import 'package:hive/hive.dart';

enum TransportMode {
  driving,
  walking,
  transit,
}

class TransportModeAdapter extends TypeAdapter<TransportMode> {
  @override
  final int typeId = 1;

  @override
  TransportMode read(BinaryReader reader) {
    final value = reader.readByte();
    switch (value) {
      case 0:
        return TransportMode.driving;
      case 1:
        return TransportMode.walking;
      case 2:
        return TransportMode.transit;
      default:
        return TransportMode.driving;
    }
  }

  @override
  void write(BinaryWriter writer, TransportMode obj) {
    switch (obj) {
      case TransportMode.driving:
        writer.writeByte(0);
        break;
      case TransportMode.walking:
        writer.writeByte(1);
        break;
      case TransportMode.transit:
        writer.writeByte(2);
        break;
    }
  }
}
