import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/db/database.dart';
import '../data/groups_providers.dart';
import '../../categories/data/categories_providers.dart';

class GroupFormScreen extends ConsumerStatefulWidget {
  final int? groupId;
  const GroupFormScreen({super.key, this.groupId});

  @override
  ConsumerState<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends ConsumerState<GroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController(text: '₴');
  Group? _existing;
  bool _loading = false;

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
        _currencyCtrl.text = g.currencySymbol;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final l = AppLocalizations.of(context)!;
    final name = _nameCtrl.text.trim();
    final currency = _currencyCtrl.text.trim().isEmpty ? '₴' : _currencyCtrl.text.trim();
    final dao = ref.read(groupsDaoProvider);

    final exists = await dao.nameExists(name, excludeId: widget.groupId);
    if (exists && mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.duplicateGroupName)));
      return;
    }

    if (_existing == null) {
      final id = await dao.insertGroup(
        GroupsCompanion.insert(name: name, currencySymbol: Value(currency)),
      );
      // Create default categories
      final catDao = ref.read(categoriesDaoProvider);
      const defaults = ['Харчування', 'Робота', 'Проживання'];
      for (final cat in defaults) {
        await catDao.insertCategory(
          CategoriesCompanion.insert(groupId: id, name: cat),
        );
      }
    } else {
      await dao.updateGroup(_existing!.copyWith(name: name, currencySymbol: currency));
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isEdit = widget.groupId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? l.editGroup : l.newGroup)),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _currencyCtrl,
                decoration: InputDecoration(labelText: l.currency),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const CircularProgressIndicator()
                    : Text(l.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
