import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/utils/snack_bars.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/db/database.dart';
import '../../../core/utils/money.dart';
import '../data/settlements_providers.dart';
import '../../participants/data/participants_providers.dart';
import '../../categories/data/categories_providers.dart';
import '../../groups/data/groups_providers.dart';
import '../../../core/widgets/group_avatar.dart';

class SettlementsScreen extends ConsumerWidget {
  final int groupId;
  const SettlementsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final asyncList = ref.watch(settlementsStreamProvider(groupId));
    final asyncParticipants = ref.watch(participantsStreamProvider(groupId));
    final asyncCategories = ref.watch(categoriesStreamProvider(groupId));
    final groupAsync = ref.watch(groupStreamByIdProvider(groupId));

    final participants = asyncParticipants.maybeWhen(
      data: (list) => {for (final p in list) p.id: p.name},
      orElse: () => <int, String>{},
    );
    final categories = asyncCategories.maybeWhen(
      data: (list) => {for (final c in list) c.id: c.name},
      orElse: () => <int, String>{},
    );
    final group = groupAsync.maybeWhen(data: (g) => g, orElse: () => null);
    final groupName = groupAsync.maybeWhen(
      data: (g) => g?.name ?? '',
      orElse: () => '',
    );
    final roundAmounts = groupAsync.maybeWhen(
      data: (g) => g?.roundAmounts ?? true,
      orElse: () => true,
    );
    final currency = groupAsync.maybeWhen(
      data: (g) => g?.currencySymbol ?? '₴',
      orElse: () => '₴',
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        if (context.mounted) context.go('/');
      },
      child: GradientScaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
            tooltip: 'Groups',
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GroupAvatar(
                name: groupName,
                iconEmoji: group?.iconEmoji,
                iconImage: group?.iconImage,
                size: 28,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  groupName.isNotEmpty
                      ? '$groupName — ${l.settlements}'
                      : l.settlements,
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (val) {
                switch (val) {
                  case 'participants':
                    context.push('/group/$groupId/participants');
                  case 'categories':
                    context.push('/group/$groupId/categories');
                  case 'edit':
                    context.push('/group/$groupId/edit');
                }
              },
              itemBuilder:
                  (_) => [
                    PopupMenuItem(
                      value: 'participants',
                      child: Text(l.participants),
                    ),
                    PopupMenuItem(
                      value: 'categories',
                      child: Text(l.categories),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(value: 'edit', child: Text(l.editGroup)),
                  ],
            ),
          ],
        ),
        body: Column(
          children: [
            // List
            Expanded(
              child: asyncList.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🤝', style: const TextStyle(fontSize: 56)),
                            const SizedBox(height: 16),
                            Text(
                              l.noSettlementsHint,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.75),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder:
                        (ctx, i) => _SettlementTile(
                          settlement: list[i],
                          groupId: groupId,
                          participants: participants,
                          categories: categories,
                          roundAmounts: roundAmounts,
                          currency: currency,
                        ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: _GlowFab(
          onTap: () => context.push('/group/$groupId/settlements/new'),
        ),
        bottomNavigationBar: AppBottomNav(currentIndex: 2, groupId: groupId),
      ),
    );
  }
}

// ── Glow FAB ──────────────────────────────────────────────────────────────────

class _GlowFab extends StatelessWidget {
  final VoidCallback onTap;
  const _GlowFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 18,
            spreadRadius: 3,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onTap,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

// ── Settlement tile ───────────────────────────────────────────────────────────

class _SettlementTile extends ConsumerWidget {
  final DirectSettlement settlement;
  final int groupId;
  final Map<int, String> participants;
  final Map<int, String> categories;
  final bool roundAmounts;
  final String currency;

  const _SettlementTile({
    required this.settlement,
    required this.groupId,
    required this.participants,
    required this.categories,
    required this.roundAmounts,
    required this.currency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final from = participants[settlement.fromParticipantId] ?? '?';
    final to = participants[settlement.toParticipantId] ?? '?';
    final catName =
        settlement.categoryId != null
            ? categories[settlement.categoryId]
            : null;
    final dateStr = DateFormat('dd.MM.yyyy').format(settlement.date);

    return Dismissible(
      key: Key('settlement_${settlement.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final result = await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text(l.delete),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      l.delete,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        );
        return result == true;
      },
      onDismissed: (_) async {
        await ref.read(settlementsDaoProvider).deleteSettlement(settlement.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.deleted),
              duration: kActionSnackBarDuration,
            ),
          );
        }
      },
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.15),
          child: Icon(
            Icons.swap_horiz,
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(
          '$from → $to: ${formatMoney(settlement.amountKop, symbol: currency, round: roundAmounts)}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          [
            dateStr,
            if (catName != null) catName,
            if (settlement.comment.isNotEmpty) settlement.comment,
          ].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap:
            () => context.push(
              '/group/$groupId/settlements/${settlement.id}/edit',
            ),
      ),
    );
  }
}
