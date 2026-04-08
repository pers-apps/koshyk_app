import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/money.dart';
import '../../../core/db/providers.dart';
import '../data/summary_provider.dart';
import '../domain/calculation_engine.dart';
import '../../participants/data/participants_providers.dart';
import '../../groups/data/groups_providers.dart';
import '../../export/export_service.dart';

class SummaryScreen extends ConsumerWidget {
  final int groupId;
  const SummaryScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final summaryAsync = ref.watch(summaryProvider(groupId));
    final participantsAsync = ref.watch(participantsStreamProvider(groupId));
    final groupAsync = ref.watch(groupByIdProvider(groupId));

    final currency = groupAsync.maybeWhen(
      data: (g) => g?.currencySymbol ?? '₴',
      orElse: () => '₴',
    );
    final participants = participantsAsync.maybeWhen(
      data: (list) => {for (final p in list) p.id: p.name},
      orElse: () => <int, String>{},
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l.summary),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: l.export,
            onPressed: () async {
              final db = ref.read(databaseProvider);
              final service = ExportService(db);
              if (context.mounted) {
                await service.exportCsv(context, groupId);
              }
            },
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (summary) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (summary.balanceWarning)
              Card(
                color: Colors.orange.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(l.balanceWarning,
                      style: const TextStyle(color: Colors.deepOrange)),
                ),
              ),
            _SummaryCard(
              l: l,
              totalShared: summary.totalShared,
              equalShare: summary.equalShare,
              currency: currency,
            ),
            const SizedBox(height: 16),
            Text(l.participants,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...summary.participants.map((ps) => _ParticipantRow(
                  summary: ps,
                  name: participants[ps.participantId] ?? '?',
                  currency: currency,
                  l: l,
                )),
            const SizedBox(height: 16),
            Text(l.settlementInstructions,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (summary.settlements.isEmpty)
              Text(l.nothingToSettle)
            else
              ...summary.settlements.map((p) => _PaymentTile(
                    payment: p,
                    participants: participants,
                    currency: currency,
                    l: l,
                  )),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final AppLocalizations l;
  final double totalShared;
  final double equalShare;
  final String currency;
  const _SummaryCard(
      {required this.l,
      required this.totalShared,
      required this.equalShare,
      required this.currency});

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
                value: formatMoney(toKopiykas(totalShared), symbol: currency)),
            _Row(
                label: l.equalShare,
                value: formatMoney(toKopiykas(equalShare), symbol: currency)),
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

class _ParticipantRow extends StatelessWidget {
  final ParticipantSummary summary;
  final String name;
  final String currency;
  final AppLocalizations l;
  const _ParticipantRow(
      {required this.summary,
      required this.name,
      required this.currency,
      required this.l});

  String _fmt(double v) => formatMoney(toKopiykas(v), symbol: currency);

  @override
  Widget build(BuildContext context) {
    final finalBalance = summary.finalBalance;
    final color = finalBalance > 0.005
        ? Colors.green
        : finalBalance < -0.005
            ? Colors.red
            : null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            _Row(label: l.amountPaid, value: _fmt(summary.amountPaid)),
            _Row(label: l.equalShare, value: _fmt(summary.equalShare)),
            _Row(label: l.rawBalance, value: _fmt(summary.rawBalance)),
            _Row(label: l.transferNet, value: _fmt(summary.transferNet)),
            const Divider(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.finalBalance,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(_fmt(finalBalance),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final Payment payment;
  final Map<int, String> participants;
  final String currency;
  final AppLocalizations l;
  const _PaymentTile(
      {required this.payment,
      required this.participants,
      required this.currency,
      required this.l});

  @override
  Widget build(BuildContext context) {
    final from = participants[payment.fromId] ?? '?';
    final to = participants[payment.toId] ?? '?';
    return ListTile(
      leading: const Icon(Icons.arrow_forward),
      title: Text('$from ${l.pays} $to'),
      trailing: Text(
        formatMoney(toKopiykas(payment.amount), symbol: currency),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
