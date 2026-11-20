import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/db/database.dart';
import '../groups/data/group_icon_storage.dart';
import '../../l10n/app_localizations.dart';
import 'export_service.dart' show kBackupFormatVersion;

class ImportService {
  final AppDatabase _db;
  ImportService(this._db);

  /// Lets the user pick a JSON backup file (produced by [ExportService]) and
  /// imports it as a brand-new group — never merges into an existing one.
  /// Returns the new group's id, or null if the user cancelled or the file
  /// was invalid.
  Future<int?> importJson(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = result?.files.single.path;
    if (path == null) return null;

    final raw = await File(path).readAsString();
    if (!context.mounted) return null;
    return importFromJsonString(context, raw);
  }

  /// Core import logic, split out from [importJson] so it can be exercised
  /// directly (e.g. in tests, or a future "paste backup text" entry point)
  /// without going through the native file picker.
  Future<int?> importFromJsonString(BuildContext context, String raw) async {
    final l = AppLocalizations.of(context)!;

    Map<String, dynamic> data;
    try {
      data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['formatVersion'] != kBackupFormatVersion) {
        throw const FormatException('unsupported formatVersion');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.importInvalidFile)));
      }
      return null;
    }

    final groupData = data['group'] as Map<String, dynamic>? ?? const {};
    final baseName = groupData['name'] as String? ?? 'Imported';

    // Avoid clobbering an existing group name.
    var name = baseName;
    var suffix = 2;
    while (await _db.groupsDao.nameExists(name)) {
      name = '$baseName ($suffix)';
      suffix++;
    }

    final iconImage = await _restoreIconPhoto(groupData['iconImagePng']);
    final newGroupId = await _db.groupsDao.insertGroup(GroupsCompanion.insert(
      name: name,
      currencySymbol: Value(groupData['currencySymbol'] as String? ?? '₴'),
      roundAmounts: Value(groupData['roundAmounts'] as bool? ?? true),
      iconEmoji: Value(groupData['iconEmoji'] as String?),
      iconImage: Value(iconImage),
    ));

    final participantIdMap = <int, int>{}; // export-local id -> new DB id
    for (final raw in (data['participants'] as List<dynamic>? ?? const [])) {
      final m = raw as Map<String, dynamic>;
      final newId = await _db.participantsDao.insertParticipant(
        ParticipantsCompanion.insert(
          groupId: newGroupId,
          name: m['name'] as String,
          isActive: Value(m['isActive'] as bool? ?? true),
        ),
      );
      participantIdMap[m['localId'] as int] = newId;
    }

    final categoryIdMap = <int, int>{};
    for (final raw in (data['categories'] as List<dynamic>? ?? const [])) {
      final m = raw as Map<String, dynamic>;
      final newId = await _db.categoriesDao.insertCategory(
        CategoriesCompanion.insert(
          groupId: newGroupId,
          name: m['name'] as String,
          icon: Value(m['icon'] as String? ?? '🏷️'),
          color: Value(m['color'] as int? ?? 0xFF2196F3),
        ),
      );
      categoryIdMap[m['localId'] as int] = newId;
    }

    for (final raw in (data['expenses'] as List<dynamic>? ?? const [])) {
      final m = raw as Map<String, dynamic>;
      final payerId = participantIdMap[m['payerLocalId']];
      if (payerId == null) continue; // malformed row — skip, don't abort import
      final categoryLocalId = m['categoryLocalId'] as int?;
      final newExpenseId =
          await _db.expensesDao.insertExpense(ExpensesCompanion.insert(
        groupId: newGroupId,
        payerId: payerId,
        amountKop: m['amountKop'] as int,
        date: DateTime.parse(m['date'] as String),
        categoryId: Value(
            categoryLocalId != null ? categoryIdMap[categoryLocalId] : null),
        title: Value(m['title'] as String? ?? ''),
        comment: Value(m['comment'] as String? ?? ''),
      ));

      // Per-expense split (REMARKS #147). Missing/empty = everyone, which
      // is also what backups made before 2.2.0 fall back to.
      final receiverIds = <int>{
        for (final localId
            in (m['receiverLocalIds'] as List<dynamic>? ?? const []))
          if (participantIdMap[localId] case final id?) id,
      };
      if (receiverIds.isNotEmpty) {
        await _db.expensesDao
            .setReceivers(newExpenseId, receiverIds.toList()..sort());
      }
    }

    for (final raw in (data['settlements'] as List<dynamic>? ?? const [])) {
      final m = raw as Map<String, dynamic>;
      final fromId = participantIdMap[m['fromLocalId']];
      final toId = participantIdMap[m['toLocalId']];
      if (fromId == null || toId == null) continue;
      final categoryLocalId = m['categoryLocalId'] as int?;
      await _db.settlementsDao.insertSettlement(
        DirectSettlementsCompanion.insert(
          groupId: newGroupId,
          fromParticipantId: fromId,
          toParticipantId: toId,
          amountKop: m['amountKop'] as int,
          date: DateTime.parse(m['date'] as String),
          categoryId: Value(categoryLocalId != null
              ? categoryIdMap[categoryLocalId]
              : null),
          comment: Value(m['comment'] as String? ?? ''),
        ),
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.importDone)));
    }

    return newGroupId;
  }

  /// Restores the group photo from a backup (REMARKS #145). Returns the new
  /// stored file name, or null if absent, oversized, invalid, or unsupported.
  Future<String?> _restoreIconPhoto(Object? b64) async {
    if (b64 is! String || !GroupIconStorage.isSupported) return null;
    try {
      final bytes = base64Decode(b64);
      if (bytes.length > 2 * 1024 * 1024) return null; // 256 px PNG is far smaller
      return await GroupIconStorage.saveRaw(bytes);
    } catch (_) {
      return null;
    }
  }
}
