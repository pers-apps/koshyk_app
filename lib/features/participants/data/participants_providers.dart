import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/providers.dart';
import '../../../core/db/database.dart';
import 'participants_dao.dart';

final participantsDaoProvider = Provider<ParticipantsDao>((ref) {
  return ref.watch(databaseProvider).participantsDao;
});

final participantsStreamProvider =
    StreamProvider.family<List<Participant>, int>((ref, groupId) {
  return ref.watch(participantsDaoProvider).watchByGroup(groupId);
});

final activeParticipantsProvider =
    FutureProvider.family<List<Participant>, int>((ref, groupId) {
  return ref.watch(participantsDaoProvider).getActiveByGroup(groupId);
});

final allParticipantsProvider =
    FutureProvider.family<List<Participant>, int>((ref, groupId) {
  return ref.watch(participantsDaoProvider).getByGroup(groupId);
});
