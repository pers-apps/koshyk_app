import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  AppDatabase()
      : super(
          kIsWeb
              ? driftDatabase(
                  name: 'koshyk',
                  web: DriftWebOptions(
                    sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                    driftWorker: Uri.parse('drift_worker.js'),
                  ),
                )
              : driftDatabase(name: 'koshyk'),
        );
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(groups, groups.isArchived);
            await m.addColumn(categories, categories.icon);
          }
          if (from < 3) {
            await m.addColumn(groups, groups.roundAmounts);
            await m.addColumn(expenses, expenses.title);
          }
          if (from < 4) {
            await m.addColumn(categories, categories.color);
          }
        },
      );
}
