import 'package:drift/drift.dart';
import '../../../core/db/database.dart';
import '../../../core/db/tables.dart';
import 'group_icon_storage.dart';

part 'groups_dao.g.dart';

@DriftAccessor(tables: [Groups])
class GroupsDao extends DatabaseAccessor<AppDatabase> with _$GroupsDaoMixin {
  GroupsDao(super.db);

  Stream<List<Group>> watchAll() => select(groups).watch();

  Stream<List<Group>> watchActive() =>
      (select(groups)..where((t) => t.isArchived.equals(false))).watch();

  Stream<List<Group>> watchArchived() =>
      (select(groups)..where((t) => t.isArchived.equals(true))).watch();

  Future<Group?> getById(int id) =>
      (select(groups)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Group?> watchById(int id) =>
      (select(groups)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<int> countActive() async {
    final result = await (select(groups)
          ..where((t) => t.isArchived.equals(false)))
        .get();
    return result.length;
  }

  Future<int> countAll() async {
    final result = await select(groups).get();
    return result.length;
  }

  Future<int> insertGroup(GroupsCompanion entry) =>
      into(groups).insert(entry);

  Future<void> updateGroup(Group entry) =>
      update(groups).replace(entry);

  Future<void> updateCurrency(int id, String symbol) =>
      (update(groups)..where((t) => t.id.equals(id)))
          .write(GroupsCompanion(currencySymbol: Value(symbol)));

  Future<void> updateCurrencyAll(String symbol) =>
      update(groups).write(GroupsCompanion(currencySymbol: Value(symbol)));

  Future<void> archiveGroup(int id, {bool archive = true}) =>
      (update(groups)..where((t) => t.id.equals(id)))
          .write(GroupsCompanion(isArchived: Value(archive)));

  /// Deletes the group and its photo icon file, if any (REMARKS #145).
  Future<int> deleteGroup(int id) async {
    final g = await (select(groups)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    final n = await (delete(groups)..where((t) => t.id.equals(id))).go();
    await GroupIconStorage.delete(g?.iconImage);
    return n;
  }

  Future<bool> nameExists(String name, {int? excludeId}) async {
    final query = select(groups)
      ..where((t) {
        if (excludeId != null) {
          return t.name.lower().equals(name.toLowerCase()) &
              t.id.equals(excludeId).not();
        }
        return t.name.lower().equals(name.toLowerCase());
      });
    return (await query.getSingleOrNull()) != null;
  }
}
