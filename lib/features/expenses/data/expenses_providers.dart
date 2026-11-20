import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/providers.dart';
import '../../../core/db/database.dart';
import 'expenses_dao.dart';

final expensesDaoProvider = Provider<ExpensesDao>((ref) {
  return ref.watch(databaseProvider).expensesDao;
});

final expensesStreamProvider =
    StreamProvider.family<List<Expense>, int>((ref, groupId) {
  return ref.watch(expensesDaoProvider).watchByGroup(groupId);
});

/// Explicit receiver ids per expense for a group (REMARKS #149 split hint).
/// An expense missing from the map has no explicit split (= everyone).
final expenseReceiversStreamProvider =
    StreamProvider.family<Map<int, List<int>>, int>((ref, groupId) {
  return ref.watch(expensesDaoProvider).watchReceiversByGroup(groupId);
});
