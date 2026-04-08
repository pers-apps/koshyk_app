import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/db/database.dart';
import '../data/categories_providers.dart';
import '../../expenses/data/expenses_providers.dart';
import '../../settlements/data/settlements_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  final int groupId;
  const CategoriesScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final asyncList = ref.watch(categoriesStreamProvider(groupId));

    return Scaffold(
      appBar: AppBar(title: Text(l.categories)),
      body: asyncList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (ctx, i) => _CategoryTile(
            category: list[i],
            groupId: groupId,
          ),
        ),
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
    return ListTile(
      leading: const Icon(Icons.label),
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

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context)!;
    final dao = widget.widgetRef.read(categoriesDaoProvider);

    if (widget.existing == null) {
      final count = await dao.countByGroup(widget.groupId);
      if (count >= 10 && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.maxCategoriesReached)));
        return;
      }
      await dao.insertCategory(
        CategoriesCompanion.insert(
            groupId: widget.groupId, name: _nameCtrl.text.trim()),
      );
    } else {
      await dao.updateCategory(
          widget.existing!.copyWith(name: _nameCtrl.text.trim()));
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
              controller: _nameCtrl,
              autofocus: true,
              decoration: InputDecoration(labelText: l.categoryName),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.required : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}
