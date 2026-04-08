import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import '../../features/groups/data/groups_dao.dart';
import '../../features/participants/data/participants_dao.dart';
import '../../features/categories/data/categories_dao.dart';
import '../../features/expenses/data/expenses_dao.dart';
import '../../features/settlements/data/settlements_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Groups,
    Participants,
    Categories,
    Expenses,
    DirectSettlements,
    AppSettings,
  ],
  daos: [
    GroupsDao,
    ParticipantsDao,
    CategoriesDao,
    ExpensesDao,
    SettlementsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'koshyk.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
