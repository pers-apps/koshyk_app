// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlements_dao.dart';

// ignore_for_file: type=lint
mixin _$SettlementsDaoMixin on DatabaseAccessor<AppDatabase> {
  $GroupsTable get groups => attachedDatabase.groups;
  $ParticipantsTable get participants => attachedDatabase.participants;
  $CategoriesTable get categories => attachedDatabase.categories;
  $DirectSettlementsTable get directSettlements =>
      attachedDatabase.directSettlements;
  SettlementsDaoManager get managers => SettlementsDaoManager(this);
}

class SettlementsDaoManager {
  final _$SettlementsDaoMixin _db;
  SettlementsDaoManager(this._db);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db.attachedDatabase, _db.groups);
  $$ParticipantsTableTableManager get participants =>
      $$ParticipantsTableTableManager(_db.attachedDatabase, _db.participants);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$DirectSettlementsTableTableManager get directSettlements =>
      $$DirectSettlementsTableTableManager(
        _db.attachedDatabase,
        _db.directSettlements,
      );
}
