import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../plan/presentation/plan_controller.dart';
import 'providers.dart';
import 'fit_utils.dart';

class PlaceDetailPanel extends ConsumerWidget {
  const PlaceDetailPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedPlaceProvider);
    if (selected == null) {
      return const Center(child: Text('未选择地点'));
    }
    final inPlan = selected.nodeId != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.place),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selected.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${selected.point.lat.toStringAsFixed(6)}, ${selected.point.lng.toStringAsFixed(6)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final controller = ref.read(mapControllerProvider);
                      if (controller != null) {
                        await controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(selected.point.lat, selected.point.lng),
                              zoom: 16,
                            ),
                          ),
                        );
                      }
                      // 只聚焦不改变页面
                    },
                    icon: const Icon(Icons.center_focus_strong),
                    label: const Text('在地图上查看'),
                  ),
                  if (inPlan)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () async {
                        await ref.read(planControllerProvider.notifier).deleteNode(selected.nodeId!);
                        ref.read(selectedPlaceProvider.notifier).state = null;
                        ref.read(panelPageProvider.notifier).state = PanelPage.timeline;
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('从计划中移除'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () async {
                        // 加入计划并适配相机到合适视图
                        await ref.read(planControllerProvider.notifier).addNodeAt(
                              selected.point,
                              title: selected.title,
                              mode: ref.read(transportModeProvider),
                            );
                        final controller = ref.read(mapControllerProvider);
                        final currentPage = ref.read(panelPageProvider);
                        if (controller != null) {
                          if (currentPage == PanelPage.timeline) {
                            // 仅时间轴页才适配整计划
                            final planAsync = ref.read(planControllerProvider);
                            if (planAsync.hasValue) {
                              await FitUtils.fitPlan(
                                controller: controller,
                                plan: planAsync.value!.currentPlan,
                                sheetFraction: ref.read(sheetFractionProvider),
                                animate: true,
                              );
                            }
                          } else {
                            // 详情页：仅聚焦该地点
                            await controller.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(selected.point.lat, selected.point.lng),
                                  zoom: 16,
                                ),
                              ),
                            );
                          }
                        }
                        // 高亮新加入的节点（通常是最后一个）
                        final plan = ref.read(planControllerProvider).valueOrNull?.currentPlan;
                        if (plan != null && plan.nodes.isNotEmpty) {
                          final last = plan.nodes.last;
                          ref.read(selectedPlaceProvider.notifier).state = SelectedPlace(
                            nodeId: last.id,
                            title: last.title,
                            point: last.point,
                          );
                        }
                      },
                      icon: const Icon(Icons.add_location_alt),
                      label: const Text('加入计划'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
