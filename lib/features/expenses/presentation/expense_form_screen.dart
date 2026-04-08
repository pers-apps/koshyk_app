import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/db/database.dart';
import '../../../core/db/app_settings_dao.dart';
import '../../../core/db/providers.dart';
import '../../../core/utils/expression_parser.dart';
import '../../../core/utils/money.dart';
import '../data/expenses_providers.dart';
import '../../participants/data/participants_providers.dart';
import '../../categories/data/categories_providers.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  final int groupId;
  final int? expenseId;
  const ExpenseFormScreen({super.key, required this.groupId, this.expenseId});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  int? _payerId;
  int? _categoryId;
  Expense? _existing;
  bool _loading = true;
  List<Participant> _participants = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final db = ref.read(databaseProvider);
    _participants =
        await ref.read(participantsDaoProvider).getActiveByGroup(widget.groupId);
    _categories =
        await ref.read(categoriesDaoProvider).getByGroup(widget.groupId);

    if (widget.expenseId != null) {
      final dao = ref.read(expensesDaoProvider);
      final expenses = await dao.getByGroup(widget.groupId);
      _existing = expenses.where((e) => e.id == widget.expenseId).firstOrNull;
      if (_existing != null) {
        _amountCtrl.text =
            fromKopiykas(_existing!.amountKop).toStringAsFixed(2);
        _commentCtrl.text = _existing!.comment;
        _date = _existing!.date;
        _payerId = _existing!.payerId;
        _categoryId = _existing!.categoryId;
      }
    } else {
      // Default payer from last-used
      final lastPayerId =
          await db.getSetting('last_payer_${widget.groupId}');
      if (lastPayerId != null) {
        final id = int.tryParse(lastPayerId);
        if (id != null && _participants.any((p) => p.id == id)) {
          _payerId = id;
        }
      }
      if (_payerId == null && _participants.isNotEmpty) {
        _payerId = _participants.first.id;
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
    if (_payerId == null) return;

    final kop = toKopiykas(amount);
    final dao = ref.read(expensesDaoProvider);

    if (_existing == null) {
      await dao.insertExpense(ExpensesCompanion.insert(
        groupId: widget.groupId,
        payerId: _payerId!,
        amountKop: kop,
        date: _date,
        categoryId: Value(_categoryId),
        comment: Value(_commentCtrl.text.trim()),
      ));
    } else {
      await dao.updateExpense(_existing!.copyWith(
        payerId: _payerId!,
        amountKop: kop,
        date: _date,
        categoryId: Value(_categoryId),
        comment: _commentCtrl.text.trim(),
      ));
    }

    // Save last-used payer
    final db = ref.read(databaseProvider);
    await db.setSetting('last_payer_${widget.groupId}', '$_payerId');

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isEdit = _existing != null;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(isEdit ? l.editExpense : l.addExpense)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? l.editExpense : l.addExpense)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
            DropdownButtonFormField<int>(
              value: _payerId,
              decoration: InputDecoration(labelText: l.payer),
              items: _participants
                  .map((p) =>
                      DropdownMenuItem(value: p.id, child: Text(p.name)))
                  .toList(),
              onChanged: (v) => setState(() => _payerId = v),
              validator: (v) => v == null ? l.required : null,
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
