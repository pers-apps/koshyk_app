import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/providers.dart';
import '../../../core/db/database.dart';
import 'settlements_dao.dart';

final settlementsDaoProvider = Provider<SettlementsDao>((ref) {
  return ref.watch(databaseProvider).settlementsDao;
});

final settlementsStreamProvider =
    StreamProvider.family<List<DirectSettlement>, int>((ref, groupId) {
  return ref.watch(settlementsDaoProvider).watchByGroup(groupId);
});
