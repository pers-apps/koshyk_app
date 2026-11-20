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
import '../../../core/widgets/group_avatar.dart';
import '../data/group_icon_storage.dart';
import 'group_icon_picker.dart';

// (icon, name, color ARGB)
List<(String, String, int)> _defaultCategories(AppLocalizations l) => [
  ('🏠', l.defaultCategoryAccommodation, 0xFF66BB6A), // green
  ('🍽️', l.defaultCategoryFood,          0xFFFF7043), // orange
  ('💼', l.defaultCategoryWork,          0xFF5C6BC0), // indigo
  ('🚗', l.defaultCategoryTransport,     0xFF2196F3), // blue
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

  // Group icon (REMARKS #145)
  String? _iconEmoji;
  String? _iconImage;
  String? _originalImage; // photo stored before this edit session
  final List<String> _sessionImages = []; // photos saved during this session
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_onNameChanged);
    if (widget.groupId != null) _loadExisting();
  }

  // Letter avatar follows the typed name.
  void _onNameChanged() {
    if (_iconEmoji == null && _iconImage == null) setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_onNameChanged);
    _nameCtrl.dispose();
    // Form left without saving → drop photos picked in this session.
    if (!_saved) {
      for (final f in _sessionImages) {
        GroupIconStorage.delete(f);
      }
    }
    super.dispose();
  }

  Future<void> _pickIcon() async {
    final choice = await showGroupIconPicker(
      context,
      hasIcon: _iconEmoji != null || _iconImage != null,
    );
    if (choice == null || !mounted) return;
    setState(() {
      switch (choice) {
        case GroupIconEmoji(:final emoji):
          _iconEmoji = emoji;
          _iconImage = null;
        case GroupIconPhoto(:final fileName):
          _sessionImages.add(fileName);
          _iconImage = fileName;
          _iconEmoji = null;
        case GroupIconRemove():
          _iconEmoji = null;
          _iconImage = null;
      }
    });
  }

  /// After a successful save: delete photos that are no longer used.
  void _cleanupUnusedPhotos() {
    _saved = true;
    final unused = <String>{
      ..._sessionImages,
      if (_originalImage != null) _originalImage!,
    }..remove(_iconImage);
    for (final f in unused) {
      GroupIconStorage.delete(f);
    }
  }

  Future<void> _loadExisting() async {
    final dao = ref.read(groupsDaoProvider);
    final g = await dao.getById(widget.groupId!);
    if (g != null && mounted) {
      setState(() {
        _existing = g;
        _nameCtrl.text = g.name;
        _roundAmounts = g.roundAmounts;
        _iconEmoji = g.iconEmoji;
        _iconImage = g.iconImage;
        _originalImage = g.iconImage;
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
          iconEmoji: Value(_iconEmoji),
          iconImage: Value(_iconImage),
        ),
      );
      _cleanupUnusedPhotos();
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
        iconEmoji: Value(_iconEmoji),
        iconImage: Value(_iconImage),
      ));
      _cleanupUnusedPhotos();
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
              // Group icon (REMARKS #145): tap to choose emoji / photo.
              Tooltip(
                message: AppLocalizations.of(context)!.groupIcon,
                child: InkWell(
                  key: const ValueKey('group-icon-picker'),
                  customBorder: const CircleBorder(),
                  onTap: _pickIcon,
                  child: Stack(
                    children: [
                      GroupAvatar(
                        name: _nameCtrl.text,
                        iconEmoji: _iconEmoji,
                        iconImage: _iconImage,
                        size: 88,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Icon(Icons.edit,
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
