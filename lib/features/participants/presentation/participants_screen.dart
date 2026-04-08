import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/db/database.dart';
import '../data/participants_providers.dart';
import '../../expenses/data/expenses_providers.dart';
import '../../settlements/data/settlements_providers.dart';

class ParticipantsScreen extends ConsumerWidget {
  final int groupId;
  const ParticipantsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final asyncList = ref.watch(participantsStreamProvider(groupId));

    return Scaffold(
      appBar: AppBar(title: Text(l.participants)),
      body: asyncList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (ctx, i) => _ParticipantTile(
            participant: list[i],
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

  void _showForm(BuildContext context, WidgetRef ref, Participant? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ParticipantForm(
        groupId: groupId,
        existing: existing,
        widgetRef: ref,
      ),
    );
  }
}

class _ParticipantTile extends ConsumerWidget {
  final Participant participant;
  final int groupId;
  const _ParticipantTile({required this.participant, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isActive = participant.isActive;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isActive ? null : Colors.grey,
        child: Text(participant.name.substring(0, 1).toUpperCase()),
      ),
      title: Text(
        participant.name + (isActive ? '' : ' ${l.inactive}'),
        style: TextStyle(color: isActive ? null : Colors.grey),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (val) => _handleMenu(context, ref, val),
        itemBuilder: (_) => [
          PopupMenuItem(value: 'edit', child: Text(l.editParticipant)),
          PopupMenuItem(
            value: 'toggle',
            child: Text(isActive ? l.deactivate : l.activate),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text(l.deleteParticipant,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenu(
      BuildContext context, WidgetRef ref, String action) async {
    final l = AppLocalizations.of(context)!;
    final dao = ref.read(participantsDaoProvider);

    if (action == 'edit') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => _ParticipantForm(
          groupId: groupId,
          existing: participant,
          widgetRef: ref,
        ),
      );
    } else if (action == 'toggle') {
      await dao.updateParticipant(
          participant.copyWith(isActive: !participant.isActive));
    } else if (action == 'delete') {
      final expDao = ref.read(expensesDaoProvider);
      final setDao = ref.read(settlementsDaoProvider);
      final hasExp = await expDao.participantHasExpenses(participant.id);
      final hasSett = await setDao.participantHasSettlements(participant.id);
      if ((hasExp || hasSett) && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.cannotDeleteParticipantHasData)));
        return;
      }
      await dao.updateParticipant(participant.copyWith(isActive: false));
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.deleted)));
      }
    }
  }
}

class _ParticipantForm extends StatefulWidget {
  final int groupId;
  final Participant? existing;
  final WidgetRef widgetRef;
  const _ParticipantForm(
      {required this.groupId, this.existing, required this.widgetRef});

  @override
  State<_ParticipantForm> createState() => _ParticipantFormState();
}

class _ParticipantFormState extends State<_ParticipantForm> {
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
    final name = _nameCtrl.text.trim();
    final dao = widget.widgetRef.read(participantsDaoProvider);

    final exists = await dao.nameExistsInGroup(name, widget.groupId,
        excludeId: widget.existing?.id);
    if (exists && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.duplicateParticipantName)));
      return;
    }

    if (widget.existing == null) {
      await dao.insertParticipant(
        ParticipantsCompanion.insert(groupId: widget.groupId, name: name),
      );
    } else {
      await dao.updateParticipant(widget.existing!.copyWith(name: name));
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
            Text(widget.existing == null ? l.addParticipant : l.editParticipant,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: InputDecoration(labelText: l.participantName),
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
