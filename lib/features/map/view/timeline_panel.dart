import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_planner/core/widgets/glassy/glassy.dart';
import '../../plan/data/plan_io.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/node.dart';
import '../../../core/models/transport_mode.dart';
import '../../../core/models/transport_segment.dart';
import '../../plan/presentation/plan_controller.dart';
import 'providers.dart';
import 'panel_search.dart';
import 'place_detail_panel.dart';


enum _OverviewMenuAction {
  addPlan,
  groupManage,
  exportJson,
  importJson,
}

class TimelinePanel extends ConsumerWidget {
  Future<SelectedPlace> _findSelectedPlaceForNode(Node n, WidgetRef ref) async {
    // 优先从附近地点或搜索结果中查找原始 placeId
    final nearby = ref.read(overlayPlacesProvider);
    final search = ref.read(searchResultsProvider);
    final all = [...nearby, ...search];
    for (final p in all) {
      if (p.location.lat == n.point.lat && p.location.lng == n.point.lng) {
        return SelectedPlace(
          nodeId: n.id,
          placeId: p.id,
          title: n.title,
          point: n.point,
        );
      }
    }
    // 如果找不到，则不带 placeId
    return SelectedPlace(
      nodeId: n.id,
      title: n.title,
      point: n.point,
    );
  }
  final DraggableScrollableController controller;
  const TimelinePanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planControllerProvider);
    final nodesRaw = planAsync.valueOrNull?.currentPlan.nodes ?? const [];
    final segs = planAsync.valueOrNull?.currentPlan.segments ?? const [];
    final page = ref.watch(panelPageProvider);
    // 按到达时间排序（未设定时间的放在最后，按原序）
    final nodes = List.of(nodesRaw);
    nodes.sort((a, b) {
      if (a.scheduledTime == null && b.scheduledTime == null) return 0;
      if (a.scheduledTime == null) return 1;
      if (b.scheduledTime == null) return -1;
      return a.scheduledTime!.compareTo(b.scheduledTime!);
    });
    // 总览统计：交通总时长（优先我的时长，其次预估）、交通总距离、停留总时长
    final int travelMinutes = segs.fold<int>(
      0,
      (sum, s) =>
          (sum + (s.userDurationMinutes ?? s.estimatedDurationMinutes ?? 0))
              .toInt(),
    );
    final double distanceMeters = segs.fold<double>(
      0.0,
      (sum, s) => sum + (s.distanceMeters ?? 0.0),
    );
    final int stayMinutes = nodes.fold<int>(
      0,
      (sum, n) => (sum + (n.stayDurationMinutes ?? 0)).toInt(),
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        bottom: false,
        child: DraggableScrollableSheet(
          controller: controller,
          initialChildSize: 0.2,
          minChildSize: 0.12,
          maxChildSize: 0.9,
          snap: true,
          snapSizes: const [0.12, 0.6, 0.9],
          expand: false,
          builder: (context, scrollController) {
            final bottomSafe = MediaQuery.of(context).padding.bottom;
            return Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
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
              // 将背景白色延展至屏幕底部，同时通过 padding 让内容不占用该留白区域
              padding: EdgeInsets.only(bottom: bottomSafe),
              child: CustomScrollView(
                controller: scrollController,
                slivers: () {
                  final slivers = <Widget>[
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
                  ];
                  // 顶部头部：返回或搜索入口
                  if (page == PanelPage.timeline) {
                    slivers.add(
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => ref
                                .read(panelPageProvider.notifier)
                                .state = PanelPage.search,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2)),
                                ],
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.search, color: Colors.black54),
                                  SizedBox(width: 8),
                                  Expanded(
                                      child: Text('搜索地点（范围：当前地图）',
                                          style: TextStyle(
                                              color: Colors.black54))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                    slivers.add(
                        const SliverToBoxAdapter(child: SizedBox(height: 8)));
                    slivers.add(
                      const SliverToBoxAdapter(
                        child: ListTile(
                          title: Text('时间轴'),
                          subtitle: Text('长按地图添加节点；每段交通方式可单独设置；点击可编辑'),
                        ),
                      ),
                    );
                  } else {
                    slivers.add(
                      SliverToBoxAdapter(
                        child: ListTile(
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => ref
                                .read(panelPageProvider.notifier)
                                .state = PanelPage.timeline,
                          ),
                          title: Text(page == PanelPage.search ? '搜索' : '地点详情'),
                        ),
                      ),
                    );
                  }

                  if (page == PanelPage.search) {
                    slivers.add(
                      const SliverFillRemaining(
                        hasScrollBody: true,
                        child: PanelSearch(),
                      ),
                    );
                    return slivers;
                  }
                  if (page == PanelPage.detail) {
                    slivers.add(
                      const SliverToBoxAdapter(child: PlaceDetailPanel()),
                    );
                    return slivers;
                  }
                  // 总览卡片与添加日期计划入口（仅时间轴页）
                  slivers.add(
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Card(
                          child: ListTile(
                            leading: const Icon(Icons.assessment),
                            title: const Text('总览'),
                            subtitle: Text(
                              '交通 $travelMinutes 分钟 · 距离 ${(distanceMeters / 1000).toStringAsFixed(1)} km · 停留 $stayMinutes 分钟',
                            ),
                            trailing: PopupMenuButton<_OverviewMenuAction>(
                              tooltip: '更多',
                              icon: const Icon(Icons.more_vert),
                              onSelected: (action) async {
                                switch (action) {
                                  case _OverviewMenuAction.addPlan:
                                    final now = DateTime.now();
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: planAsync
                                              .valueOrNull?.currentPlan.date ??
                                          now,
                                      firstDate: DateTime(now.year - 1),
                                      lastDate: DateTime(now.year + 2),
                                    );
                                    if (picked != null) {
                                      await ref
                                          .read(planControllerProvider.notifier)
                                          .createPlanForDate(picked);
                                    }
                                    break;
                                  case _OverviewMenuAction.groupManage:
                                    context.push('/groups');
                                    break;
                                  case _OverviewMenuAction.exportJson:
                                    final group = planAsync.valueOrNull?.group;
                                    if (group == null) return;
                                    const io = PlanIO();
                                    final path =
                                        await io.saveExportToFile(group);
                                    final messenger =
                                        ScaffoldMessenger.maybeOf(context);
                                    messenger?.showSnackBar(SnackBar(
                                        content: Text('已导出至文件：$path')));
                                    break;
                                  case _OverviewMenuAction.importJson:
                                    final controller = TextEditingController();
                                    final jsonStr = await showDialog<String?>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('导入 JSON（粘贴内容）'),
                                        content: SizedBox(
                                          width: 520,
                                          child: TextField(
                                            controller: controller,
                                            maxLines: 12,
                                            decoration: const InputDecoration(
                                                hintText: '将 JSON 粘贴到此处'),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, null),
                                              child: const Text('取消')),
                                          TextButton(
                                              onPressed: () => Navigator.pop(
                                                  ctx, controller.text),
                                              child: const Text('确定')),
                                        ],
                                      ),
                                    );
                                    if (jsonStr == null ||
                                        jsonStr.trim().isEmpty) {
                                      return;
                                    }
                                    try {
                                      const io = PlanIO();
                                      final group =
                                          await io.importFromJson(jsonStr);
                                      await ref
                                          .read(planControllerProvider.notifier)
                                          .replaceGroup(group);
                                      if (!context.mounted) {
                                        return;
                                      }
                                      final messenger =
                                          ScaffoldMessenger.maybeOf(context);
                                      messenger?.showSnackBar(const SnackBar(
                                          content: Text('导入成功')));
                                    } catch (e) {
                                      if (!context.mounted) {
                                        return;
                                      }
                                      final messenger =
                                          ScaffoldMessenger.maybeOf(context);
                                      messenger?.showSnackBar(
                                          SnackBar(content: Text('导入失败：$e')));
                                    }
                                    break;
                                }
                              },
                              itemBuilder: (ctx) => const [
                                PopupMenuItem(
                                    value: _OverviewMenuAction.addPlan,
                                    child: Text('添加日期计划')),
                                PopupMenuItem(
                                    value: _OverviewMenuAction.groupManage,
                                    child: Text('分组管理')),
                                PopupMenuItem(
                                    value: _OverviewMenuAction.exportJson,
                                    child: Text('导出JSON')),
                                PopupMenuItem(
                                    value: _OverviewMenuAction.importJson,
                                    child: Text('导入JSON')),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                  slivers
                      .add(const SliverToBoxAdapter(child: Divider(height: 1)));
                  // 不再在时间轴页展示“选中点详情卡片”（仅在详情页展示）
                  slivers.add(
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (page != PanelPage.timeline) {
                            return const SizedBox.shrink();
                          }
                          // 防御：当节点列表为空时，不应构建任何子项（理论上 childCount=0 已避免触发）
                          if (nodes.isEmpty) {
                            return const SizedBox.shrink();
                          }
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
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
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
                                onTap: () async {
                                  ref.read(selectedPlaceProvider.notifier).state =
                                      await _findSelectedPlaceForNode(n, ref);
                                  ref.read(panelPageProvider.notifier).state =
                                      PanelPage.detail;
                                  // 面板移动到 60% 中档位置
                                  await controller.animateTo(
                                    0.6,
                                    duration: const Duration(milliseconds: 260),
                                    curve: Curves.easeOutCubic,
                                  );
                                  final c = ref.read(mapControllerProvider);
                                  if (c != null) {
                                    // 面板感知：根据底部面板占比与当前可见区域跨度，计算上移偏移
                                    final fraction = ref
                                        .read(sheetFractionProvider)
                                        .clamp(0.0, 0.95);
                                    // 基于目标 zoom 估算纬度跨度，以确保平移距离与最终视野匹配
                                    const zoom = 16.0;
                                    final latSpan = 360 / pow(2, zoom);
                                    // 将目标点置于可见区域的垂直中心，相机中心需下移 fraction/2 的屏幕高度
                                    final shiftLat = latSpan * (fraction / 2.0);
                                    final center = LatLng(
                                        n.point.lat - shiftLat, n.point.lng);

                                    await c.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                            target: center, zoom: 16),
                                      ),
                                    );
                                    c.showMarkerInfoWindow(MarkerId(n.id));
                                  }
                                },
                                trailing: Wrap(
                                  spacing: 8,
                                  children: [
                                    IconButton(
                                      tooltip: '重命名',
                                      icon: const Icon(Icons.edit),
                                      onPressed: () async {
                                        final controller =
                                            TextEditingController(
                                                text: n.title);
                                        final newTitle =
                                            await showDialog<String?>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('重命名节点'),
                                            content: TextField(
                                              controller: controller,
                                              decoration: const InputDecoration(
                                                  hintText: '输入新的名称'),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, null),
                                                child: const Text('取消'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    ctx,
                                                    controller.text.trim()),
                                                child: const Text('确定'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (newTitle != null &&
                                            newTitle.isNotEmpty) {
                                          await ref
                                              .read(planControllerProvider
                                                  .notifier)
                                              .updateNodeTitle(
                                                  nodeId: n.id,
                                                  title: newTitle);
                                        }
                                      },
                                    ),
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
                                              .read(planControllerProvider
                                                  .notifier)
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
                                        final controller =
                                            TextEditingController(
                                                text: (n.stayDurationMinutes ??
                                                        '')
                                                    .toString());
                                        final minutes = await showDialog<int?>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('设置停留时长（分钟）'),
                                            content: TextField(
                                              controller: controller,
                                              keyboardType:
                                                  TextInputType.number,
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
                                                    int.tryParse(controller.text
                                                        .trim())),
                                                child: const Text('确定'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (minutes != null) {
                                          await ref
                                              .read(planControllerProvider
                                                  .notifier)
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
                            final segNN = seg;
                            final est = segNN.estimatedDurationMinutes;
                            final user = segNN.userDurationMinutes;
                            final distStr = (segNN.distanceMeters != null &&
                                    segNN.distanceMeters! > 0)
                                ? ' · 距离 ${(segNN.distanceMeters! / 1000).toStringAsFixed(1)} km'
                                : '';
                            final subtitle = user != null
                                ? '我的时长 $user 分钟${est != null ? '（预估 $est 分钟）' : ''}$distStr'
                                : (est != null
                                    ? '预估 $est 分钟$distStr'
                                    : '无预估，直线连接$distStr');
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
                                                segNN
                                                    .estimatedDurationMinutes ??
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
                                              keyboardType:
                                                  TextInputType.number,
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
                                            .read(
                                                planControllerProvider.notifier)
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
                                            .read(
                                                planControllerProvider.notifier)
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
                  );
                  return slivers;
                }(),
              ),
            ).glassy(
              borderRadius: 40,
              settings: const LiquidGlassSettings(
                blur: 4,
                thickness: 60,
                blend: 40,
                lightAngle: 0.3 * pi,
                lightIntensity: 0.5,
                saturation: 0.5,
                lightness: 0.5,
              ),
            );
          },
        ),
      ),
    );
  }
}
