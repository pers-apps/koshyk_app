import '../../../core/widgets/gradient_scaffold.dart';
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
import '../../../core/widgets/amount_operator_bar.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/pastel_colors.dart';
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
  final _titleCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  final _amountFocus = FocusNode();
  DateTime _date = DateTime.now();
  int? _payerId;
  int? _categoryId;
  Expense? _existing;
  bool _loading = true;
  bool _saving = false;
  bool _amountError = false;
  List<Participant> _participants = [];
  List<Category> _categories = [];
  List<int> _receiverIds = [];

  @override
  void initState() {
    super.initState();
    _init();
    _amountFocus.addListener(_onAmountFocusChange);
  }

  void _onAmountFocusChange() {
    // Rebuild so AmountOperatorBar shows/hides with focus (REMARKS #143).
    setState(() {});
    if (!_amountFocus.hasFocus) {
      final text = _amountCtrl.text.trim();
      if (text.isEmpty) {
        setState(() => _amountError = false);
        return;
      }
      final result = parseAmount(text);
      if (result != null) {
        final formatted = result == result.truncateToDouble()
            ? result.toInt().toString()
            : result.toStringAsFixed(2);
        setState(() {
          _amountCtrl.text = formatted;
          _amountError = false;
        });
      } else {
        setState(() => _amountError = true);
      }
    }
  }

  @override
  void dispose() {
    _amountFocus.removeListener(_onAmountFocusChange);
    _amountFocus.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
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
          _titleCtrl.text = _existing!.title;
          _commentCtrl.text = _existing!.comment;
          _date = _existing!.date;
          _payerId = _existing!.payerId;
          _categoryId = _existing!.categoryId;
          // Ensure the existing payer is in the dropdown even if now inactive.
          if (!_participants.any((p) => p.id == _payerId)) {
            final allParticipants = await ref
                .read(participantsDaoProvider)
                .getByGroup(widget.groupId);
            final payer =
                allParticipants.where((p) => p.id == _payerId).firstOrNull;
            if (payer != null) _participants = [payer, ..._participants];
          }
          // Explicit receivers, if any were saved; keep only ids still
          // offered in the form. Empty (no explicit rows, or everyone
          // filtered out) falls back to "everyone" — same meaning as today.
          final explicitReceivers = await dao.getReceiverIds(widget.expenseId!);
          _receiverIds = explicitReceivers
              .where((id) => _participants.any((p) => p.id == id))
              .toList();
          if (_receiverIds.isEmpty) {
            _receiverIds = _participants.map((p) => p.id).toList();
          }
        }
      } else {
        _receiverIds = _participants.map((p) => p.id).toList();
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
        if (_categoryId == null && _categories.length == 1) {
          _categoryId = _categories.first.id;
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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

  String _receiverSummary(AppLocalizations l) {
    final allIds = _participants.map((p) => p.id).toSet();
    final selected = _receiverIds.toSet();
    if (selected.length == allIds.length && selected.containsAll(allIds)) {
      return l.splitAll;
    }
    return _receiverIds
        .map((id) => _participants.where((p) => p.id == id).firstOrNull?.name)
        .whereType<String>()
        .join(', ');
  }

  Future<void> _pickReceivers(AppLocalizations l) async {
    final selected = Set<int>.from(_receiverIds);
    final colors = buildParticipantColors(
        _participants.map((p) => MapEntry(p.id, p.name)).toList());

    final result = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 18,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.splitBetweenSheetTitle,
                      style: Theme.of(sheetContext).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final p in _participants)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: selected.contains(p.id),
                      onChanged: (checked) => setSheetState(() {
                        if (checked == true) {
                          selected.add(p.id);
                        } else {
                          selected.remove(p.id);
                        }
                      }),
                      secondary: CircleAvatar(
                        radius: 14,
                        backgroundColor: colors[p.id] ?? kPastelColors[0],
                        child: Text(
                          p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      title: Text(p.name),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: selected.isEmpty
                        ? null
                        : () => Navigator.pop(sheetContext, selected),
                    child: Text(l.done),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _receiverIds = result.toList());
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context)!;
    final amount = parseAmount(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.invalidAmount)));
      return;
    }
    if (_payerId == null) return;

    setState(() => _saving = true);
    try {
      final kop = toKopiykas(amount);
      final dao = ref.read(expensesDaoProvider);

      int expenseId;
      if (_existing == null) {
        // Free-plan limit disabled for v1.0 (Phase 1: all users have full access).
        expenseId = await dao.insertExpense(ExpensesCompanion.insert(
          groupId: widget.groupId,
          payerId: _payerId!,
          amountKop: kop,
          date: _date,
          categoryId: Value(_categoryId),
          title: Value(_titleCtrl.text.trim()),
          comment: Value(_commentCtrl.text.trim()),
        ));
      } else {
        expenseId = _existing!.id;
        await dao.updateExpense(_existing!.copyWith(
          payerId: _payerId!,
          amountKop: kop,
          date: _date,
          categoryId: Value(_categoryId),
          title: _titleCtrl.text.trim(),
          comment: _commentCtrl.text.trim(),
        ));
      }

      await dao.setReceivers(expenseId, _receiverIds);

      // Save last-used payer
      final db = ref.read(databaseProvider);
      await db.setSetting('last_payer_${widget.groupId}', '$_payerId');

      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isEdit = _existing != null;

    if (_loading) {
      return GradientScaffold(
        appBar: AppBar(title: Text(isEdit ? l.editExpense : l.addExpense)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return GradientScaffold(
      appBar: AppBar(title: Text(isEdit ? l.editExpense : l.addExpense)),
      body: Column(
        children: [
          Expanded(
            child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: l.expenseTitle),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountCtrl,
              focusNode: _amountFocus,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l.amount,
                hintText: l.amountHint,
                filled: _amountError,
                fillColor: _amountError ? Colors.red.withValues(alpha: 0.12) : null,
                enabledBorder: _amountError
                    ? OutlineInputBorder(borderSide: BorderSide(color: Colors.red.shade400))
                    : OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l.required;
                if (parseAmount(v) == null) return l.invalidAmount;
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _payerId,
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
            DropdownButtonFormField<int>(
              initialValue: _categoryId,
              decoration: InputDecoration(labelText: l.category),
              items: _categories.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Row(
                      children: [
                        Text(c.icon,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
                  )).toList(),
              onChanged: (v) => setState(() => _categoryId = v),
              validator: (v) => v == null ? l.required : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commentCtrl,
              decoration: InputDecoration(labelText: l.comment),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _pickReceivers(l),
              child: InputDecorator(
                decoration: InputDecoration(labelText: l.splitBetween),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _receiverSummary(l),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l.save),
            ),
          ],
        ),
      ),
          ),
          if (_amountFocus.hasFocus)
            AmountOperatorBar(controller: _amountCtrl),
        ],
      ),
    );
  }
}
