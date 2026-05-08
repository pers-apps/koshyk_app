import '../../../core/widgets/gradient_scaffold.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/db/database.dart';
import '../../../core/widgets/onboarding_progress_bar.dart';
import '../../../core/providers/onboarding_state.dart';
import '../data/groups_providers.dart';
// kFreeGroupLimit import removed — limits disabled for v1.0
import '../../categories/data/categories_providers.dart';
import '../../../core/providers/currency_provider.dart';

// (icon, name, color ARGB)
List<(String, String, int)> _defaultCategories(AppLocalizations l) => [
  ('🏠', l.defaultCategoryAccommodation, 0xFF66BB6A), // green
  ('🍽️', l.defaultCategoryFood,          0xFFFF7043), // orange
  ('🚗', l.defaultCategoryWork,          0xFF2196F3), // blue
];

class GroupFormScreen extends ConsumerStatefulWidget {
  final int? groupId;
  const GroupFormScreen({super.key, this.groupId});

  @override
  ConsumerState<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends ConsumerState<GroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  Group? _existing;
  bool _loading = false;
  bool _roundAmounts = true;

  @override
  void initState() {
    super.initState();
    if (widget.groupId != null) _loadExisting();
  }

  Future<void> _loadExisting() async {
    final dao = ref.read(groupsDaoProvider);
    final g = await dao.getById(widget.groupId!);
    if (g != null && mounted) {
      setState(() {
        _existing = g;
        _nameCtrl.text = g.name;
        _roundAmounts = g.roundAmounts;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final l = AppLocalizations.of(context)!;
    final name = _nameCtrl.text.trim();
    final dao = ref.read(groupsDaoProvider);

    final exists = await dao.nameExists(name, excludeId: widget.groupId);
    if (exists && mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.duplicateGroupName)));
      return;
    }

    if (_existing == null) {
      // Free-plan limit disabled for v1.0 (Phase 1: all users have full access).
      final defaultCurrency = ref.read(currencyProvider);
      final id = await dao.insertGroup(
        GroupsCompanion.insert(
          name: name,
          roundAmounts: Value(_roundAmounts),
          currencySymbol: Value(defaultCurrency),
        ),
      );
      // Create default categories with icons
      final catDao = ref.read(categoriesDaoProvider);
      for (final cat in _defaultCategories(l)) {
        await catDao.insertCategory(
          CategoriesCompanion.insert(
            groupId: id,
            name: cat.$2,
            icon: Value(cat.$1),
            color: Value(cat.$3),
          ),
        );
      }
      onboardingGroupId = id;
      if (mounted) context.pushReplacement('/group/$id/participants');
    } else {
      await dao.updateGroup(_existing!.copyWith(
        name: name,
        roundAmounts: _roundAmounts,
      ));
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isEdit = widget.groupId != null;
    return GradientScaffold(
      appBar: AppBar(title: Text(isEdit ? l.editGroup : l.newGroup)),
      bottomNavigationBar: isEdit
          ? null
          : const OnboardingProgressBar(currentStep: 0),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                autofocus: true,
                decoration: InputDecoration(labelText: l.groupName),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l.required : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.roundingEnabled),
                value: _roundAmounts,
                onChanged: (v) => setState(() => _roundAmounts = v),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  l.equalSharingInfo,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const CircularProgressIndicator()
                    : Text(isEdit ? l.save : l.nextStep),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
