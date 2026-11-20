import '../../../core/db/database.dart';

/// Up to this many receivers are listed by name; more collapse to "N of M"
/// (REMARKS #149).
const int kSplitHintMaxNames = 3;

/// What the Expenses list shows under an expense that is split among only
/// part of the group (REMARKS #149). An expense split among everyone has no
/// hint at all, so the list stays clean and partial splits stand out.
class SplitHint {
  /// Receiver ids, in the group's participant order.
  final List<int> receiverIds;

  /// Size of the group the expense is measured against: every active
  /// participant, plus any receiver who has since been deactivated.
  final int groupSize;

  const SplitHint({required this.receiverIds, required this.groupSize});

  bool get showNames => receiverIds.length <= kSplitHintMaxNames;
}

/// Returns the hint for one expense, or null when it is split among everyone.
///
/// [explicitReceivers] are the stored receiver rows for the expense. Null or
/// empty means no explicit selection (pre-#141 expenses) = everyone. An
/// explicit set that covers every active participant also means everyone —
/// that's what the form saves for "Всі".
SplitHint? splitHintFor(
  List<int>? explicitReceivers,
  List<Participant> participants,
) {
  if (explicitReceivers == null || explicitReceivers.isEmpty) return null;
  final receiverSet = explicitReceivers.toSet();
  final activeIds = [
    for (final p in participants)
      if (p.isActive) p.id,
  ];
  if (activeIds.every(receiverSet.contains)) return null;

  final ordered = [
    for (final p in participants)
      if (receiverSet.contains(p.id)) p.id,
  ];
  // Receivers no longer in the participant list at all (shouldn't happen —
  // rows cascade on delete) are still counted, just not named.
  final known = ordered.toSet();
  ordered.addAll(receiverSet.where((id) => !known.contains(id)));

  final groupSize = {...activeIds, ...receiverSet}.length;
  return SplitHint(receiverIds: ordered, groupSize: groupSize);
}

/// Hints for every expense that has one, keyed by expense id.
Map<int, SplitHint> splitHintsFor(
  Map<int, List<int>> receiversByExpense,
  List<Participant> participants,
) {
  final result = <int, SplitHint>{};
  receiversByExpense.forEach((expenseId, receivers) {
    final hint = splitHintFor(receivers, participants);
    if (hint != null) result[expenseId] = hint;
  });
  return result;
}
