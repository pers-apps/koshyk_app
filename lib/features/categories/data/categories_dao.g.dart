// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_dao.dart';

// ignore_for_file: type=lint
mixin _$CategoriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $GroupsTable get groups => attachedDatabase.groups;
  $CategoriesTable get categories => attachedDatabase.categories;
  $ParticipantsTable get participants => attachedDatabase.participants;
  $ExpensesTable get expenses => attachedDatabase.expenses;
  CategoriesDaoManager get managers => CategoriesDaoManager(this);
}

class CategoriesDaoManager {
  final _$CategoriesDaoMixin _db;
  CategoriesDaoManager(this._db);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db.attachedDatabase, _db.groups);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ParticipantsTableTableManager get participants =>
      $$ParticipantsTableTableManager(_db.attachedDatabase, _db.participants);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db.attachedDatabase, _db.expenses);
}
