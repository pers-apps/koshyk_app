import 'package:drift/drift.dart';
import '../../../core/db/database.dart';
import '../../../core/db/tables.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Stream<List<Category>> watchByGroup(int groupId) =>
      (select(categories)..where((t) => t.groupId.equals(groupId))).watch();

  Future<List<Category>> getByGroup(int groupId) =>
      (select(categories)..where((t) => t.groupId.equals(groupId))).get();

  Future<int> insertCategory(CategoriesCompanion entry) =>
      into(categories).insert(entry);

  Future<void> updateCategory(Category entry) =>
      update(categories).replace(entry);

  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((t) => t.id.equals(id))).go();

  Future<int> countByGroup(int groupId) async {
    final count = await (select(categories)
          ..where((t) => t.groupId.equals(groupId)))
        .get();
    return count.length;
  }
}
