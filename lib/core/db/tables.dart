import 'package:drift/drift.dart';

class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get currencySymbol => text().withDefault(const Constant('₴'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Participants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 50)();
}

/// Shared expenses — amount stored in kopiykas (INTEGER)
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();
  IntColumn get payerId =>
      integer().references(Participants, #id)();
  IntColumn get amountKop => integer()(); // minor units
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  TextColumn get comment => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();
}

/// Peer-to-peer transfers — do NOT enter shared expense pool
class DirectSettlements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();
  IntColumn get fromParticipantId =>
      integer().references(Participants, #id)();
  IntColumn get toParticipantId =>
      integer().references(Participants, #id)();
  IntColumn get amountKop => integer()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  TextColumn get comment => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();
}

class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().withLength(min: 1, max: 50)();
  TextColumn get value => text()();
}
