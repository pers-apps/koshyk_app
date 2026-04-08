import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/db/database.dart';
import '../../../core/utils/money.dart';
import '../data/expenses_providers.dart';
import '../../participants/data/participants_providers.dart';
import '../../categories/data/categories_providers.dart';

class ExpensesScreen extends ConsumerWidget {
  final int groupId;
  const ExpensesScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final asyncExpenses = ref.watch(expensesStreamProvider(groupId));
    final asyncParticipants = ref.watch(participantsStreamProvider(groupId));
    final asyncCategories = ref.watch(categoriesStreamProvider(groupId));

    final participants = asyncParticipants.maybeWhen(
      data: (list) => {for (final p in list) p.id: p.name},
      orElse: () => <int, String>{},
    );
    final categories = asyncCategories.maybeWhen(
      data: (list) => {for (final c in list) c.id: c.name},
      orElse: () => <int, String>{},
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.expenses)),
      body: asyncExpenses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text(l.noExpenses));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (ctx, i) => _ExpenseTile(
              expense: list[i],
              groupId: groupId,
              participants: participants,
              categories: categories,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/group/$groupId/expenses/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ExpenseTile extends ConsumerWidget {
  final Expense expense;
  final int groupId;
  final Map<int, String> participants;
  final Map<int, String> categories;

  const _ExpenseTile({
    required this.expense,
    required this.groupId,
    required this.participants,
    required this.categories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final payer = participants[expense.payerId] ?? '?';
    final catName = expense.categoryId != null
        ? categories[expense.categoryId]
        : null;
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
        leading: const Icon(Icons.receipt),
        title: Text(
          '${formatMoney(expense.amountKop)} — $payer',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text([
          dateStr,
          if (catName != null) catName,
          if (expense.comment.isNotEmpty) expense.comment,
        ].join(' · ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            context.push('/group/$groupId/expenses/${expense.id}/edit'),
      ),
    );
  }
}
