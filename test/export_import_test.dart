import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koshyk_app/core/db/database.dart';
import 'package:koshyk_app/features/export/export_service.dart';
import 'package:koshyk_app/features/export/import_service.dart';
import 'package:koshyk_app/l10n/app_localizations.dart';

void main() {
  testWidgets('export then import round-trips a group onto a new group',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    // Seed a source group with one of everything.
    final groupId = await db.groupsDao.insertGroup(GroupsCompanion.insert(
      name: 'Test trip',
      currencySymbol: const Value('₴'),
      roundAmounts: const Value(true),
    ));
    final aliceId = await db.participantsDao.insertParticipant(
        ParticipantsCompanion.insert(groupId: groupId, name: 'Alice'));
    final bobId = await db.participantsDao.insertParticipant(
        ParticipantsCompanion.insert(groupId: groupId, name: 'Bob'));
    final foodCatId = await db.categoriesDao.insertCategory(
      CategoriesCompanion.insert(
        groupId: groupId,
        name: 'Food',
        icon: const Value('🍽️'),
        color: const Value(0xFFFF7043),
      ),
    );
    await db.expensesDao.insertExpense(ExpensesCompanion.insert(
      groupId: groupId,
      payerId: aliceId,
      amountKop: 12000,
      date: DateTime(2026, 1, 1),
      categoryId: Value(foodCatId),
      title: const Value('Lunch'),
      comment: const Value('with Bob'),
    ));
    await db.settlementsDao.insertSettlement(
      DirectSettlementsCompanion.insert(
        groupId: groupId,
        fromParticipantId: bobId,
        toParticipantId: aliceId,
        amountKop: 6000,
        date: DateTime(2026, 1, 2),
      ),
    );

    // buildBackupData / importFromJsonString are pure data + DB operations —
    // no Share or file_picker platform channels involved, so no mocking
    // needed. A BuildContext is still required for AppLocalizations strings
    // on the import side, hence the minimal MaterialApp harness.
    final backupData = await ExportService(db).buildBackupData(groupId);
    expect(backupData, isNotNull);
    final jsonStr = const JsonEncoder().convert(backupData);

    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Builder(builder: (context) {
        capturedContext = context;
        return const Scaffold();
      }),
    ));
    await tester.pumpAndSettle();

    final newGroupId = await ImportService(db)
        .importFromJsonString(capturedContext, jsonStr);
    expect(newGroupId, isNotNull);
    expect(newGroupId, isNot(groupId),
        reason: 'import must create a NEW group, not reuse the source one');

    final importedParticipants =
        await db.participantsDao.getByGroup(newGroupId!);
    final importedCategories = await db.categoriesDao.getByGroup(newGroupId);
    final importedExpenses = await db.expensesDao.getByGroup(newGroupId);
    final importedSettlements =
        await db.settlementsDao.getByGroup(newGroupId);

    expect(importedParticipants.map((p) => p.name).toSet(), {'Alice', 'Bob'});
    expect(importedCategories.map((c) => c.name), ['Food']);
    expect(importedExpenses, hasLength(1));
    expect(importedExpenses.single.amountKop, 12000);
    expect(importedExpenses.single.title, 'Lunch');
    expect(importedSettlements, hasLength(1));
    expect(importedSettlements.single.amountKop, 6000);

    // Source group must be untouched.
    final originalExpenses = await db.expensesDao.getByGroup(groupId);
    expect(originalExpenses, hasLength(1));

    // Malformed / wrong-version input must be rejected without creating
    // a group or throwing.
    final beforeCount = await db.groupsDao.countAll();
    final rejectedGarbage = await ImportService(db)
        .importFromJsonString(capturedContext, 'not valid json');
    expect(rejectedGarbage, isNull);
    final rejectedVersion = await ImportService(db).importFromJsonString(
        capturedContext, jsonEncode({'formatVersion': 999, 'group': {}}));
    expect(rejectedVersion, isNull);
    expect(await db.groupsDao.countAll(), beforeCount);
  });

  testWidgets('per-expense split survives export → import (REMARKS #147)',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final groupId = await db.groupsDao
        .insertGroup(GroupsCompanion.insert(name: 'Split trip'));
    final aliceId = await db.participantsDao.insertParticipant(
        ParticipantsCompanion.insert(groupId: groupId, name: 'Alice'));
    final bobId = await db.participantsDao.insertParticipant(
        ParticipantsCompanion.insert(groupId: groupId, name: 'Bob'));
    await db.participantsDao.insertParticipant(
        ParticipantsCompanion.insert(groupId: groupId, name: 'Carol'));

    // Taxi: split between Alice and Bob only.
    final taxiId = await db.expensesDao.insertExpense(ExpensesCompanion.insert(
      groupId: groupId,
      payerId: aliceId,
      amountKop: 30000,
      date: DateTime(2026, 1, 1),
      title: const Value('Taxi'),
    ));
    await db.expensesDao.setReceivers(taxiId, [aliceId, bobId]);
    // Dinner: no explicit rows = everyone.
    await db.expensesDao.insertExpense(ExpensesCompanion.insert(
      groupId: groupId,
      payerId: bobId,
      amountKop: 90000,
      date: DateTime(2026, 1, 2),
      title: const Value('Dinner'),
    ));

    final backupData = await ExportService(db).buildBackupData(groupId);
    final exportedExpenses =
        (backupData!['expenses'] as List).cast<Map<String, dynamic>>();
    final exportedTaxi = exportedExpenses.firstWhere((e) => e['title'] == 'Taxi');
    final exportedDinner =
        exportedExpenses.firstWhere((e) => e['title'] == 'Dinner');
    expect(exportedTaxi['receiverLocalIds'], hasLength(2));
    expect(exportedDinner.containsKey('receiverLocalIds'), isFalse,
        reason: '"everyone" stays implicit, as in older backups');
    final jsonStr = const JsonEncoder().convert(backupData);

    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Builder(builder: (context) {
        capturedContext = context;
        return const Scaffold();
      }),
    ));
    await tester.pumpAndSettle();

    final newGroupId = await ImportService(db)
        .importFromJsonString(capturedContext, jsonStr);
    expect(newGroupId, isNotNull);

    final newParticipants = await db.participantsDao.getByGroup(newGroupId!);
    final nameById = {for (final p in newParticipants) p.id: p.name};
    final newExpenses = await db.expensesDao.getByGroup(newGroupId);
    final receivers = await db.expensesDao.getReceiversByGroup(newGroupId);

    final newTaxi = newExpenses.firstWhere((e) => e.title == 'Taxi');
    final newDinner = newExpenses.firstWhere((e) => e.title == 'Dinner');
    expect(receivers[newTaxi.id]!.map((id) => nameById[id]).toSet(),
        {'Alice', 'Bob'},
        reason: 'split must point at the NEW group\'s participants');
    expect(receivers.containsKey(newDinner.id), isFalse);

    // A pre-2.2.0 backup (no receiverLocalIds) still imports, as "everyone".
    final legacy = Map<String, dynamic>.from(backupData);
    legacy['expenses'] = [
      for (final e in exportedExpenses)
        Map<String, dynamic>.from(e)..remove('receiverLocalIds'),
    ];
    final legacyGroupId = await ImportService(db)
        .importFromJsonString(capturedContext, jsonEncode(legacy));
    expect(legacyGroupId, isNotNull);
    expect(await db.expensesDao.getByGroup(legacyGroupId!), hasLength(2));
    expect(await db.expensesDao.getReceiversByGroup(legacyGroupId), isEmpty);
  });
}
