import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../core/models/latlng_point.dart';
import '../../../core/models/node.dart';
import '../../../core/models/plan.dart';
import '../../../core/models/plan_group.dart';
import '../../../core/models/transport_mode.dart';
import '../../../core/models/transport_segment.dart';

class PlanIO {
  const PlanIO();

  Future<String> exportToJson(PlanGroup group) async {
    final map = _groupToMap(group);
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  Future<String> saveExportToFile(PlanGroup group) async {
    final jsonStr = await exportToJson(group);
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now();
    final name = 'travel_plan_${ts.year}${twoDigits(ts.month)}${twoDigits(ts.day)}_${twoDigits(ts.hour)}${twoDigits(ts.minute)}${twoDigits(ts.second)}.json';
    final file = File('${dir.path}/$name');
    await file.writeAsString(jsonStr);
    return file.path;
  }

  Future<PlanGroup> importFromJson(String jsonStr) async {
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    return _groupFromMap(map);
  }

  Future<PlanGroup> loadImportFromFile(String path) async {
    final file = File(path);
    final jsonStr = await file.readAsString();
    return importFromJson(jsonStr);
  }

  // --- helpers ---
  Map<String, dynamic> _groupToMap(PlanGroup g) => {
        'id': g.id,
        'name': g.name,
        'plans': g.plans.map(_planToMap).toList(),
      };

  Map<String, dynamic> _planToMap(Plan p) => {
        'id': p.id,
        'date': DateTime(p.date.year, p.date.month, p.date.day).millisecondsSinceEpoch,
        'nodes': p.nodes.map(_nodeToMap).toList(),
        'segments': p.segments.map(_segToMap).toList(),
      };

  Map<String, dynamic> _nodeToMap(Node n) => {
        'id': n.id,
        'title': n.title,
        'point': {'lat': n.point.lat, 'lng': n.point.lng},
        'scheduledTime': n.scheduledTime?.millisecondsSinceEpoch,
        'stay': n.stayDurationMinutes,
      };

  Map<String, dynamic> _segToMap(TransportSegment s) => {
        'id': s.id,
        'from': s.fromNodeId,
        'to': s.toNodeId,
        'mode': s.mode.name,
        'userMinutes': s.userDurationMinutes,
        'estMinutes': s.estimatedDurationMinutes,
        'distance': s.distanceMeters,
        'path': (s.path ?? const [])
            .map((e) => {'lat': e.lat, 'lng': e.lng})
            .toList(),
      };

  PlanGroup _groupFromMap(Map<String, dynamic> m) {
    final plans = ((m['plans'] as List?) ?? const [])
        .map((e) => _planFromMap((e as Map).cast<String, dynamic>()))
        .toList();
    return PlanGroup(
      id: (m['id'] as String?) ?? 'default',
      name: (m['name'] as String?) ?? '我的行程',
      plans: plans,
    );
  }

  Plan _planFromMap(Map<String, dynamic> m) {
    final dateMs = (m['date'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch;
    final nodes = ((m['nodes'] as List?) ?? const [])
        .map((e) => _nodeFromMap((e as Map).cast<String, dynamic>()))
        .toList();
    final segments = ((m['segments'] as List?) ?? const [])
        .map((e) => _segFromMap((e as Map).cast<String, dynamic>()))
        .toList();
    return Plan(
      id: (m['id'] as String?) ?? DateTime.now().microsecondsSinceEpoch.toString(),
      date: DateTime.fromMillisecondsSinceEpoch(dateMs),
      nodes: nodes,
      segments: segments,
    );
  }

  Node _nodeFromMap(Map<String, dynamic> m) {
    final schedMs = (m['scheduledTime'] as num?)?.toInt();
    // 兼容 point 缺失或类型异常（如为 String、List 等），并稳健解析 lat/lng
    double toDoubleSafe(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      if (v is String) {
        final dv = double.tryParse(v);
        return dv ?? 0;
      }
      return 0;
    }
    final pointAny = m['point'];
    double lat = 0;
    double lng = 0;
    if (pointAny is Map) {
      lat = toDoubleSafe(pointAny['lat']);
      lng = toDoubleSafe(pointAny['lng']);
    }
    return Node(
      id: (m['id'] as String?) ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: (m['title'] as String?) ?? '未命名',
      point: LatLngPoint(lat, lng),
      scheduledTime: schedMs != null ? DateTime.fromMillisecondsSinceEpoch(schedMs) : null,
      stayDurationMinutes: (m['stay'] as num?)?.toInt(),
    );
  }

  TransportSegment _segFromMap(Map<String, dynamic> m) {
    final modeStr = (m['mode'] as String?) ?? 'walking';
    final mode = switch (modeStr) {
      'driving' => TransportMode.driving,
      'transit' => TransportMode.transit,
      _ => TransportMode.walking,
    };
    final pathList = (m['path'] as List?)
            ?.map((e) => LatLngPoint(((e as Map)['lat'] as num).toDouble(), ((e)['lng'] as num).toDouble()))
            .toList();
    return TransportSegment(
      id: (m['id'] as String?) ?? DateTime.now().microsecondsSinceEpoch.toString(),
      fromNodeId: (m['from'] as String?) ?? '',
      toNodeId: (m['to'] as String?) ?? '',
      mode: mode,
      userDurationMinutes: (m['userMinutes'] as num?)?.toInt(),
      estimatedDurationMinutes: (m['estMinutes'] as num?)?.toInt(),
      distanceMeters: (m['distance'] as num?)?.toDouble(),
      path: pathList,
    );
  }

  String twoDigits(int v) => v.toString().padLeft(2, '0');
}
