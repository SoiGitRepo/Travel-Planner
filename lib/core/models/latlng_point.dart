import 'package:hive/hive.dart';

class LatLngPoint {
  final double lat;
  final double lng;
  const LatLngPoint(this.lat, this.lng);
}

class LatLngPointAdapter extends TypeAdapter<LatLngPoint> {
  @override
  final int typeId = 2;

  @override
  LatLngPoint read(BinaryReader reader) {
    final lat = reader.readDouble();
    final lng = reader.readDouble();
    return LatLngPoint(lat, lng);
  }

  @override
  void write(BinaryWriter writer, LatLngPoint obj) {
    writer
      ..writeDouble(obj.lat)
      ..writeDouble(obj.lng);
  }
}
