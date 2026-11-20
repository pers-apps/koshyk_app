import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koshyk_app/core/db/database.dart';
import 'package:koshyk_app/core/widgets/group_avatar.dart';
import 'package:koshyk_app/features/export/export_service.dart';
import 'package:koshyk_app/features/export/import_service.dart';
import 'package:koshyk_app/features/groups/data/group_icon_storage.dart';
import 'package:koshyk_app/l10n/app_localizations.dart';

// REMARKS #145 — group icon survives backup export → import.
void main() {
  testWidgets('emoji and photo icons round-trip through JSON backup',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    late Directory dir;
    late BuildContext ctx;

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Builder(builder: (c) {
        ctx = c;
        return const Scaffold();
      }),
    ));

    await tester.runAsync(() async {
      dir = await Directory.systemTemp.createTemp('koshyk_icons');
      GroupIconStorage.setDirectoryForTesting(dir.path);

      // Photo group
      final png = Uint8List.fromList(List.generate(64, (i) => i));
      final stored = await GroupIconStorage.saveRaw(png);
      final photoGroup = await db.groupsDao.insertGroup(GroupsCompanion.insert(
          name: 'Photo trip', iconImage: Value(stored)));
      // Emoji group
      final emojiGroup = await db.groupsDao.insertGroup(GroupsCompanion.insert(
          name: 'Beach', iconEmoji: const Value('🏖️')));
      // Plain group (old-style backup, no icon keys)
      final plainGroup = await db.groupsDao
          .insertGroup(GroupsCompanion.insert(name: 'Plain'));

      final exp = ExportService(db);
      final photoJson = jsonEncode(await exp.buildBackupData(photoGroup));
      final emojiJson = jsonEncode(await exp.buildBackupData(emojiGroup));
      final plainData = (await exp.buildBackupData(plainGroup))!;
      expect((plainData['group'] as Map).containsKey('iconEmoji'), isFalse);
      expect((plainData['group'] as Map).containsKey('iconImagePng'), isFalse);

      final imp = ImportService(db);
      final newPhoto = await imp.importFromJsonString(ctx, photoJson);
      final newEmoji = await imp.importFromJsonString(ctx, emojiJson);
      final newPlain = await imp.importFromJsonString(ctx, jsonEncode(plainData));

      final gp = await db.groupsDao.getById(newPhoto!);
      expect(gp!.iconImage, isNotNull);
      expect(gp.iconImage, isNot(stored)); // a new copy, not shared
      expect(GroupIconStorage.fileFor(gp.iconImage)!.readAsBytesSync(), png);

      expect((await db.groupsDao.getById(newEmoji!))!.iconEmoji, '🏖️');
      final pl = (await db.groupsDao.getById(newPlain!))!;
      expect(pl.iconEmoji, isNull);
      expect(pl.iconImage, isNull);

      // Deleting a group removes its photo file.
      final f = GroupIconStorage.fileFor(gp.iconImage)!;
      await db.groupsDao.deleteGroup(newPhoto);
      expect(f.existsSync(), isFalse);

      await dir.delete(recursive: true);
    });
  });

  test('letter fallback helpers', () {
    expect(GroupAvatar.initialOf('подорож'), 'П');
    expect(GroupAvatar.initialOf('  '), '?');
    expect(GroupAvatar.colorFor('Trip'), GroupAvatar.colorFor(' trip '));
  });
}
