import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/db/database.dart';
import '../groups/data/group_icon_storage.dart';
import '../../l10n/app_localizations.dart';

/// Bumped whenever the backup JSON shape changes incompatibly.
const kBackupFormatVersion = 1;

class ExportService {
  final AppDatabase _db;
  ExportService(this._db);

  /// Exports a group as a JSON backup file for transfer to another device,
  /// and opens the system share sheet so the user picks a channel
  /// (AirDrop, email, Drive, Telegram, etc.) — no server upload involved.
  Future<void> exportJson(BuildContext context, int groupId) async {
    final l = AppLocalizations.of(context)!;

    final data = await buildBackupData(groupId);
    if (data == null) return;
    final groupName = (data['group'] as Map)['name'] as String;

    final dir = await getTemporaryDirectory();
    final fileName = backupFileName(groupName, DateTime.now());
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    if (context.mounted) {
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: fileName,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.exportDone)));
      }
    }
  }

  /// Builds the backup JSON structure for a group — pure data, no file I/O
  /// or sharing — so it can be exercised directly (e.g. in tests).
  Future<Map<String, dynamic>?> buildBackupData(int groupId) async {
    final group = await _db.groupsDao.getById(groupId);
    if (group == null) return null;

    final participants = await _db.participantsDao.getByGroup(groupId);
    final categories = await _db.categoriesDao.getByGroup(groupId);
    final expenses = await _db.expensesDao.getByGroup(groupId);
    final settlements = await _db.settlementsDao.getByGroup(groupId);
    // Per-expense split (REMARKS #141/#147). Expenses absent from this map
    // have no explicit rows = split among everyone.
    final receiversByExpense =
        await _db.expensesDao.getReceiversByGroup(groupId);

    // Export-local sequential ids (not this device's DB autoincrement ids),
    // so foreign keys can be remapped safely on import into another device.
    final participantLocalId = {
      for (var i = 0; i < participants.length; i++) participants[i].id: i + 1,
    };
    final categoryLocalId = {
      for (var i = 0; i < categories.length; i++) categories[i].id: i + 1,
    };

    final data = {
      'formatVersion': kBackupFormatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'group': {
        'name': group.name,
        'currencySymbol': group.currencySymbol,
        'roundAmounts': group.roundAmounts,
        // Group icon (REMARKS #145) — optional; older backups lack these.
        if (group.iconEmoji != null) 'iconEmoji': group.iconEmoji,
        if (_iconPngBase64(group.iconImage) case final png?)
          'iconImagePng': png,
      },
      'participants': [
        for (final p in participants)
          {
            'localId': participantLocalId[p.id],
            'name': p.name,
            'isActive': p.isActive,
          },
      ],
      'categories': [
        for (final c in categories)
          {
            'localId': categoryLocalId[c.id],
            'name': c.name,
            'icon': c.icon,
            'color': c.color,
          },
      ],
      'expenses': [
        for (final e in expenses)
          {
            'payerLocalId': participantLocalId[e.payerId],
            'amountKop': e.amountKop,
            'categoryLocalId':
                e.categoryId != null ? categoryLocalId[e.categoryId] : null,
            'title': e.title,
            'comment': e.comment,
            'date': e.date.toIso8601String(),
            // Optional (REMARKS #147): who the expense is split between.
            // Omitted = everyone, which is also how older backups import.
            if (_receiverLocalIds(receiversByExpense[e.id], participantLocalId)
                case final ids?)
              'receiverLocalIds': ids,
          },
      ],
      'settlements': [
        for (final s in settlements)
          {
            'fromLocalId': participantLocalId[s.fromParticipantId],
            'toLocalId': participantLocalId[s.toParticipantId],
            'amountKop': s.amountKop,
            'categoryLocalId':
                s.categoryId != null ? categoryLocalId[s.categoryId] : null,
            'comment': s.comment,
            'date': s.date.toIso8601String(),
          },
      ],
    };

    return data;
  }
}

/// Backup file name (REMARKS #144):
/// `Koshyk_BU_HHMM_DDMMYYYY_<first 6 chars of group name>.json`.
///
/// Cyrillic and other letters are kept (Dart's `\w` is ASCII-only, which
/// previously turned Ukrainian names into "______"); characters invalid in
/// file names and whitespace become `_`, leading/trailing `_` are trimmed.
/// If nothing usable remains, the group-name suffix is omitted.
String backupFileName(String groupName, DateTime now) {
  String two(int v) => v.toString().padLeft(2, '0');
  final time = '${two(now.hour)}${two(now.minute)}';
  final date = '${two(now.day)}${two(now.month)}${now.year}';
  final safe = groupName
      .replaceAll(RegExp(r'[\\/:*?"<>|\s\x00-\x1F]'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  final chars = safe.runes.take(6).map(String.fromCharCode).join();
  final suffix = chars.replaceAll(RegExp(r'_+$'), '');
  return suffix.isEmpty
      ? 'Koshyk_BU_${time}_$date.json'
      : 'Koshyk_BU_${time}_${date}_$suffix.json';
}

/// Maps an expense's receiver DB ids to export-local ids, or null when the
/// expense has no explicit split (= everyone) or nothing maps.
List<int>? _receiverLocalIds(
    List<int>? receiverIds, Map<int, int> participantLocalId) {
  if (receiverIds == null || receiverIds.isEmpty) return null;
  final ids = [
    for (final id in receiverIds)
      if (participantLocalId[id] case final localId?) localId,
  ]..sort();
  return ids.isEmpty ? null : ids;
}

/// Base64 of the stored 256 px group photo, or null if none / unreadable.
String? _iconPngBase64(String? fileName) {
  final f = GroupIconStorage.fileFor(fileName);
  if (f == null) return null;
  try {
    return base64Encode(f.readAsBytesSync());
  } catch (_) {
    return null;
  }
}
