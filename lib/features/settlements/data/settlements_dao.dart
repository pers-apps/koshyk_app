import 'package:drift/drift.dart';
import '../../../core/db/database.dart';
import '../../../core/db/tables.dart';

part 'settlements_dao.g.dart';

@DriftAccessor(tables: [DirectSettlements])
class SettlementsDao extends DatabaseAccessor<AppDatabase>
    with _$SettlementsDaoMixin {
  SettlementsDao(super.db);

  Stream<List<DirectSettlement>> watchByGroup(int groupId) =>
      (select(directSettlements)
            ..where((t) => t.groupId.equals(groupId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<List<DirectSettlement>> getByGroup(int groupId) =>
      (select(directSettlements)
            ..where((t) => t.groupId.equals(groupId)))
          .get();

  Future<List<DirectSettlement>> getByGroupAndDateRange(
      int groupId, DateTime? from, DateTime? to) {
    final query = select(directSettlements)
      ..where((t) {
        Expression<bool> cond = t.groupId.equals(groupId);
        if (from != null) cond = cond & t.date.isBiggerOrEqualValue(from);
        if (to != null) cond = cond & t.date.isSmallerOrEqualValue(to);
        return cond;
      });
    return query.get();
  }

  Future<int> countByGroup(int groupId) async {
    final result = await (select(directSettlements)
          ..where((t) => t.groupId.equals(groupId)))
        .get();
    return result.length;
  }

  Future<int> insertSettlement(DirectSettlementsCompanion entry) =>
      into(directSettlements).insert(entry);

  Future<void> updateSettlement(DirectSettlement entry) =>
      update(directSettlements).replace(entry);

  Future<int> deleteSettlement(int id) =>
      (delete(directSettlements)..where((t) => t.id.equals(id))).go();

  Future<bool> participantHasSettlements(int participantId) async {
    final result = await (select(directSettlements)
          ..where((t) =>
              t.fromParticipantId.equals(participantId) |
              t.toParticipantId.equals(participantId))
          ..limit(1))
        .getSingleOrNull();
    return result != null;
  }

  Future<void> nullifyCategorySettlements(int categoryId) =>
      (update(directSettlements)
            ..where((t) => t.categoryId.equals(categoryId)))
          .write(const DirectSettlementsCompanion(categoryId: Value(null)));
}
