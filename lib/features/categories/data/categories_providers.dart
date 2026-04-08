import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/db/providers.dart';
import '../../../core/db/database.dart';
import 'categories_dao.dart';

final categoriesDaoProvider = Provider<CategoriesDao>((ref) {
  return ref.watch(databaseProvider).categoriesDao;
});

final categoriesStreamProvider =
    StreamProvider.family<List<Category>, int>((ref, groupId) {
  return ref.watch(categoriesDaoProvider).watchByGroup(groupId);
});

final categoriesProvider =
    FutureProvider.family<List<Category>, int>((ref, groupId) {
  return ref.watch(categoriesDaoProvider).getByGroup(groupId);
});
