import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/latlng_point.dart' as model;
import '../../core/providers.dart';
import '../plan/presentation/plan_controller.dart';

class SearchPage extends HookConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final loading = useState(false);
    final results = useState<List<_ResultItem>>([]);

    Future<void> doSearch() async {
      final q = controller.text.trim();
      if (q.isEmpty) return;
      loading.value = true;
      try {
        final repo = ref.read(placesRepositoryProvider);
        final planAsync = ref.read(planControllerProvider);
        model.LatLngPoint? near;
        if (planAsync.hasValue && planAsync.value!.currentPlan.nodes.isNotEmpty) {
          near = planAsync.value!.currentPlan.nodes.last.point;
        }
        final list = await repo.searchText(q, near: near);
        results.value = list
            .map((e) => _ResultItem(name: e.name, address: e.address, point: e.location))
            .toList();
      } finally {
        if (context.mounted) loading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索地点'),
        actions: [
          IconButton(
            tooltip: '关闭',
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: '输入关键字，例如 "美食"、"酒店"、"博物馆"',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => doSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: loading.value ? null : doSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('搜索'),
                ),
              ],
            ),
          ),
          if (loading.value) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: results.value.isEmpty
                ? const Center(child: Text('输入关键字开始搜索'))
                : ListView.separated(
                    itemCount: results.value.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final it = results.value[i];
                      return ListTile(
                        leading: const Icon(Icons.place_outlined),
                        title: Text(it.name),
                        subtitle: Text(it.address ?? '${it.point.lat}, ${it.point.lng}'),
                        trailing: TextButton.icon(
                          onPressed: () async {
                            await ref.read(planControllerProvider.notifier).addNodeAt(
                                  it.point,
                                  title: it.name,
                                );
                            if (context.mounted) context.pop();
                          },
                          icon: const Icon(Icons.add_location_alt),
                          label: const Text('加入计划'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResultItem {
  final String name;
  final String? address;
  final model.LatLngPoint point;
  const _ResultItem({required this.name, required this.point, this.address});
}
