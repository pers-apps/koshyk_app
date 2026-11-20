import 'package:drift/drift.dart';
import '../../../core/db/database.dart';
import '../../../core/db/tables.dart';

part 'expenses_dao.g.dart';

@DriftAccessor(tables: [Expenses, ExpenseParticipants])
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

  Future<int> countByGroup(int groupId) async {
    final result = await (select(expenses)
          ..where((t) => t.groupId.equals(groupId)))
        .get();
    return result.length;
  }

  Future<int> insertExpense(ExpensesCompanion entry) =>
      into(expenses).insert(entry);

  Future<void> updateExpense(Expense entry) =>
      update(expenses).replace(entry);

  Future<int> deleteExpense(int id) =>
      (delete(expenses)..where((t) => t.id.equals(id))).go();

  Future<bool> participantHasExpenses(int participantId) async {
    final result = await (select(expenses)
          ..where((t) => t.payerId.equals(participantId))
          ..limit(1))
        .get();
    return result.isNotEmpty;
  }

  Future<void> nullifyCategoryExpenses(int categoryId) =>
      (update(expenses)..where((t) => t.categoryId.equals(categoryId)))
          .write(const ExpensesCompanion(categoryId: Value(null)));

  /// Explicit receiver ids for [expenseId]. An empty list means "no explicit
  /// selection was ever saved" — callers should treat that as every active
  /// participant in the group, which preserves pre-#141 expenses without a
  /// data migration.
  Future<List<int>> getReceiverIds(int expenseId) async {
    final rows = await (select(expenseParticipants)
          ..where((t) => t.expenseId.equals(expenseId)))
        .get();
    return rows.map((r) => r.participantId).toList();
  }

  /// Replaces the receiver set for [expenseId] with exactly [participantIds].
  /// Called with every active participant for "Equally — everyone" too, so
  /// the stored rows always reflect what was actually selected at save time.
  Future<void> setReceivers(int expenseId, List<int> participantIds) async {
    await transaction(() async {
      await (delete(expenseParticipants)
            ..where((t) => t.expenseId.equals(expenseId)))
          .go();
      for (final participantId in participantIds) {
        await into(expenseParticipants).insert(
          ExpenseParticipantsCompanion.insert(
            expenseId: expenseId,
            participantId: participantId,
          ),
        );
      }
    });
  }

  /// All explicit receiver sets for a group's expenses, keyed by expenseId —
  /// for feeding [calculateSummary] without one query per expense. An
  /// expense absent from the result has no explicit rows (= "everyone").
  Future<Map<int, List<int>>> getReceiversByGroup(int groupId) async {
    final query = select(expenseParticipants).join([
      innerJoin(
          expenses, expenses.id.equalsExp(expenseParticipants.expenseId)),
    ])
      ..where(expenses.groupId.equals(groupId));
    return _groupReceiverRows(await query.get());
  }

  /// Live version of [getReceiversByGroup] for the Expenses list split hint
  /// (REMARKS #149). Watching the join re-emits whenever expenses or their
  /// receiver rows change, so a hint appears as soon as a split is saved.
  Stream<Map<int, List<int>>> watchReceiversByGroup(int groupId) {
    final query = select(expenseParticipants).join([
      innerJoin(
          expenses, expenses.id.equalsExp(expenseParticipants.expenseId)),
    ])
      ..where(expenses.groupId.equals(groupId));
    return query.watch().map(_groupReceiverRows);
  }

  Map<int, List<int>> _groupReceiverRows(List<TypedResult> rows) {
    final result = <int, List<int>>{};
    for (final row in rows) {
      final ep = row.readTable(expenseParticipants);
      result.putIfAbsent(ep.expenseId, () => []).add(ep.participantId);
    }
    return result;
  }
}
