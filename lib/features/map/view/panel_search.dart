import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/models/latlng_point.dart' as model;
import '../../../core/providers.dart';
import '../../../core/utils/haversine.dart';
import 'providers.dart';

class PanelSearch extends ConsumerStatefulWidget {
  const PanelSearch({super.key});

  @override
  ConsumerState<PanelSearch> createState() => _PanelSearchState();
}

class _PanelSearchState extends ConsumerState<PanelSearch> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? _radiusFromBounds(LatLngBounds? b) {
    if (b == null) return null;
    final sw = b.southwest;
    final ne = b.northeast;
    final center = LatLng((sw.latitude + ne.latitude) / 2, (sw.longitude + ne.longitude) / 2);
    final r1 = haversine(center.latitude, center.longitude, ne.latitude, ne.longitude);
    final r2 = haversine(center.latitude, center.longitude, sw.latitude, sw.longitude);
    return max(r1, r2).toInt();
  }

  Future<void> _doSearch() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() => _loading = true);
    try {
      final ps = ref.read(placesServiceProvider);
      final bounds = ref.read(visibleRegionProvider);
      final radius = _radiusFromBounds(bounds);
      model.LatLngPoint? near;
      if (bounds != null) {
        final sw = bounds.southwest;
        final ne = bounds.northeast;
        near = model.LatLngPoint((sw.latitude + ne.latitude) / 2, (sw.longitude + ne.longitude) / 2);
      }
      final list = await ps.searchText(q, near: near, radiusMeters: radius);
      ref.read(searchResultsProvider.notifier).state = list;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '输入关键字，例如 "美食"、"酒店"、"博物馆"（范围：当前地图）',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _doSearch(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _loading ? null : _doSearch,
                icon: const Icon(Icons.search),
                label: const Text('搜索'),
              ),
            ],
          ),
        ),
        if (_loading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: results.isEmpty
              ? const Center(child: Text('输入关键字并搜索，结果将标注在地图上'))
              : ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final it = results[i];
                    return ListTile(
                      leading: const Icon(Icons.place_outlined),
                      title: Text(it.name),
                      subtitle: Text(it.address ?? '${it.location.lat}, ${it.location.lng}'),
                      onTap: () async {
                        // 聚焦地图并进入详情
                        final controller = ref.read(mapControllerProvider);
                        if (controller != null) {
                          await controller.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(it.location.lat, it.location.lng),
                                zoom: 15,
                              ),
                            ),
                          );
                        }
                        ref.read(selectedPlaceProvider.notifier).state = SelectedPlace(
                          placeId: it.id,
                          title: it.name,
                          point: it.location,
                        );
                        ref.read(panelPageProvider.notifier).state = PanelPage.detail;
                      },
                      trailing: TextButton.icon(
                        onPressed: () async {
                          final controller = ref.read(mapControllerProvider);
                          if (controller != null) {
                            await controller.animateCamera(
                              CameraUpdate.newLatLng(LatLng(it.location.lat, it.location.lng)),
                            );
                          }
                          ref.read(selectedPlaceProvider.notifier).state = SelectedPlace(
                            placeId: it.id,
                            title: it.name,
                            point: it.location,
                          );
                          ref.read(panelPageProvider.notifier).state = PanelPage.detail;
                        },
                        icon: const Icon(Icons.info_outline),
                        label: const Text('查看'),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
