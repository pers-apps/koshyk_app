import 'database.dart';

/// Simple key-value settings via AppDatabase extension.
extension AppSettingsExtension on AppDatabase {
  Future<String?> getSetting(String key) async {
    final rows = await (select(appSettings)
          ..where((t) => t.key.equals(key))
          ..limit(1))
        .get();
    return rows.firstOrNull?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await (delete(appSettings)..where((t) => t.key.equals(key))).go();
    await into(appSettings).insert(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }
}
