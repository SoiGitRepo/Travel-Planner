import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import 'plan_controller.dart';

class GroupManagerPage extends ConsumerWidget {
  const GroupManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(planRepositoryProvider);
    final groups = repo.getAllGroups();
    final currentId = repo.getCurrentGroupId();
    return Scaffold(
      appBar: AppBar(
        title: const Text('分组管理'),
        actions: [
          IconButton(
            tooltip: '创建分组',
            icon: const Icon(Icons.add),
            onPressed: () async {
              final controller = TextEditingController();
              final name = await showDialog<String?>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('创建新分组'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: '输入分组名称'),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('取消')),
                    TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('确定')),
                  ],
                ),
              );
              if (name != null && name.isNotEmpty) {
                await repo.createGroup(name);
                // 刷新页面
                // ignore: use_build_context_synchronously
                (context as Element).markNeedsBuild();
              }
            },
          )
        ],
      ),
      body: ListView.separated(
        itemCount: groups.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final g = groups[i];
          final isCurrent = g.id == currentId;
          return ListTile(
            leading: Icon(isCurrent ? Icons.check_circle : Icons.circle_outlined,
                color: isCurrent ? Colors.indigo : Colors.grey),
            title: Text(g.name),
            subtitle: Text('ID: ${g.id} · 共 ${g.plans.length} 天'),
            onTap: () async {
              await repo.setCurrentGroupId(g.id);
              // 使计划控制器重建加载新分组
              ref.invalidate(planControllerProvider);
              if (context.mounted) Navigator.pop(context);
            },
            trailing: Wrap(spacing: 8, children: [
              IconButton(
                tooltip: '重命名',
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final controller = TextEditingController(text: g.name);
                  final newName = await showDialog<String?>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('重命名分组'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(hintText: '输入新的分组名'),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('取消')),
                        TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('确定')),
                      ],
                    ),
                  );
                  if (newName != null && newName.isNotEmpty) {
                    await repo.renameGroup(g.id, newName);
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
              IconButton(
                tooltip: '删除',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('确认删除'),
                          content: Text('确定删除分组“${g.name}”吗？该操作不可恢复。'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除')),
                          ],
                        ),
                      ) ??
                      false;
                  if (!ok) return;
                  await repo.deleteGroup(g.id);
                  ref.invalidate(planControllerProvider);
                  (context as Element).markNeedsBuild();
                },
              ),
            ]),
          );
        },
      ),
    );
  }
}
