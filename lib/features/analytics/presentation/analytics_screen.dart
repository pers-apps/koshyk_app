import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/money.dart';
import '../../expenses/data/expenses_providers.dart';
import '../../participants/data/participants_providers.dart';
import '../../categories/data/categories_providers.dart';
import '../../groups/data/groups_providers.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  final int groupId;
  const AnalyticsScreen({super.key, required this.groupId});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final asyncExpenses = ref.watch(expensesStreamProvider(widget.groupId));
    final asyncParticipants =
        ref.watch(participantsStreamProvider(widget.groupId));
    final asyncCategories =
        ref.watch(categoriesStreamProvider(widget.groupId));
    final groupAsync = ref.watch(groupByIdProvider(widget.groupId));

    final currency = groupAsync.maybeWhen(
      data: (g) => g?.currencySymbol ?? '₴',
      orElse: () => '₴',
    );
    final participantMap = asyncParticipants.maybeWhen(
      data: (list) => {for (final p in list) p.id: p.name},
      orElse: () => <int, String>{},
    );
    final categoryMap = asyncCategories.maybeWhen(
      data: (list) => {for (final c in list) c.id: c.name},
      orElse: () => <int, String>{},
    );

    final colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.red, Colors.teal, Colors.amber, Colors.indigo,
      Colors.pink, Colors.cyan,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.analytics)),
      body: asyncExpenses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (allExpenses) {
          // Apply date filter
          final expenses = allExpenses.where((e) {
            if (_fromDate != null && e.date.isBefore(_fromDate!)) return false;
            if (_toDate != null &&
                e.date.isAfter(_toDate!.add(const Duration(days: 1)))) {
              return false;
            }
            return true;
          }).toList();

          // --- Category pie data ---
          final catTotals = <int?, int>{};
          for (final e in expenses) {
            catTotals[e.categoryId] =
                (catTotals[e.categoryId] ?? 0) + e.amountKop;
          }
          final totalKop =
              catTotals.values.fold<int>(0, (s, v) => s + v);

          // --- Participant bar data ---
          final participantTotals = <int, int>{};
          for (final e in expenses) {
            participantTotals[e.payerId] =
                (participantTotals[e.payerId] ?? 0) + e.amountKop;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Date range filter
              _DateRangeFilter(
                l: l,
                fromDate: _fromDate,
                toDate: _toDate,
                onFromChanged: (d) => setState(() => _fromDate = d),
                onToChanged: (d) => setState(() => _toDate = d),
                onClear: () => setState(() {
                  _fromDate = null;
                  _toDate = null;
                }),
              ),
              const SizedBox(height: 16),

              // Pie chart: by category
              Text(l.byCategory,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (catTotals.isEmpty)
                Center(child: Text(l.noExpenses))
              else
                SizedBox(
                  height: 260,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedPieIndex = -1;
                                    return;
                                  }
                                  _touchedPieIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
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
                              final catName = catId != null
                                  ? categoryMap[catId] ?? l.noCategory
                                  : l.noCategory;
                              return PieChartSectionData(
                                color: colors[idx % colors.length],
                                value: amount.toDouble(),
                                title: isTouched
                                    ? '${pct.toStringAsFixed(1)}%\n$catName'
                                    : '',
                                radius: isTouched ? 70 : 60,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Legend
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: catTotals.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            final idx = entry.key;
                            final catId = entry.value.key;
                            final amount = entry.value.value;
                            final catName = catId != null
                                ? categoryMap[catId] ?? l.noCategory
                                : l.noCategory;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    color: colors[idx % colors.length],
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '$catName\n${formatMoney(amount, symbol: currency)}',
                                      style: const TextStyle(fontSize: 11),
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

              const SizedBox(height: 24),

              // Bar chart: by participant
              Text(l.byParticipant,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (participantTotals.isEmpty)
                Center(child: Text(l.noExpenses))
              else
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: participantTotals.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        final idx = entry.key;
                        final amount = entry.value.value;
                        return BarChartGroupData(
                          x: idx,
                          barRods: [
                            BarChartRodData(
                              toY: amount / 100.0,
                              color: colors[idx % colors.length],
                              width: 24,
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (val, meta) => Text(
                              val.toStringAsFixed(0),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              final idx = val.toInt();
                              final keys = participantTotals.keys.toList();
                              if (idx >= keys.length) return const SizedBox();
                              final pId = keys[idx];
                              final name = participantMap[pId] ?? '?';
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  name.length > 6
                                      ? name.substring(0, 6)
                                      : name,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: true),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DateRangeFilter extends StatelessWidget {
  final AppLocalizations l;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ValueChanged<DateTime?> onFromChanged;
  final ValueChanged<DateTime?> onToChanged;
  final VoidCallback onClear;

  const _DateRangeFilter({
    required this.l,
    required this.fromDate,
    required this.toDate,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onClear,
  });

  Future<void> _pick(BuildContext context, DateTime? initial,
      ValueChanged<DateTime?> onChange) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onChange(picked);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy');
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(
                fromDate == null ? l.from_date : fmt.format(fromDate!),
                style: const TextStyle(fontSize: 12)),
            onPressed: () => _pick(context, fromDate, onFromChanged),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(toDate == null ? l.to_date : fmt.format(toDate!),
                style: const TextStyle(fontSize: 12)),
            onPressed: () => _pick(context, toDate, onToChanged),
          ),
        ),
        if (fromDate != null || toDate != null)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: onClear,
            tooltip: l.allTime,
          ),
      ],
    );
  }
}
