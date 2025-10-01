import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    final detailsAsync = selected.placeId == null
        ? const AsyncValue<Never>.loading()
        : ref.watch(placeDetailsProvider(selected.placeId!));
    final hasPlacesKey = (dotenv.env['GOOGLE_PLACES_API_KEY']?.isNotEmpty ?? false) ||
        (dotenv.env['GOOGLE_DIRECTIONS_API_KEY']?.isNotEmpty ?? false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selected.placeId != null && !hasPlacesKey)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withAlpha(102)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '未检测到 Places API Key，详情与图片可能不可用。请在 assets/env/.env 配置 GOOGLE_PLACES_API_KEY。',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
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
              if (selected.placeId == null)
                Text(
                  '${selected.point.lat.toStringAsFixed(6)}, ${selected.point.lng.toStringAsFixed(6)}',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else
                detailsAsync.when(
                  data: (d) {
                    if (d == null) {
                      return Text('暂无详情（网络受限或服务不可用）', style: Theme.of(context).textTheme.bodySmall);
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (d.address != null)
                          Text(d.address!, style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star_rate, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(d.rating?.toStringAsFixed(1) ?? '-', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(width: 8),
                            Text('(${d.userRatingsTotal ?? 0})', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (d.photoUrls.isNotEmpty)
                          SizedBox(
                            height: 96,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (_, i) => ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(d.photoUrls[i], height: 96, width: 128, fit: BoxFit.cover),
                              ),
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemCount: d.photoUrls.length,
                            ),
                          ),
                        if (d.photoUrls.isNotEmpty) const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (d.phone != null)
                              Chip(avatar: const Icon(Icons.phone, size: 16), label: Text(d.phone!)),
                            if (d.website != null)
                              Chip(avatar: const Icon(Icons.public, size: 16), label: Text(Uri.parse(d.website!).host)),
                            if (d.priceLevel != null)
                              Chip(avatar: const Icon(Icons.payments, size: 16), label: Text('价位 ${d.priceLevel}')),
                          ],
                        ),
                        if (d.openingWeekdayText.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('营业时间', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 4),
                          ...d.openingWeekdayText.map((e) => Text(e, style: Theme.of(context).textTheme.bodySmall)),
                        ],
                      ],
                    );
                  },
                  loading: () => const SizedBox(height: 20, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                  error: (_, __) => Text('加载详情失败', style: Theme.of(context).textTheme.bodySmall),
                ),
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // 在地图上查看按钮（始终显示）
                  OutlinedButton.icon(
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
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text('在地图上查看'),
                  ),
                  
                  // 加入/移除计划按钮
                  FilledButton.icon(
                    onPressed: () async {
                      if (inPlan) {
                        // 从计划中移除
                        await ref.read(planControllerProvider.notifier).deleteNode(selected.nodeId!);
                        if (!context.mounted) return;
                        ref.read(selectedPlaceProvider.notifier).state = null;
                        ref.read(panelPageProvider.notifier).state = PanelPage.timeline;
                      } else {
                        // 加入计划
                        final mode = ref.read(transportModeProvider);
                        await ref.read(planControllerProvider.notifier).addNodeAt(
                              selected.point,
                              title: selected.title,
                              mode: mode,
                            );
                        if (!context.mounted) return;

                        final controller = ref.read(mapControllerProvider);
                        final currentPage = ref.read(panelPageProvider);

                        if (controller != null) {
                          if (currentPage == PanelPage.timeline) {
                            // 时间轴页：适配整个计划
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
                        if (!context.mounted) return;

                        // 高亮新加入的节点（通常是最后一个）
                        final plan = ref.read(planControllerProvider).valueOrNull?.currentPlan;
                        if (plan != null && plan.nodes.isNotEmpty) {
                          final last = plan.nodes.last;
                          ref.read(selectedPlaceProvider.notifier).state = SelectedPlace(
                            nodeId: last.id,
                            placeId: selected.placeId, // 保留原始 placeId 以保持地址信息
                            title: last.title,
                            point: last.point,
                          );
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: inPlan ? Colors.red.shade100 : Theme.of(context).colorScheme.primary,
                      foregroundColor: inPlan ? Colors.red : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(inPlan ? Icons.remove_circle_outline : Icons.add_location_alt, size: 18),
                    label: Text(inPlan ? '从计划中移除' : '加入计划'),
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
