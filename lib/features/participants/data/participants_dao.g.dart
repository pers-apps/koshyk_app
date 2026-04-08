// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participants_dao.dart';

// ignore_for_file: type=lint
mixin _$ParticipantsDaoMixin on DatabaseAccessor<AppDatabase> {
  $GroupsTable get groups => attachedDatabase.groups;
  $ParticipantsTable get participants => attachedDatabase.participants;
  ParticipantsDaoManager get managers => ParticipantsDaoManager(this);
}

class ParticipantsDaoManager {
  final _$ParticipantsDaoMixin _db;
  ParticipantsDaoManager(this._db);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db.attachedDatabase, _db.groups);
  $$ParticipantsTableTableManager get participants =>
      $$ParticipantsTableTableManager(_db.attachedDatabase, _db.participants);
}
