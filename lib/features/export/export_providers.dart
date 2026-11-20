import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/providers.dart';
import 'export_service.dart';
import 'import_service.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref.watch(databaseProvider));
});

final importServiceProvider = Provider<ImportService>((ref) {
  return ImportService(ref.watch(databaseProvider));
});
