import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../participants/data/participants_providers.dart';
import '../../expenses/data/expenses_providers.dart';
import '../../settlements/data/settlements_providers.dart';
import '../domain/calculation_engine.dart';

final summaryProvider =
    StreamProvider.family<GroupSummary, int>((ref, groupId) async* {
  final participantsAsync = ref.watch(participantsStreamProvider(groupId));
  final expensesAsync = ref.watch(expensesStreamProvider(groupId));
  final settlementsAsync = ref.watch(settlementsStreamProvider(groupId));

  if (participantsAsync.hasValue &&
      expensesAsync.hasValue &&
      settlementsAsync.hasValue) {
    final receivers =
        await ref.watch(expensesDaoProvider).getReceiversByGroup(groupId);
    yield calculateSummary(
      participants: participantsAsync.value!,
      expenses: expensesAsync.value!,
      directSettlements: settlementsAsync.value!,
      expenseReceivers: receivers,
    );
  }
});
