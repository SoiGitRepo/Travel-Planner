import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:travel_planner/core/widgets/glassy/glassy.dart';

import '../../../core/models/transport_mode.dart';
import '../../../core/models/transport_segment.dart';
import '../../plan/presentation/plan_controller.dart';
import 'providers.dart';

class TimelinePanel extends ConsumerWidget {
  final DraggableScrollableController controller;
  const TimelinePanel({super.key, required this.controller});

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
