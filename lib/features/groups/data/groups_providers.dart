import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/providers.dart';
import '../../../core/db/database.dart';
import 'groups_dao.dart';

final groupsDaoProvider = Provider<GroupsDao>((ref) {
  return ref.watch(databaseProvider).groupsDao;
});

final groupsStreamProvider = StreamProvider<List<Group>>((ref) {
  return ref.watch(groupsDaoProvider).watchAll();
});

final groupByIdProvider =
    FutureProvider.family<Group?, int>((ref, id) async {
  return ref.watch(groupsDaoProvider).getById(id);
});
