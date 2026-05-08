import '../../../core/widgets/gradient_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../data/groups_providers.dart';

class GroupDetailScreen extends ConsumerWidget {
  final int groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final group = await ref.read(groupsDaoProvider).getById(groupId);
    if (group == null || !context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.deleteGroup),
        content: Text(l.deleteGroupConfirm(group.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.delete,
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(groupsDaoProvider).deleteGroup(groupId);
      if (context.mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final groupAsync = ref.watch(groupByIdProvider(groupId));

    return groupAsync.when(
      loading: () => const GradientScaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => GradientScaffold(body: Center(child: Text('$e'))),
      data: (group) {
        if (group == null) {
          return const GradientScaffold(body: Center(child: Text('Not found')));
        }
        return GradientScaffold(
          appBar: AppBar(
            title: Text(group.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/group/$groupId/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          body: ListView(
            children: [
              _NavTile(
                icon: Icons.people,
                label: l.participants,
                onTap: () => context.push('/group/$groupId/participants'),
              ),
              _NavTile(
                icon: Icons.category,
                label: l.categories,
                onTap: () => context.push('/group/$groupId/categories'),
              ),
              _NavTile(
                icon: Icons.receipt_long,
                label: l.expenses,
                onTap: () => context.push('/group/$groupId/expenses'),
              ),
              _NavTile(
                icon: Icons.swap_horiz,
                label: l.settlements,
                onTap: () => context.push('/group/$groupId/settlements'),
              ),
              _NavTile(
                icon: Icons.summarize,
                label: l.summary,
                onTap: () => context.push('/group/$groupId/summary'),
              ),
              // Analytics removed — now integrated as pie chart in Summary
            ],
          ),
        );
      },
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
