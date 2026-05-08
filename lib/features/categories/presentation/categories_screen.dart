import '../../../core/widgets/gradient_scaffold.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/db/database.dart';
import '../../../core/widgets/onboarding_progress_bar.dart';
import '../../../core/providers/onboarding_state.dart';
import '../data/categories_providers.dart';
import '../../expenses/data/expenses_providers.dart';
import '../../settlements/data/settlements_providers.dart';
import '../../groups/data/groups_providers.dart';

const _kCategoryColors = [
  0xFFE53935, // red
  0xFFFF7043, // orange
  0xFFFFCA28, // amber
  0xFF66BB6A, // green
  0xFF26A69A, // teal
  0xFF2196F3, // blue
  0xFF5C6BC0, // indigo
  0xFFAB47BC, // purple
  0xFFEC407A, // pink
  0xFF90A4AE, // grey
];

class CategoriesScreen extends ConsumerWidget {
  final int groupId;
  final bool isOnboarding;
  const CategoriesScreen({
    super.key,
    required this.groupId,
    this.isOnboarding = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final asyncList = ref.watch(categoriesStreamProvider(groupId));
    final groupName = ref.watch(groupStreamByIdProvider(groupId)).maybeWhen(
      data: (g) => g?.name ?? '',
      orElse: () => '',
    );

    return GradientScaffold(
      appBar: AppBar(
        title: Text(groupName.isNotEmpty ? '$groupName — ${l.categories}' : l.categories),
        actions: isOnboarding
            ? [
                TextButton(
                  onPressed: () {
                    onboardingGroupId = null;
                    context.go('/group/$groupId/expenses');
                  },
                  child: Text(l.done,
                      style: const TextStyle(color: Colors.white)),
                ),
              ]
            : null,
      ),
      bottomNavigationBar: isOnboarding
          ? const OnboardingProgressBar(currentStep: 2)
          : null,
      body: asyncList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          final hint = isOnboarding ? l.onboardingCategoriesHint : l.noCategoriesHint;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.75), fontSize: 15),
                ),
              ),
              if (list.isEmpty)
                const Expanded(child: SizedBox())
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (ctx, i) => _CategoryTile(
                      category: list[i],
                      groupId: groupId,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, Category? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _CategoryForm(groupId: groupId, existing: existing, widgetRef: ref),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  final Category category;
  final int groupId;
  const _CategoryTile({required this.category, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final color = Color(category.color);
    return Dismissible(
      key: Key('category_${category.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final currentCount = ref.read(categoriesStreamProvider(groupId)).value?.length ?? 0;
        if (!context.mounted) return false;
        if (currentCount <= 1) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l.minOneCategoryRequired)));
          return false;
        }
        final inUse =
            await ref.read(categoriesDaoProvider).isUsedInExpenses(category.id);
        if (!context.mounted) return false;
        if (inUse) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l.cannotDeleteCategoryInUse)));
          return false;
        }
        final result = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(l.delete),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l.cancel)),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l.delete,
                      style: const TextStyle(color: Colors.red))),
            ],
          ),
        );
        return result == true;
      },
      onDismissed: (_) async {
        await ref.read(expensesDaoProvider).nullifyCategoryExpenses(category.id);
        await ref
            .read(settlementsDaoProvider)
            .nullifyCategorySettlements(category.id);
        await ref.read(categoriesDaoProvider).deleteCategory(category.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l.deleted)));
        }
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(category.icon, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(category.name),
        trailing: PopupMenuButton<String>(
          onSelected: (v) => _handle(context, ref, v),
          itemBuilder: (_) => [
            PopupMenuItem(value: 'edit', child: Text(l.editCategory)),
            PopupMenuItem(
                value: 'delete',
                child: Text(l.delete,
                    style: const TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  Future<void> _handle(
      BuildContext context, WidgetRef ref, String action) async {
    final l = AppLocalizations.of(context)!;
    if (action == 'edit') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => _CategoryForm(
            groupId: groupId, existing: category, widgetRef: ref),
      );
    } else if (action == 'delete') {
      final currentCount = ref.read(categoriesStreamProvider(groupId)).value?.length ?? 0;
      if (currentCount <= 1 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.minOneCategoryRequired)));
        return;
      }
      final inUse =
          await ref.read(categoriesDaoProvider).isUsedInExpenses(category.id);
      if (inUse && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.cannotDeleteCategoryInUse)));
        return;
      }
      await ref.read(expensesDaoProvider).nullifyCategoryExpenses(category.id);
      await ref
          .read(settlementsDaoProvider)
          .nullifyCategorySettlements(category.id);
      await ref.read(categoriesDaoProvider).deleteCategory(category.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.deleted)));
      }
    }
  }
}

class _CategoryForm extends StatefulWidget {
  final int groupId;
  final Category? existing;
  final WidgetRef widgetRef;
  const _CategoryForm(
      {required this.groupId, this.existing, required this.widgetRef});

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _iconCtrl;
  late int _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _iconCtrl =
        TextEditingController(text: widget.existing?.icon ?? '🏷️');
    _selectedColor = widget.existing?.color ?? _kCategoryColors.first;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context)!;
    final dao = widget.widgetRef.read(categoriesDaoProvider);
    final icon = _iconCtrl.text.trim().isEmpty ? '🏷️' : _iconCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    final isDuplicate = await dao.nameExistsInGroup(
      name,
      widget.groupId,
      excludeId: widget.existing?.id,
    );
    if (isDuplicate && mounted) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          content: Text(l.duplicateCategoryName),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.confirm),
            ),
          ],
        ),
      );
      return;
    }

    if (widget.existing == null) {
      final count = await dao.countByGroup(widget.groupId);
      if (count >= 10 && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.maxCategoriesReached)));
        return;
      }
      await dao.insertCategory(
        CategoriesCompanion.insert(
          groupId: widget.groupId,
          name: name,
          icon: Value(icon),
          color: Value(_selectedColor),
        ),
      );
    } else {
      await dao.updateCategory(widget.existing!.copyWith(
        name: name,
        icon: icon,
        color: _selectedColor,
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                widget.existing == null ? l.addCategory : l.editCategory,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextFormField(
              controller: _iconCtrl,
              decoration: InputDecoration(labelText: l.categoryIcon),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: InputDecoration(labelText: l.categoryName),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.required : null,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(l.categoryColor,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      )),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kCategoryColors.map((c) {
                final isSelected = c == _selectedColor;
                // Colors used by other categories in this group
                final usedColors = <int>{
                  for (final cat in widget.widgetRef
                      .read(categoriesStreamProvider(widget.groupId))
                      .value ?? [])
                    if (cat.id != widget.existing?.id) cat.color,
                };
                final isUsed = usedColors.contains(c);
                return GestureDetector(
                  onTap: isUsed ? null : () => setState(() => _selectedColor = c),
                  child: Opacity(
                    opacity: isUsed ? 0.28 : 1.0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 3,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 18)
                          : isUsed
                              ? const Icon(Icons.block,
                                  color: Colors.white, size: 16)
                              : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}
