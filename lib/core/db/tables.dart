import 'package:drift/drift.dart';

class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get currencySymbol => text().withDefault(const Constant('₴'))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get roundAmounts => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Group icon (REMARKS #145). Photo takes priority over emoji; if both are
  /// null the UI shows a coloured circle with the group's first letter.
  TextColumn get iconEmoji => text().nullable()();

  /// File name (not full path) of the circle-cropped photo inside the app's
  /// documents dir `group_icons/` — full paths can change between app updates.
  TextColumn get iconImage => text().nullable()();
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
  TextColumn get icon => text().withDefault(const Constant('🏷️'))();
  IntColumn get color => integer().withDefault(const Constant(0xFF2196F3))();
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
  TextColumn get title => text().withDefault(const Constant(''))();
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

/// Which participants an expense is split between. No rows for a given
/// expenseId means "everyone currently active in the group" — this keeps
/// pre-#141 expenses working without a data migration.
class ExpenseParticipants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get expenseId =>
      integer().references(Expenses, #id, onDelete: KeyAction.cascade)();
  IntColumn get participantId =>
      integer().references(Participants, #id, onDelete: KeyAction.cascade)();
}

class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().withLength(min: 1, max: 50)();
  TextColumn get value => text()();
}
