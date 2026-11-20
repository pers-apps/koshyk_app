import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/utils/snack_bars.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/db/database.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/pastel_colors.dart';
import '../data/expenses_providers.dart';
import '../domain/split_hint.dart';
import 'split_hint_chip.dart';
import '../../participants/data/participants_providers.dart';
import '../../categories/data/categories_providers.dart';
import '../../export/export_providers.dart';
import '../../groups/data/groups_providers.dart';
import '../../../core/widgets/group_avatar.dart';
import '../../summary/data/summary_provider.dart';
import '../../summary/domain/calculation_engine.dart';
import '../../summary/presentation/summary_widgets.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  final int groupId;
  const ExpensesScreen({super.key, required this.groupId});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final _screenshotKey = GlobalKey();
  bool _sharing = false;

  Future<void> _shareLatestExpenses(AppLocalizations l) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final boundary = _screenshotKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/koshyk_latest_expenses.png');
      await file.writeAsBytes(pngBytes);
      if (mounted) {
        await Share.shareXFiles([XFile(file.path)],
            subject: l.latestExpensesShareTitle);
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupId = widget.groupId;
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
    // Who shares each partially split expense (REMARKS #149). Expenses
    // split among everyone have no entry, so they show no hint.
    final asyncReceivers = ref.watch(expenseReceiversStreamProvider(groupId));
    final splitHints = (asyncParticipants.hasValue && asyncReceivers.hasValue)
        ? splitHintsFor(asyncReceivers.value!, asyncParticipants.value!)
        : const <int, SplitHint>{};
    final categoryNames = asyncCategories.maybeWhen(
      data: (list) => {for (final c in list) c.id: c.name},
      orElse: () => <int, String>{},
    );
    final categoryIcons = asyncCategories.maybeWhen(
      data: (list) => {for (final c in list) c.id: c.icon},
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

    // Total expenses for this group
    final totalKop = asyncExpenses.maybeWhen(
      data: (list) => list.fold<int>(0, (s, e) => s + e.amountKop),
      orElse: () => 0,
    );
    final latestExpenses = asyncExpenses.maybeWhen(
      data: (list) => list.take(10).toList(),
      orElse: () => const <Expense>[],
    );
    // "Who owes whom" for the screenshot (REMARKS #148) — same provider as
    // the Summary screen, so the numbers always match.
    final sortedSettlements = ref.watch(summaryProvider(groupId)).maybeWhen(
          data: (summary) =>
              sortPaymentsByDebtor(summary.settlements, participants),
          orElse: () => const <Payment>[],
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
            GroupAvatar(
              name: groupName,
              iconEmoji: group?.iconEmoji,
              iconImage: group?.iconImage,
              size: 28,
            ),
            const SizedBox(width: 8),
            Flexible(child: Text(groupName.isNotEmpty ? '$groupName — ${l.expenses}' : l.expenses)),
          ],
        ),
        actions: [
          IconButton(
            icon: _sharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
            tooltip: l.shareTitle,
            onPressed: latestExpenses.isEmpty || _sharing
                ? null
                : () => _shareLatestExpenses(l),
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              switch (val) {
                case 'participants':
                  context.push('/group/$groupId/participants');
                case 'categories':
                  context.push('/group/$groupId/categories');
                case 'edit':
                  context.push('/group/$groupId/edit');
                case 'export':
                  ref.read(exportServiceProvider).exportJson(context, groupId);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'participants', child: Text(l.participants)),
              PopupMenuItem(value: 'categories', child: Text(l.categories)),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'edit', child: Text(l.editGroup)),
              PopupMenuItem(value: 'export', child: Text(l.export)),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
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
                        splitHint: splitHints[list[i].id],
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
          // Off-canvas capture target for the "latest 10" screenshot — laid out
          // and painted normally (so RepaintBoundary.toImage works), just
          // positioned far outside the visible viewport.
          Positioned(
            left: -5000,
            top: 0,
            child: RepaintBoundary(
              key: _screenshotKey,
              child: _LatestExpensesCapture(
                l: l,
                groupName: groupName,
                groupIconEmoji: group?.iconEmoji,
                groupIconImage: group?.iconImage,
                expenses: latestExpenses,
                settlements: sortedSettlements,
                participants: participants,
                participantColors: participantColors,
                splitHints: splitHints,
                categoryNames: categoryNames,
                categoryIcons: categoryIcons,
                roundAmounts: roundAmounts,
                currency: currency,
              ),
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

// ── Latest-expenses screenshot content ─────────────────────────────────────────

class _LatestExpensesCapture extends StatelessWidget {
  final AppLocalizations l;
  final String groupName;
  final String? groupIconEmoji;
  final String? groupIconImage;
  final List<Expense> expenses;
  final List<Payment> settlements;
  final Map<int, String> participants;
  final Map<int, Color> participantColors;
  final Map<int, SplitHint> splitHints;
  final Map<int, String> categoryNames;
  final Map<int, String> categoryIcons;
  final bool roundAmounts;
  final String currency;

  const _LatestExpensesCapture({
    required this.l,
    required this.groupName,
    this.groupIconEmoji,
    this.groupIconImage,
    required this.expenses,
    required this.settlements,
    required this.participants,
    required this.participantColors,
    required this.splitHints,
    required this.categoryNames,
    required this.categoryIcons,
    required this.roundAmounts,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('dd.MM.yyyy');

    return Material(
      color: cs.surface,
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(20),
        color: cs.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GroupAvatar(
                  name: groupName,
                  iconEmoji: groupIconEmoji,
                  iconImage: groupIconImage,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    groupName.isNotEmpty
                        ? '$groupName — ${l.latestExpensesHeading}'
                        : l.latestExpensesHeading,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final e in expenses) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        participantColors[e.payerId] ?? kPastelColors[0],
                    child: Text(
                      e.categoryId != null
                          ? (categoryIcons[e.categoryId] ?? '🏷️')
                          : '🏷️',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.title.isNotEmpty
                              ? e.title
                              : (e.categoryId != null
                                  ? (categoryNames[e.categoryId] ?? '')
                                  : ''),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          [
                            participants[e.payerId] ?? '?',
                            dateFmt.format(e.date),
                          ].join(' · '),
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        if (splitHints[e.id] != null)
                          SplitHintChip(
                            hint: splitHints[e.id]!,
                            participantNames: participants,
                            participantColors: participantColors,
                            l: l,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    formatMoney(e.amountKop,
                        symbol: currency, round: roundAmounts),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            // ── Who owes whom — same section as on Summary (REMARKS #148) ──
            const SizedBox(height: 8),
            SummarySectionHeader(
              label: l.whoOwesWhom,
              stripeColor: cs.primary,
            ),
            const SizedBox(height: 8),
            for (final p in settlements)
              PaymentTile(
                payment: p,
                participantNames: participants,
                participantColors: participantColors,
                currency: currency,
                l: l,
                roundAmounts: roundAmounts,
              ),
          ],
        ),
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
  final SplitHint? splitHint;
  final Map<int, String> categoryNames;
  final Map<int, String> categoryIcons;
  final bool roundAmounts;
  final String currency;

  const _ExpenseTile({
    required this.expense,
    required this.groupId,
    required this.participants,
    required this.participantColors,
    this.splitHint,
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
            SnackBar(
                content: Text(l.deleted),
                duration: kActionSnackBarDuration),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text([
              formatMoney(expense.amountKop,
                  symbol: currency, round: roundAmounts),
              payer,
              dateStr,
              if (expense.comment.isNotEmpty) expense.comment,
            ].join(' · ')),
            // Only for expenses split among part of the group (REMARKS #149).
            if (splitHint != null)
              SplitHintChip(
                hint: splitHint!,
                participantNames: participants,
                participantColors: participantColors,
                l: l,
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            context.push('/group/$groupId/expenses/${expense.id}/edit'),
      ),
    );
  }
}
