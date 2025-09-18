import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/models/transport_mode.dart';
import '../../../core/models/latlng_point.dart' as model;
import '../../../core/models/transport_segment.dart';
import '../../plan/presentation/plan_controller.dart';

final mapControllerProvider =
    StateProvider<GoogleMapController?>((ref) => null);
final transportModeProvider =
    StateProvider<TransportMode>((ref) => TransportMode.walking);
// 底部面板当前高度占屏幕高度的比例（0~1）
final sheetFractionProvider = StateProvider<double>((ref) => 0.2);

class SelectedPlace {
  final String? nodeId; // 若为已在计划中的节点则有值
  final String title;
  final model.LatLngPoint point;
  const SelectedPlace({this.nodeId, required this.title, required this.point});
}

final selectedPlaceProvider = StateProvider<SelectedPlace?>((ref) => null);

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final _sheetController = DraggableScrollableController();
  Timer? _fitDebounce;
  // 去除拖动结束后的二次动画，改为在接近吸附档位时直接使用动画，避免“两段式”停顿
  DateTime? _lastAnimateAt; // 上一次使用 animate 的时间
  double _lastSheetSize = 0.2; // 记录上一次的面板比例
  static const _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco default
    zoom: 12,
  );

  // 注意：不要在 initState 使用 ref.listen（Riverpod 限制）。

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(() {
      final size = _sheetController.size; // 0-1
      ref.read(sheetFractionProvider.notifier).state = size;
      // 拖动中节流触发视野适配：接近吸附档位时直接用动画，否则根据变化幅度与节流使用 move
      _fitDebounce?.cancel();
      _fitDebounce = Timer(const Duration(milliseconds: 90), () {
        final delta = (size - _lastSheetSize).abs();
        final now = DateTime.now();
        final since = _lastAnimateAt == null
            ? const Duration(milliseconds: 999)
            : now.difference(_lastAnimateAt!);
        const snaps = [0.12, 0.6, 0.9];
        final nearSnap = snaps.any((s) => (size - s).abs() < 0.02);
        final shouldAnimate = nearSnap || delta > 0.08 || since.inMilliseconds > 320;
        _fitToNodes(context, animate: shouldAnimate);
        if (shouldAnimate) {
          _lastAnimateAt = now;
        }
        _lastSheetSize = size;
      });
    });
  }

  @override
  void dispose() {
    _fitDebounce?.cancel();
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _fitToNodes(BuildContext context, {bool animate = true}) async {
    final controller = ref.read(mapControllerProvider);
    final planAsync = ref.read(planControllerProvider);
    if (controller == null || !planAsync.hasValue) return;
    final plan = planAsync.value!.currentPlan;
    final nodes = plan.nodes;
    final segs = plan.segments;

    // 收集所有需要纳入视野的点：节点坐标 + 所有路线折线点
    final pts = <LatLng>[];
    for (final n in nodes) {
      pts.add(LatLng(n.point.lat, n.point.lng));
    }
    for (final s in segs) {
      final path = s.path ?? const [];
      for (final p in path) {
        pts.add(LatLng(p.lat, p.lng));
      }
    }

    if (pts.isEmpty) {
      final update = CameraUpdate.newCameraPosition(_initialPosition);
      if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
      return;
    }
    if (pts.length == 1) {
      final update = CameraUpdate.newCameraPosition(
          CameraPosition(target: pts.first, zoom: 14));
      if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
      return;
    }

    var minLat = pts.first.latitude;
    var maxLat = pts.first.latitude;
    var minLng = pts.first.longitude;
    var maxLng = pts.first.longitude;
    for (final p in pts) {
      minLat = p.latitude < minLat ? p.latitude : minLat;
      maxLat = p.latitude > maxLat ? p.latitude : maxLat;
      minLng = p.longitude < minLng ? p.longitude : minLng;
      maxLng = p.longitude > maxLng ? p.longitude : maxLng;
    }

    // 基于底部面板高度，计算需要的“可见比例”，确保所有点都显示在 (地图高度 - 面板高度) 内；
    // 做法：按 1/(可见比例) 扩大内容纵向范围，并将中心按面板占比向上偏移。
    final fraction = ref.read(sheetFractionProvider).clamp(0.0, 0.95);
    final latSpan = (maxLat - minLat).abs();
    final safeSpan = latSpan < 1e-5 ? 1e-3 : latSpan; // 防止过小导致过度放大
    final visibleRatio =
        (0.85 - fraction).clamp(0.2, 0.9); // 最少给 20% 可见空间，避免无穷放大
    final expandFactor = 1.0 / visibleRatio;
    final targetSpan = safeSpan * expandFactor;
    final grow = targetSpan - safeSpan;
    // 以“向上扩”为主，下方保留少量余量
    minLat -= grow * 0.15;
    maxLat += grow * 0.85;
    // 根据面板高度，将相机中心向下偏移（使内容在屏幕上整体上移，远离底部遮挡）
    final shiftLat = targetSpan * (fraction * 0.9); // 0~0.475倍span
    minLat -= shiftLat;
    maxLat -= shiftLat;

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    try {
      final update = CameraUpdate.newLatLngBounds(bounds, 64);
      if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
    } catch (_) {
      // 某些平台在首次渲染或地图尚未布局完成时会抛错，降级为移动中心点
      final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
      final update = CameraUpdate.newLatLng(center);
      if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
    }
  }

  Future<void> _onLongPress(LatLng point) async {
    final mode = ref.read(transportModeProvider);
    await ref.read(planControllerProvider.notifier).addNodeAt(
          model.LatLngPoint(point.latitude, point.longitude),
          mode: mode,
        );
    unawaited(_fitToNodes(context));
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(planControllerProvider);

    final markers = <Marker>{};
    final polylines = <Polyline>{};

    planAsync.whenData((s) {
      final nodes = s.currentPlan.nodes;
      for (var i = 0; i < nodes.length; i++) {
        final n = nodes[i];
        markers.add(Marker(
          markerId: MarkerId(n.id),
          position: LatLng(n.point.lat, n.point.lng),
          infoWindow: InfoWindow(title: n.title),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          onTap: () {
            ref.read(selectedPlaceProvider.notifier).state = SelectedPlace(
              nodeId: n.id,
              title: n.title,
              point: n.point,
            );
          },
        ));
      }
      for (final seg in s.currentPlan.segments) {
        final pts = seg.path ?? [];
        if (pts.length >= 2) {
          polylines.add(Polyline(
            polylineId: PolylineId(seg.id),
            points: pts.map((e) => LatLng(e.lat, e.lng)).toList(),
            color: Colors.indigo,
            width: 5,
          ));
        }
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            myLocationButtonEnabled: true,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            markers: markers,
            polylines: polylines,
            onMapCreated: (controller) {
              ref.read(mapControllerProvider.notifier).state = controller;
            },
            onTap: (latLng) {
              ref.read(selectedPlaceProvider.notifier).state = SelectedPlace(
                title: '所选位置',
                point: model.LatLngPoint(latLng.latitude, latLng.longitude),
              );
            },
            onLongPress: _onLongPress,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _fitToNodes(context),
              icon: const Icon(Icons.center_focus_strong),
              label: const Text('适配视野'),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 12,
            child: _ModeSwitcher(),
          ),
          // 选择/新增某天计划
          Positioned(
            right: 16,
            bottom: 24,
            child: FloatingActionButton(
              heroTag: 'pick_date',
              onPressed: () async {
                final today = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: today,
                  firstDate: DateTime(today.year - 1),
                  lastDate: DateTime(today.year + 2),
                );
                if (picked != null) {
                  await ref
                      .read(planControllerProvider.notifier)
                      .createPlanForDate(picked);
                  // 切换/创建当天计划后，自适应视野
                  unawaited(_fitToNodes(context));
                }
              },
              child: const Icon(Icons.calendar_month),
            ),
          ),
          // 通过手动输入经纬度添加节点（默认替代方案）
          Positioned(
            left: 16,
            bottom: 24,
            child: FloatingActionButton(
              heroTag: 'add_node_manual',
              onPressed: () async {
                final latCtl = TextEditingController();
                final lngCtl = TextEditingController();
                final titleCtl = TextEditingController();
                final res = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('添加节点（手动输入经纬度）'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                            controller: titleCtl,
                            decoration: const InputDecoration(labelText: '标题')),
                        TextField(
                            controller: latCtl,
                            decoration: const InputDecoration(labelText: '纬度')),
                        TextField(
                            controller: lngCtl,
                            decoration: const InputDecoration(labelText: '经度')),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('取消')),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('确定')),
                    ],
                  ),
                );
                if (res == true) {
                  final lat = double.tryParse(latCtl.text.trim());
                  final lng = double.tryParse(lngCtl.text.trim());
                  if (lat != null && lng != null) {
                    await _onLongPress(LatLng(lat, lng));
                  }
                }
              },
              child: const Icon(Icons.add_location_alt),
            ),
          ),
          _TimelinePanel(controller: _sheetController),
          if (planAsync.isLoading)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeSwitcher extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(transportModeProvider);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: ToggleButtons(
        isSelected: [
          mode == TransportMode.walking,
          mode == TransportMode.driving,
          mode == TransportMode.transit,
        ],
        borderRadius: BorderRadius.circular(12),
        onPressed: (index) {
          final next = [
            TransportMode.walking,
            TransportMode.driving,
            TransportMode.transit
          ][index];
          ref.read(transportModeProvider.notifier).state = next;
        },
        children: const [
          Padding(
              padding: EdgeInsets.all(8), child: Icon(Icons.directions_walk)),
          Padding(
              padding: EdgeInsets.all(8), child: Icon(Icons.directions_car)),
          Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.directions_transit)),
        ],
      ),
    );
  }
}

class _TimelinePanel extends ConsumerWidget {
  final DraggableScrollableController controller;
  const _TimelinePanel({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planControllerProvider);
    final nodesRaw = planAsync.valueOrNull?.currentPlan.nodes ?? const [];
    final segs = planAsync.valueOrNull?.currentPlan.segments ?? const [];
    // 按到达时间排序（未设定时间的放在最后，按原序）
    final nodes = List.of(nodesRaw);
    nodes.sort((a, b) {
      if (a.scheduledTime == null && b.scheduledTime == null) return 0;
      if (a.scheduledTime == null) return 1;
      if (b.scheduledTime == null) return -1;
      return a.scheduledTime!.compareTo(b.scheduledTime!);
    });

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: DraggableScrollableSheet(
          controller: controller,
          initialChildSize: 0.2,
          minChildSize: 0.12,
          maxChildSize: 0.9,
          snap: true,
          snapSizes: const [0.12, 0.6, 0.9],
          expand: false,
          builder: (context, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: CustomScrollView(
                controller: controller,
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverToBoxAdapter(
                    child: Center(
                      child: Container(
                        height: 6,
                        width: 56,
                        decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(3)),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  const SliverToBoxAdapter(
                    child: ListTile(
                      title: Text('时间轴'),
                      subtitle: Text('长按地图添加节点；每段交通方式可单独设置；点击可编辑'),
                    ),
                  ),
                  const SliverToBoxAdapter(child: Divider(height: 1)),
                  // 选中地点信息面板（若有）
                  SliverToBoxAdapter(
                    child: Builder(builder: (context) {
                      final selected = ref.watch(selectedPlaceProvider);
                      if (selected == null) return const SizedBox.shrink();
                      final inPlan = selected.nodeId != null;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Card(
                          child: ListTile(
                            leading: const Icon(Icons.place),
                            title: Text(selected.title),
                            subtitle: Text(
                                '${selected.point.lat.toStringAsFixed(5)}, ${selected.point.lng.toStringAsFixed(5)}'),
                            trailing: Wrap(spacing: 8, children: [
                              IconButton(
                                tooltip: inPlan ? '从计划中移除' : '加入计划',
                                icon: Icon(inPlan ? Icons.remove : Icons.add),
                                onPressed: () async {
                                  if (inPlan) {
                                    await ref
                                        .read(planControllerProvider.notifier)
                                        .deleteNode(selected.nodeId!);
                                  } else {
                                    await ref
                                        .read(planControllerProvider.notifier)
                                        .addNodeAt(
                                          selected.point,
                                          title: selected.title,
                                          mode: ref.read(transportModeProvider),
                                        );
                                  }
                                  ref
                                      .read(selectedPlaceProvider.notifier)
                                      .state = null;
                                },
                              ),
                              IconButton(
                                tooltip: '关闭',
                                icon: const Icon(Icons.close),
                                onPressed: () => ref
                                    .read(selectedPlaceProvider.notifier)
                                    .state = null,
                              ),
                            ]),
                          ),
                        ),
                      );
                    }),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // 防御：当节点列表为空时，不应构建任何子项（理论上 childCount=0 已避免触发）
                        if (nodes.isEmpty) return const SizedBox.shrink();
                        if (index.isEven) {
                          final i = index ~/ 2;
                          final n = nodes[i];
                          final timeStr = n.scheduledTime != null
                              ? n.scheduledTime!.toString().substring(11, 16)
                              : '--:--';
                          return Dismissible(
                            key: ValueKey('node_${n.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) async {
                              await ref
                                  .read(planControllerProvider.notifier)
                                  .deleteNode(n.id);
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.shade50,
                                foregroundColor: Colors.indigo,
                                child: Text('${i + 1}'),
                              ),
                              title: Text(n.title),
                              subtitle: Text(
                                '${n.point.lat.toStringAsFixed(5)}, ${n.point.lng.toStringAsFixed(5)}  · 到达 $timeStr${n.stayDurationMinutes != null ? ' · 停留 ${n.stayDurationMinutes} 分钟' : ''}',
                              ),
                              onTap: () {
                                ref.read(selectedPlaceProvider.notifier).state =
                                    SelectedPlace(
                                  nodeId: n.id,
                                  title: n.title,
                                  point: n.point,
                                );
                              },
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  IconButton(
                                    tooltip: '设置到达时间',
                                    icon: const Icon(Icons.access_time),
                                    onPressed: () async {
                                      final now = DateTime.now();
                                      final picked = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.fromDateTime(
                                            n.scheduledTime ?? now),
                                      );
                                      if (picked != null) {
                                        final day =
                                            planAsync.value!.currentPlan.date;
                                        final arrival = DateTime(
                                            day.year,
                                            day.month,
                                            day.day,
                                            picked.hour,
                                            picked.minute);
                                        await ref
                                            .read(
                                                planControllerProvider.notifier)
                                            .updateNodeSchedule(
                                                nodeId: n.id,
                                                arrivalTime: arrival);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    tooltip: '设置停留时长',
                                    icon: const Icon(Icons.timelapse),
                                    onPressed: () async {
                                      final controller = TextEditingController(
                                          text: (n.stayDurationMinutes ?? '')
                                              .toString());
                                      final minutes = await showDialog<int?>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('设置停留时长（分钟）'),
                                          content: TextField(
                                            controller: controller,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                hintText: '例如 60'),
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, null),
                                                child: const Text('取消')),
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  ctx,
                                                  int.tryParse(
                                                      controller.text.trim())),
                                              child: const Text('确定'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (minutes != null) {
                                        await ref
                                            .read(
                                                planControllerProvider.notifier)
                                            .updateNodeSchedule(
                                                nodeId: n.id,
                                                stayMinutes: minutes);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          final segIndex = (index - 1) ~/ 2;
                          // 找到当前节点与下一节点之间的段
                          final fromNode = nodes[segIndex];
                          final toNode = nodes[segIndex + 1];
                          TransportSegment? seg;
                          for (final s in segs) {
                            if (s.fromNodeId == fromNode.id &&
                                s.toNodeId == toNode.id) {
                              seg = s;
                              break;
                            }
                          }
                          if (seg == null) return const SizedBox.shrink();
                          final segNN =
                              seg; // capture a non-null local for closures
                          final est = segNN.estimatedDurationMinutes;
                          final user = segNN.userDurationMinutes;
                          final subtitle = user != null
                              ? '我的时长 ${user} 分钟${est != null ? '（预估 ${est} 分钟）' : ''}'
                              : (est != null ? '预估 $est 分钟' : '无预估，直线连接');
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.more_horiz,
                                color: Colors.grey),
                            title: Text('交通：${segNN.mode.name}'),
                            subtitle: Text(subtitle),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  tooltip: '设置我的时长',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final controller = TextEditingController(
                                      text: (segNN.userDurationMinutes ??
                                              segNN.estimatedDurationMinutes ??
                                              '')
                                          .toString(),
                                    );
                                    final minutes = await showDialog<int?>(
                                      context: context,
                                      builder: (ctx) {
                                        return AlertDialog(
                                          title: const Text('设置我的交通时长（分钟）'),
                                          content: TextField(
                                            controller: controller,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                hintText: '请输入分钟数，例如 15'),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(null),
                                              child: const Text('取消'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                final v = int.tryParse(
                                                    controller.text.trim());
                                                Navigator.of(ctx).pop(v);
                                              },
                                              child: const Text('确定'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (minutes != null) {
                                      await ref
                                          .read(planControllerProvider.notifier)
                                          .setSegmentUserDuration(
                                              segmentId: segNN.id,
                                              minutes: minutes);
                                    }
                                  },
                                ),
                                if (segNN.userDurationMinutes != null)
                                  IconButton(
                                    tooltip: '清除我的时长',
                                    icon: const Icon(Icons.clear),
                                    onPressed: () async {
                                      await ref
                                          .read(planControllerProvider.notifier)
                                          .setSegmentUserDuration(
                                              segmentId: segNN.id,
                                              minutes: null);
                                    },
                                  ),
                                PopupMenuButton<TransportMode>(
                                  tooltip: '切换交通方式',
                                  onSelected: (m) async {
                                    await ref
                                        .read(planControllerProvider.notifier)
                                        .setSegmentMode(
                                            segmentId: segNN.id, mode: m);
                                  },
                                  itemBuilder: (ctx) => const [
                                    PopupMenuItem(
                                        value: TransportMode.walking,
                                        child: Text('步行')),
                                    PopupMenuItem(
                                        value: TransportMode.driving,
                                        child: Text('驾车')),
                                    PopupMenuItem(
                                        value: TransportMode.transit,
                                        child: Text('公共交通')),
                                  ],
                                  icon: const Icon(Icons.alt_route),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      childCount: nodes.isEmpty ? 0 : (nodes.length * 2 - 1),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
