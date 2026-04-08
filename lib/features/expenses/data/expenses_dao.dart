import 'package:drift/drift.dart';
import '../../../core/db/database.dart';
import '../../../core/db/tables.dart';

part 'expenses_dao.g.dart';

@DriftAccessor(tables: [Expenses])
class ExpensesDao extends DatabaseAccessor<AppDatabase>
    with _$ExpensesDaoMixin {
  ExpensesDao(super.db);

  Stream<List<Expense>> watchByGroup(int groupId) =>
      (select(expenses)
            ..where((t) => t.groupId.equals(groupId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<List<Expense>> getByGroup(int groupId) =>
      (select(expenses)
            ..where((t) => t.groupId.equals(groupId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Future<List<Expense>> getByGroupAndDateRange(
      int groupId, DateTime? from, DateTime? to) {
    final query = select(expenses)
      ..where((t) {
        Expression<bool> cond = t.groupId.equals(groupId);
        if (from != null) cond = cond & t.date.isBiggerOrEqualValue(from);
        if (to != null) cond = cond & t.date.isSmallerOrEqualValue(to);
        return cond;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.get();
  }

  Future<int> insertExpense(ExpensesCompanion entry) =>
      into(expenses).insert(entry);

  Future<void> updateExpense(Expense entry) =>
      update(expenses).replace(entry);

  Future<int> deleteExpense(int id) =>
      (delete(expenses)..where((t) => t.id.equals(id))).go();

  Future<bool> participantHasExpenses(int participantId) async {
    final result = await (select(expenses)
          ..where((t) => t.payerId.equals(participantId)))
        .getSingleOrNull();
    return result != null;
  }

  Future<void> nullifyCategoryExpenses(int categoryId) =>
      (update(expenses)..where((t) => t.categoryId.equals(categoryId)))
          .write(const ExpensesCompanion(categoryId: Value(null)));
}
