import 'dart:math';
import '../../../core/db/database.dart';

class Balance {
  final int participantId;
  double value; // in UAH (double for calculation)
  Balance(this.participantId, this.value);
}

class Payment {
  final int fromId;
  final int toId;
  final double amount; // UAH, 2dp
  const Payment({
    required this.fromId,
    required this.toId,
    required this.amount,
  });
}

class ParticipantSummary {
  final int participantId;
  final double amountPaid;
  final double equalShare;
  final double rawBalance;
  final double transferNet;
  final double finalBalance;
  const ParticipantSummary({
    required this.participantId,
    required this.amountPaid,
    required this.equalShare,
    required this.rawBalance,
    required this.transferNet,
    required this.finalBalance,
  });
}

class GroupSummary {
  final double totalShared;
  final double equalShare;
  final List<ParticipantSummary> participants;
  final List<Payment> settlements;
  final bool balanceWarning;
  const GroupSummary({
    required this.totalShared,
    required this.equalShare,
    required this.participants,
    required this.settlements,
    required this.balanceWarning,
  });
}

double _round2(double v) => (v * 100).round() / 100.0;

GroupSummary calculateSummary({
  required List<Participant> participants,
  required List<Expense> expenses,
  required List<DirectSettlement> directSettlements,
}) {
  if (participants.isEmpty) {
    return const GroupSummary(
      totalShared: 0,
      equalShare: 0,
      participants: [],
      settlements: [],
      balanceWarning: false,
    );
  }

  final n = participants.length;

  // Total shared expenses in UAH
  final totalShared = _round2(
    expenses.fold<double>(0, (s, e) => s + e.amountKop / 100.0),
  );

  // Equal share per person
  final equalShare = n > 0 ? _round2(totalShared / n) : 0.0;

  // Amount paid per participant
  final paid = <int, double>{for (final p in participants) p.id: 0.0};
  for (final e in expenses) {
    paid[e.payerId] = (paid[e.payerId] ?? 0) + e.amountKop / 100.0;
  }

  // Transfer net per participant: received - sent
  final transferNet = <int, double>{for (final p in participants) p.id: 0.0};
  for (final s in directSettlements) {
    transferNet[s.fromParticipantId] =
        (transferNet[s.fromParticipantId] ?? 0) - s.amountKop / 100.0;
    transferNet[s.toParticipantId] =
        (transferNet[s.toParticipantId] ?? 0) + s.amountKop / 100.0;
  }

  // Build per-participant summaries
  final summaries = participants.map((p) {
    final ap = _round2(paid[p.id] ?? 0);
    final raw = _round2(ap - equalShare);
    final tn = _round2(transferNet[p.id] ?? 0);
    final fb = _round2(raw + tn);
    return ParticipantSummary(
      participantId: p.id,
      amountPaid: ap,
      equalShare: equalShare,
      rawBalance: raw,
      transferNet: tn,
      finalBalance: fb,
    );
  }).toList();

  // Minimise settlements using greedy cascade
  final balances = summaries
      .map((s) => Balance(s.participantId, s.finalBalance))
      .toList();
  final payments = _minimiseSettlements(balances);

  // Check balance sum
  final balanceSum =
      summaries.fold<double>(0, (s, p) => s + p.finalBalance).abs();
  final balanceWarning = balanceSum > 0.02;

  return GroupSummary(
    totalShared: totalShared,
    equalShare: equalShare,
    participants: summaries,
    settlements: payments,
    balanceWarning: balanceWarning,
  );
}

List<Payment> _minimiseSettlements(List<Balance> balances) {
  final debtors = balances
      .where((b) => b.value < -0.005)
      .map((b) => Balance(b.participantId, b.value))
      .toList()
    ..sort((a, b) => a.value.compareTo(b.value));

  final creditors = balances
      .where((b) => b.value > 0.005)
      .map((b) => Balance(b.participantId, b.value))
      .toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final payments = <Payment>[];
  int di = 0, ci = 0;

  while (di < debtors.length && ci < creditors.length) {
    final amount = min(-debtors[di].value, creditors[ci].value);
    final rounded = _round2(amount);
    if (rounded > 0) {
      payments.add(Payment(
        fromId: debtors[di].participantId,
        toId: creditors[ci].participantId,
        amount: rounded,
      ));
    }
    debtors[di].value += amount;
    creditors[ci].value -= amount;
    if (debtors[di].value.abs() < 0.01) di++;
    if (creditors[ci].value < 0.01) ci++;
  }

  return payments;
}
