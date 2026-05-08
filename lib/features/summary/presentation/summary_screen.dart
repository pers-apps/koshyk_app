import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/pastel_colors.dart';
import '../data/summary_provider.dart';
import '../domain/calculation_engine.dart';
import '../../participants/data/participants_providers.dart';
import '../../groups/data/groups_providers.dart';
import '../../expenses/data/expenses_providers.dart';
import '../../categories/data/categories_providers.dart';


class SummaryScreen extends ConsumerStatefulWidget {
  final int groupId;
  const SummaryScreen({super.key, required this.groupId});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  final _screenshotKey = GlobalKey();
  int _touchedPieIndex = -1;
  bool _sharing = false;

  Future<void> _shareScreenshot(AppLocalizations l) async {
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
      final file = File('${dir.path}/koshyk_summary.png');
      await file.writeAsBytes(pngBytes);
      if (mounted) {
        await Share.shareXFiles([XFile(file.path)], subject: l.shareTitle);
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final summaryAsync = ref.watch(summaryProvider(widget.groupId));
    final participantsAsync =
        ref.watch(participantsStreamProvider(widget.groupId));
    final groupAsync = ref.watch(groupStreamByIdProvider(widget.groupId));
    final asyncExpenses = ref.watch(expensesStreamProvider(widget.groupId));
    final asyncCategories =
        ref.watch(categoriesStreamProvider(widget.groupId));

    final currency = groupAsync.maybeWhen(
      data: (g) => g?.currencySymbol ?? '₴',
      orElse: () => '₴',
    );
    final roundAmounts = groupAsync.maybeWhen(
      data: (g) => g?.roundAmounts ?? true,
      orElse: () => true,
    );
    final groupName = groupAsync.maybeWhen(
      data: (g) => g?.name ?? '',
      orElse: () => '',
    );

    // Participants map id → name
    final participantNames = participantsAsync.maybeWhen(
      data: (list) => {for (final p in list) p.id: p.name},
      orElse: () => <int, String>{},
    );

    // Deterministic pastel colour per participant (canonical shared palette)
    final participantColors =
        buildParticipantColors(participantNames.entries.toList());

    final categoryMap = asyncCategories.maybeWhen(
      data: (list) => {for (final c in list) c.id: c.name},
      orElse: () => <int, String>{},
    );
    final categoryColorMap = asyncCategories.maybeWhen(
      data: (list) => {for (final c in list) c.id: Color(c.color)},
      orElse: () => <int, Color>{},
    );

    // Pie data from expenses
    final catTotals = <int?, int>{};
    asyncExpenses.whenData((expenses) {
      for (final e in expenses) {
        catTotals[e.categoryId] =
            (catTotals[e.categoryId] ?? 0) + e.amountKop;
      }
    });
    final totalKop = catTotals.values.fold<int>(0, (s, v) => s + v);

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
            Flexible(child: Text(groupName.isNotEmpty ? '$groupName — ${l.summary}' : l.summary)),
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
            onPressed: _sharing ? null : () => _shareScreenshot(l),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 1, groupId: widget.groupId),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (summary) {
          final sortedSettlements = [...summary.settlements]
            ..sort((a, b) {
              final nameA = participantNames[a.fromId] ?? '';
              final nameB = participantNames[b.fromId] ?? '';
              return nameA.compareTo(nameB);
            });

          final hasExpenses = asyncExpenses.maybeWhen(data: (list) => list.isNotEmpty, orElse: () => true);
          if (!hasExpenses) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📊', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 16),
                    Text(
                      l.noExpenses,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/group/${widget.groupId}/expenses/new'),
                      icon: const Icon(Icons.add),
                      label: Text(l.addExpense),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: RepaintBoundary(
              key: _screenshotKey,
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset('assets/logo.png', width: 24, height: 24),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          groupName.isNotEmpty ? '$groupName — ${l.summary}' : l.summary,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                if (summary.balanceWarning)
                  Card(
                    color: Colors.orange.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(l.balanceWarning,
                          style:
                              const TextStyle(color: Colors.deepOrange)),
                    ),
                  ),

                // ── Totals card ──────────────────────────────────────────
                _SummaryCard(
                  l: l,
                  totalShared: summary.totalShared,
                  equalShare: summary.equalShare,
                  currency: currency,
                  roundAmounts: roundAmounts,
                ),
                const SizedBox(height: 20),

                // ── Who owes whom — FIRST ────────────────────────────────
                _SectionHeader(
                  label: l.whoOwesWhom,
                  stripeColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                ...sortedSettlements.map((p) => _PaymentTile(
                        payment: p,
                        participantNames: participantNames,
                        participantColors: participantColors,
                        currency: currency,
                        l: l,
                        roundAmounts: roundAmounts,
                      )),

                // ── Pie chart — AFTER who-owes-whom ─────────────────────
                if (catTotals.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionHeader(
                    label: l.spendingByCategory,
                    stripeColor: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    if (!event
                                            .isInterestedForInteractions ||
                                        response == null ||
                                        response.touchedSection == null) {
                                      _touchedPieIndex = -1;
                                      return;
                                    }
                                    _touchedPieIndex = response
                                        .touchedSection!
                                        .touchedSectionIndex;
                                  });
                                },
                              ),
                              sections: catTotals.entries
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final idx = entry.key;
                                final catId = entry.value.key;
                                final amount = entry.value.value;
                                final pct = totalKop > 0
                                    ? (amount / totalKop * 100)
                                    : 0.0;
                                final isTouched = idx == _touchedPieIndex;
                                final sectionColor = catId != null
                                    ? (categoryColorMap[catId] ??
                                        Colors.grey)
                                    : Colors.grey;
                                // Show % + amount directly on the sector
                                final amtStr = formatMoney(amount,
                                    symbol: currency, round: roundAmounts);
                                return PieChartSectionData(
                                  color: sectionColor,
                                  value: amount.toDouble(),
                                  title: '${pct.toStringAsFixed(0)}%\n$amtStr',
                                  titleStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  radius: isTouched ? 88 : 76,
                                  titlePositionPercentageOffset: 0.62,
                                );
                              }).toList(),
                            ),
                          ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Legend side-by-side — name only, no repeated amount
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: catTotals.entries
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                              final catId = entry.value.key;
                              final catName = catId != null
                                  ? (categoryMap[catId] ?? '?')
                                  : '?';
                              final catColor = catId != null
                                  ? (categoryColorMap[catId] ?? Colors.grey)
                                  : Colors.grey;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: catColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        catName,
                                        style:
                                            const TextStyle(fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ],
                ],
              ),
            ),
          ),
        );
        },
      ),
      ),
    );
  }
}

// ── Section header with top color stripe (Variant C) ─────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color stripeColor;
  const _SectionHeader({required this.label, required this.stripeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          top: BorderSide(color: stripeColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

// ── Summary totals card ───────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final AppLocalizations l;
  final double totalShared;
  final double equalShare;
  final String currency;
  final bool roundAmounts;
  const _SummaryCard({
    required this.l,
    required this.totalShared,
    required this.equalShare,
    required this.currency,
    required this.roundAmounts,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Row(
                label: l.totalShared,
                value: formatMoney(toKopiykas(totalShared),
                    symbol: currency, round: roundAmounts)),
            _Row(
                label: l.equalShare,
                value: formatMoney(toKopiykas(equalShare),
                    symbol: currency, round: roundAmounts)),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── Payment tile — pastel accent, bigger amount, sorted alphabetically ────────

class _PaymentTile extends StatelessWidget {
  final Payment payment;
  final Map<int, String> participantNames;
  final Map<int, Color> participantColors;
  final String currency;
  final AppLocalizations l;
  final bool roundAmounts;

  const _PaymentTile({
    required this.payment,
    required this.participantNames,
    required this.participantColors,
    required this.currency,
    required this.l,
    required this.roundAmounts,
  });

  @override
  Widget build(BuildContext context) {
    final from = participantNames[payment.fromId] ?? '?';
    final to = participantNames[payment.toId] ?? '?';
    final accentColor =
        participantColors[payment.fromId] ?? const Color(0xFF90CAF9);
    final amountStr = formatMoney(
      toKopiykas(payment.amount),
      symbol: currency,
      round: roundAmounts,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ),
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Debtor avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: accentColor.withValues(alpha: 0.25),
              child: Text(
                from.isNotEmpty ? from[0].toUpperCase() : '?',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Names + label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        from,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.arrow_forward_rounded, size: 22),
                      ),
                      Text(
                        to,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    l.pays, // "борг" / "debt"
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            // Amount — bigger font, neutral color (not red)
            Text(
              amountStr,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
