import '../../../core/widgets/gradient_scaffold.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/db/database.dart';
import '../../../core/utils/expression_parser.dart';
import '../../../core/widgets/amount_operator_bar.dart';
import '../../../core/utils/money.dart';
import '../data/settlements_providers.dart';
import '../../participants/data/participants_providers.dart';
import '../../categories/data/categories_providers.dart';
import '../../summary/data/summary_provider.dart';
import '../../groups/data/groups_providers.dart';

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
  final _amountFocus = FocusNode();
  DateTime _date = DateTime.now();
  int? _fromId;
  int? _toId;
  int? _categoryId;
  DirectSettlement? _existing;
  bool _loading = true;
  bool _amountError = false;
  List<Participant> _participants = [];
  List<Category> _categories = [];

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
        // Ensure inactive participants referenced by this settlement are shown.
        final allParticipants = await ref
            .read(participantsDaoProvider)
            .getByGroup(widget.groupId);
        for (final id in [_fromId, _toId]) {
          if (id != null && !_participants.any((p) => p.id == id)) {
            final p = allParticipants.where((p) => p.id == id).firstOrNull;
            if (p != null) _participants = [p, ..._participants];
          }
        }
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
      // Free-plan limit disabled for v1.0 (Phase 1: all users have full access).
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
      return GradientScaffold(
        appBar: AppBar(
            title: Text(isEdit ? l.editSettlement : l.addSettlement)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final summaryAsync = ref.watch(summaryProvider(widget.groupId));
    final roundAmounts = ref.watch(groupByIdProvider(widget.groupId)).maybeWhen(
      data: (g) => g?.roundAmounts ?? true,
      orElse: () => true,
    );
    final currency = ref.watch(groupByIdProvider(widget.groupId)).maybeWhen(
      data: (g) => g?.currencySymbol ?? '₴',
      orElse: () => '₴',
    );

    // Calculate current debt between selected pair
    double? currentDebt; // positive = fromId owes toId, negative = toId owes fromId
    if (_fromId != null && _toId != null && _fromId != _toId) {
      summaryAsync.whenData((summary) {
        final fwd = summary.settlements
            .where((p) => p.fromId == _fromId && p.toId == _toId)
            .firstOrNull;
        if (fwd != null) {
          currentDebt = fwd.amount;
          return;
        }
        final rev = summary.settlements
            .where((p) => p.fromId == _toId && p.toId == _fromId)
            .firstOrNull;
        if (rev != null) {
          currentDebt = -rev.amount;
          return;
        }
        currentDebt = 0;
      });
    }

    return GradientScaffold(
      appBar:
          AppBar(title: Text(isEdit ? l.editSettlement : l.addSettlement)),
      body: Column(
        children: [
          Expanded(
            child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              initialValue: _fromId,
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
              initialValue: _toId,
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
            if (currentDebt != null) ...[
              const SizedBox(height: 12),
              _DebtHint(
                label: l.currentlyOwes,
                amount: currentDebt!,
                roundAmounts: roundAmounts,
                currency: currency,
              ),
            ],
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.date),
              subtitle: Text(DateFormat('dd.MM.yyyy').format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<int?>(
              initialValue: _categoryId,
              decoration: InputDecoration(labelText: l.category),
              items: [
                DropdownMenuItem<int?>(
                    value: null, child: Text(l.noCategory)),
                ..._categories.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Row(
                        children: [
                          Text(c.icon, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ],
                      ),
                    )),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commentCtrl,
              decoration: InputDecoration(labelText: l.comment),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary,
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l.save,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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

// ── Debt hint widget ──────────────────────────────────────────────────────────

class _DebtHint extends StatelessWidget {
  final String label;
  final double amount; // positive = from owes to, negative = reverse
  final bool roundAmounts;
  final String currency;

  const _DebtHint({
    required this.label,
    required this.amount,
    required this.roundAmounts,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final isReverse = amount < -0.005;
    final isZero = amount.abs() <= 0.005;
    final color = isZero
        ? Colors.grey
        : isReverse
            ? Colors.green
            : Colors.red;
    final displayKop = toKopiykas(amount.abs());
    final amountStr = isZero
        ? formatMoney(0, symbol: currency, round: roundAmounts)
        : isReverse
            ? '-${formatMoney(displayKop, symbol: currency, round: roundAmounts)}'
            : formatMoney(displayKop, symbol: currency, round: roundAmounts);

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color),
        ),
      ),
      child: Text(
        amountStr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
