import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/utils/money.dart';
import '../domain/calculation_engine.dart';

/// Shared by the Summary screen and the Expenses screenshot (REMARKS #148),
/// so both show the "who owes whom" tiles identically.

/// Settlement payments sorted alphabetically by the debtor's name.
List<Payment> sortPaymentsByDebtor(
    List<Payment> payments, Map<int, String> participantNames) {
  return [...payments]
    ..sort((a, b) {
      final nameA = participantNames[a.fromId] ?? '';
      final nameB = participantNames[b.fromId] ?? '';
      return nameA.compareTo(nameB);
    });
}

// ── Section header with top color stripe (Variant C) ─────────────────────────

class SummarySectionHeader extends StatelessWidget {
  final String label;
  final Color stripeColor;
  const SummarySectionHeader({super.key, required this.label, required this.stripeColor});

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

// ── Payment tile — pastel accent, bigger amount, sorted alphabetically ────────

class PaymentTile extends StatelessWidget {
  final Payment payment;
  final Map<int, String> participantNames;
  final Map<int, Color> participantColors;
  final String currency;
  final AppLocalizations l;
  final bool roundAmounts;

  const PaymentTile({
    super.key,
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
