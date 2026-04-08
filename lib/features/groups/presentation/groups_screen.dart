import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../data/groups_providers.dart';
import '../../../core/utils/money.dart';
import '../../expenses/data/expenses_providers.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final groupsAsync = ref.watch(groupsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.appTitle)),
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (groups) {
          if (groups.isEmpty) {
            return Center(child: Text(l.noGroups));
          }
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (ctx, i) {
              final g = groups[i];
              return _GroupTile(groupId: g.id, name: g.name, currency: g.currencySymbol);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/group/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GroupTile extends ConsumerWidget {
  final int groupId;
  final String name;
  final String currency;
  const _GroupTile({required this.groupId, required this.name, required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final expensesAsync = ref.watch(expensesStreamProvider(groupId));

    final total = expensesAsync.maybeWhen(
      data: (list) => list.fold<int>(0, (s, e) => s + e.amountKop),
      orElse: () => 0,
    );

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.group)),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${l.totalExpenses}: ${formatMoney(total, symbol: currency)}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/group/$groupId'),
    );
  }
}
