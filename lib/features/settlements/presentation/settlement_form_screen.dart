import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/db/database.dart';
import '../../../core/utils/expression_parser.dart';
import '../../../core/utils/money.dart';
import '../data/settlements_providers.dart';
import '../../participants/data/participants_providers.dart';
import '../../categories/data/categories_providers.dart';

class SettlementFormScreen extends ConsumerStatefulWidget {
  final int groupId;
  final int? settlementId;
  const SettlementFormScreen(
      {super.key, required this.groupId, this.settlementId});

  @override
  ConsumerState<SettlementFormScreen> createState() =>
      _SettlementFormScreenState();
}

class _SettlementFormScreenState
    extends ConsumerState<SettlementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  int? _fromId;
  int? _toId;
  int? _categoryId;
  DirectSettlement? _existing;
  bool _loading = true;
  List<Participant> _participants = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _participants =
        await ref.read(participantsDaoProvider).getActiveByGroup(widget.groupId);
    _categories =
        await ref.read(categoriesDaoProvider).getByGroup(widget.groupId);

    if (widget.settlementId != null) {
      final dao = ref.read(settlementsDaoProvider);
      final all = await dao.getByGroup(widget.groupId);
      _existing =
          all.where((s) => s.id == widget.settlementId).firstOrNull;
      if (_existing != null) {
        _amountCtrl.text =
            fromKopiykas(_existing!.amountKop).toStringAsFixed(2);
        _commentCtrl.text = _existing!.comment;
        _date = _existing!.date;
        _fromId = _existing!.fromParticipantId;
        _toId = _existing!.toParticipantId;
        _categoryId = _existing!.categoryId;
      }
    } else {
      if (_participants.isNotEmpty) {
        _fromId = _participants.first.id;
        _toId = _participants.length > 1 ? _participants[1].id : null;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context)!;

    final amount = parseAmount(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.invalidAmount)));
      return;
    }
    if (_fromId == null || _toId == null) return;
    if (_fromId == _toId) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.samePersonError)));
      return;
    }

    final kop = toKopiykas(amount);
    final dao = ref.read(settlementsDaoProvider);

    if (_existing == null) {
      await dao.insertSettlement(DirectSettlementsCompanion.insert(
        groupId: widget.groupId,
        fromParticipantId: _fromId!,
        toParticipantId: _toId!,
        amountKop: kop,
        date: _date,
        categoryId: Value(_categoryId),
        comment: Value(_commentCtrl.text.trim()),
      ));
    } else {
      await dao.updateSettlement(_existing!.copyWith(
        fromParticipantId: _fromId!,
        toParticipantId: _toId!,
        amountKop: kop,
        date: _date,
        categoryId: Value(_categoryId),
        comment: _commentCtrl.text.trim(),
      ));
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isEdit = _existing != null;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
            title: Text(isEdit ? l.editSettlement : l.addSettlement)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar:
          AppBar(title: Text(isEdit ? l.editSettlement : l.addSettlement)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              value: _fromId,
              decoration: InputDecoration(labelText: l.from),
              items: _participants
                  .map((p) =>
                      DropdownMenuItem(value: p.id, child: Text(p.name)))
                  .toList(),
              onChanged: (v) => setState(() => _fromId = v),
              validator: (v) => v == null ? l.required : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _toId,
              decoration: InputDecoration(labelText: l.to),
              items: _participants
                  .map((p) =>
                      DropdownMenuItem(value: p.id, child: Text(p.name)))
                  .toList(),
              onChanged: (v) => setState(() => _toId = v),
              validator: (v) {
                if (v == null) return l.required;
                if (v == _fromId) return l.samePersonError;
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountCtrl,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l.amount,
                hintText: l.amountHint,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l.required;
                if (parseAmount(v) == null) return l.invalidAmount;
                return null;
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.date),
              subtitle: Text(DateFormat('dd.MM.yyyy').format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<int?>(
              value: _categoryId,
              decoration: InputDecoration(labelText: l.category),
              items: [
                DropdownMenuItem<int?>(
                    value: null, child: Text(l.noCategory)),
                ..._categories.map((c) =>
                    DropdownMenuItem(value: c.id, child: Text(c.name))),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commentCtrl,
              decoration: InputDecoration(labelText: l.comment),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}
