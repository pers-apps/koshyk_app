import 'package:drift/drift.dart';
import '../../../core/db/database.dart';
import '../../../core/db/tables.dart';

part 'participants_dao.g.dart';

@DriftAccessor(tables: [Participants])
class ParticipantsDao extends DatabaseAccessor<AppDatabase>
    with _$ParticipantsDaoMixin {
  ParticipantsDao(super.db);

  Stream<List<Participant>> watchByGroup(int groupId) =>
      (select(participants)..where((t) => t.groupId.equals(groupId))).watch();

  Future<List<Participant>> getByGroup(int groupId) =>
      (select(participants)..where((t) => t.groupId.equals(groupId))).get();

  Future<List<Participant>> getActiveByGroup(int groupId) =>
      (select(participants)
            ..where((t) =>
                t.groupId.equals(groupId) & t.isActive.equals(true)))
          .get();

  Future<Participant?> getById(int id) =>
      (select(participants)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertParticipant(ParticipantsCompanion entry) =>
      into(participants).insert(entry);

  Future<void> updateParticipant(Participant entry) =>
      update(participants).replace(entry);

  Future<int> deleteParticipant(int id) =>
      (delete(participants)..where((t) => t.id.equals(id))).go();

  Future<bool> nameExistsInGroup(String name, int groupId,
      {int? excludeId}) async {
    final query = select(participants)
      ..where((t) {
        final base = t.groupId.equals(groupId) &
            t.name.lower().equals(name.toLowerCase());
        if (excludeId != null) {
          return base & t.id.equals(excludeId).not();
        }
        return base;
      });
    return (await query.getSingleOrNull()) != null;
  }
}
