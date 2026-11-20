import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koshyk_app/core/db/database.dart';

// REMARKS #145 — schema v5 → v6 adds groups.icon_emoji / groups.icon_image.
// Builds a real v5 database file (current schema minus the two new columns,
// user_version = 5), then opens it with the v6 AppDatabase.
void main() {
  test('v5 → v6 migration keeps groups and adds icon columns', () async {
    final dir = await Directory.systemTemp.createTemp('koshyk_mig');
    final file = File('${dir.path}/db.sqlite');

    // 1. Create current schema, insert a group, then downgrade to v5 shape.
    final db1 = AppDatabase.forTesting(NativeDatabase(file));
    await db1.customStatement(
        "INSERT INTO groups (name, currency_symbol) VALUES ('Old trip', '₴')");
    await db1.customStatement('ALTER TABLE groups DROP COLUMN icon_emoji');
    await db1.customStatement('ALTER TABLE groups DROP COLUMN icon_image');
    await db1.customStatement('PRAGMA user_version = 5');
    await db1.close();

    // 2. Reopen with v6 code → onUpgrade(5, 6) must run.
    final db2 = AppDatabase.forTesting(NativeDatabase(file));
    final cols = await db2.customSelect('PRAGMA table_info(groups)').get();
    final names = cols.map((r) => r.read<String>('name')).toSet();
    expect(names, containsAll(['icon_emoji', 'icon_image']));

    final groups = await db2.select(db2.groups).get();
    expect(groups.single.name, 'Old trip');
    expect(groups.single.iconEmoji, isNull);
    expect(groups.single.iconImage, isNull);

    // New columns are writable.
    await (db2.update(db2.groups)..where((g) => g.id.equals(groups.single.id)))
        .write(const GroupsCompanion(iconEmoji: Value('🏖️')));
    expect((await db2.select(db2.groups).getSingle()).iconEmoji, '🏖️');

    final version =
        await db2.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 6);

    await db2.close();
    await dir.delete(recursive: true);
  });
}
