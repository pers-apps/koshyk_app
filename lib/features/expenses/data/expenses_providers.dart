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
