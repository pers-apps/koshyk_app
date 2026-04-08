import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/db/database.dart';
import '../../core/utils/money.dart';
import '../summary/domain/calculation_engine.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

class ExportService {
  final AppDatabase _db;
  ExportService(this._db);

  Future<void> exportCsv(BuildContext context, int groupId) async {
    final l = AppLocalizations.of(context)!;

    final group = await _db.groupsDao.getById(groupId);
    if (group == null) return;

    final participants = await _db.participantsDao.getByGroup(groupId);
    final categories = await _db.categoriesDao.getByGroup(groupId);
    final expenses = await _db.expensesDao.getByGroup(groupId);
    final settlements = await _db.settlementsDao.getByGroup(groupId);

    final pMap = {for (final p in participants) p.id: p.name};
    final cMap = {for (final c in categories) c.id: c.name};

    final buf = StringBuffer();
    // UTF-8 BOM for Excel compatibility
    buf.write('\uFEFF');

    // Group info
    buf.writeln('Група,${_esc(group.name)}');
    buf.writeln('Валюта,${_esc(group.currencySymbol)}');
    buf.writeln();

    // Participants
    buf.writeln('Учасники');
    buf.writeln('ID,Ім\'я,Активний');
    for (final p in participants) {
      buf.writeln('${p.id},${_esc(p.name)},${p.isActive ? "Так" : "Ні"}');
    }
    buf.writeln();

    // Expenses
    final dateFmt = DateFormat('dd.MM.yyyy');
    buf.writeln('Витрати');
    buf.writeln('Дата,Платник,Сума,Категорія,Коментар');
    for (final e in expenses) {
      final payer = pMap[e.payerId] ?? '?';
      final cat = e.categoryId != null ? (cMap[e.categoryId] ?? '') : '';
      buf.writeln(
          '${dateFmt.format(e.date)},${_esc(payer)},${fromKopiykas(e.amountKop).toStringAsFixed(2)},${_esc(cat)},${_esc(e.comment)}');
    }
    buf.writeln();

    // Direct settlements
    buf.writeln('Прямі розрахунки');
    buf.writeln('Дата,Від,Кому,Сума,Категорія,Коментар');
    for (final s in settlements) {
      final from = pMap[s.fromParticipantId] ?? '?';
      final to = pMap[s.toParticipantId] ?? '?';
      final cat = s.categoryId != null ? (cMap[s.categoryId] ?? '') : '';
      buf.writeln(
          '${dateFmt.format(s.date)},${_esc(from)},${_esc(to)},${fromKopiykas(s.amountKop).toStringAsFixed(2)},${_esc(cat)},${_esc(s.comment)}');
    }
    buf.writeln();

    // Summary
    final summary = calculateSummary(
      participants: participants,
      expenses: expenses,
      directSettlements: settlements,
    );

    buf.writeln('Підсумок балансів');
    buf.writeln(
        'Учасник,Сплачено,Рівна частка,Баланс (до переказів),Перекази (нетто),Підсумковий баланс');
    for (final ps in summary.participants) {
      final name = pMap[ps.participantId] ?? '?';
      buf.writeln([
        _esc(name),
        ps.amountPaid.toStringAsFixed(2),
        ps.equalShare.toStringAsFixed(2),
        ps.rawBalance.toStringAsFixed(2),
        ps.transferNet.toStringAsFixed(2),
        ps.finalBalance.toStringAsFixed(2),
      ].join(','));
    }
    buf.writeln();

    buf.writeln('Інструкції розрахунку');
    buf.writeln('Від,Кому,Сума');
    for (final p in summary.settlements) {
      final from = pMap[p.fromId] ?? '?';
      final to = pMap[p.toId] ?? '?';
      buf.writeln(
          '${_esc(from)},${_esc(to)},${p.amount.toStringAsFixed(2)}');
    }

    // Write to temp file (UTF-8)
    final dir = await getTemporaryDirectory();
    final safeGroupName = group.name.replaceAll(RegExp(r'[^\w]'), '_');
    final fileName =
        '${safeGroupName}_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(utf8.encode(buf.toString()));

    if (context.mounted) {
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: fileName,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.exportDone)));
      }
    }
  }

  /// Escape CSV field (wrap in quotes if contains comma/newline/quote)
  String _esc(String s) {
    if (s.contains(',') || s.contains('\n') || s.contains('"')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}
