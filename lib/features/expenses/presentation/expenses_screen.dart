import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/db/database.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/pastel_colors.dart';
import '../data/expenses_providers.dart';
import '../../participants/data/participants_providers.dart';
import '../../categories/data/categories_providers.dart';
import '../../groups/data/groups_providers.dart';

class ExpensesScreen extends ConsumerWidget {
  final int groupId;
  const ExpensesScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final asyncExpenses = ref.watch(expensesStreamProvider(groupId));
    final asyncParticipants = ref.watch(participantsStreamProvider(groupId));
    final asyncCategories = ref.watch(categoriesStreamProvider(groupId));
    final groupAsync = ref.watch(groupStreamByIdProvider(groupId));

    final participants = asyncParticipants.maybeWhen(
      data: (list) => {for (final p in list) p.id: p.name},
      orElse: () => <int, String>{},
    );
    final participantColors = asyncParticipants.maybeWhen(
      data: (list) => buildParticipantColors(
          list.map((p) => MapEntry(p.id, p.name)).toList()),
      orElse: () => <int, Color>{},
    );
    final categoryNames = asyncCategories.maybeWhen(
      data: (list) => {for (final c in list) c.id: c.name},
      orElse: () => <int, String>{},
    );
    final categoryIcons = asyncCategories.maybeWhen(
      data: (list) => {for (final c in list) c.id: c.icon},
      orElse: () => <int, String>{},
    );
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

    // Total expenses for this group
    final totalKop = asyncExpenses.maybeWhen(
      data: (list) => list.fold<int>(0, (s, e) => s + e.amountKop),
      orElse: () => 0,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) { if (context.mounted) context.go('/'); },
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/logo.png', width: 28, height: 28),
            ),
            const SizedBox(width: 8),
            Flexible(child: Text(groupName.isNotEmpty ? '$groupName — ${l.expenses}' : l.expenses)),
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
            itemBuilder: (_) => [
              PopupMenuItem(value: 'participants', child: Text(l.participants)),
              PopupMenuItem(value: 'categories', child: Text(l.categories)),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'edit', child: Text(l.editGroup)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Total expenses card
          _TotalCard(
            totalKop: totalKop,
            currency: currency,
            roundAmounts: roundAmounts,
            l: l,
          ),
          // Expenses list
          Expanded(
            child: asyncExpenses.when(
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
                          const Text('🧾', style: TextStyle(fontSize: 56)),
                          const SizedBox(height: 16),
                          Text(
                            l.noExpensesHint,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.75), fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (ctx, i) => _ExpenseTile(
                    expense: list[i],
                    groupId: groupId,
                    participants: participants,
                    participantColors: participantColors,
                    categoryNames: categoryNames,
                    categoryIcons: categoryIcons,
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
        onTap: () => context.push('/group/$groupId/expenses/new'),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 0, groupId: groupId),
      ),
    );
  }
}

// ── Total expenses card ───────────────────────────────────────────────────────

class _TotalCard extends StatelessWidget {
  final int totalKop;
  final String currency;
  final bool roundAmounts;
  final AppLocalizations l;

  const _TotalCard({
    required this.totalKop,
    required this.currency,
    required this.roundAmounts,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: cs.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l.totalExpenses,
            style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6)),
          ),
          Text(
            formatMoney(totalKop, symbol: currency, round: roundAmounts),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
        ],
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

// ── Expense tile ──────────────────────────────────────────────────────────────

class _ExpenseTile extends ConsumerWidget {
  final Expense expense;
  final int groupId;
  final Map<int, String> participants;
  final Map<int, Color> participantColors;
  final Map<int, String> categoryNames;
  final Map<int, String> categoryIcons;
  final bool roundAmounts;
  final String currency;

  const _ExpenseTile({
    required this.expense,
    required this.groupId,
    required this.participants,
    required this.participantColors,
    required this.categoryNames,
    required this.categoryIcons,
    required this.roundAmounts,
    required this.currency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final payer = participants[expense.payerId] ?? '?';
    final catIcon = expense.categoryId != null
        ? (categoryIcons[expense.categoryId] ?? '🏷️')
        : '🏷️';
    final dateStr = DateFormat('dd.MM.yyyy').format(expense.date);

    return Dismissible(
      key: Key('expense_${expense.id}'),
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
          builder: (_) => AlertDialog(
            title: Text(l.delete),
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
        return result == true;
      },
      onDismissed: (_) async {
        await ref.read(expensesDaoProvider).deleteExpense(expense.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.deleted)),
          );
        }
      },
      child: ListTile(
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor:
                  (participantColors[expense.payerId] ?? kPastelColors[0]),
              child: Text(catIcon, style: const TextStyle(fontSize: 20)),
            ),
          ],
        ),
        title: Text(
          expense.title.isNotEmpty
              ? expense.title
              : formatMoney(expense.amountKop, symbol: currency, round: roundAmounts),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text([
          formatMoney(expense.amountKop, symbol: currency, round: roundAmounts),
          payer,
          dateStr,
          if (expense.comment.isNotEmpty) expense.comment,
        ].join(' · ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            context.push('/group/$groupId/expenses/${expense.id}/edit'),
      ),
    );
  }
}
