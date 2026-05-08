import '../../../core/widgets/gradient_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../data/groups_providers.dart';
import '../../../core/utils/money.dart';
import '../../expenses/data/expenses_providers.dart';

const kFreeGroupLimit = 1;

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  bool _archiveExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoOpenLastGroup());
  }

  Future<void> _autoOpenLastGroup() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final lastId = prefs.getInt('last_group_id');
    if (lastId == null || !mounted) return;
    final group = await ref.read(groupsDaoProvider).getById(lastId);
    if (group == null || !mounted) return;
    context.push('/group/$lastId/expenses');
  }

  Future<void> _onCreateGroup() async {
    // Free-plan limit disabled for v1.0 (Phase 1: all users have full access).
    if (mounted) context.push('/group/new');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final activeAsync = ref.watch(activeGroupsStreamProvider);
    final archivedAsync = ref.watch(archivedGroupsStreamProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final exit = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(l.exitAppTitle),
            content: Text(l.exitAppConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.exitApp,
                    style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (exit == true) {
          SystemNavigator.pop();
        }
      },
      child: GradientScaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/logo.png', width: 28, height: 28),
              ),
              const SizedBox(width: 8),
              Flexible(child: Text(l.appTitleTagline)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () => context.push('/more'),
            ),
          ],
        ),
        body: activeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (active) {
            final archived = archivedAsync.maybeWhen(
              data: (list) => list,
              orElse: () => <dynamic>[],
            );

            if (active.isEmpty && archived.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l.createFirstGroupTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 12),
                      Text(
                        l.createFirstGroupSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton.icon(
                        onPressed: _onCreateGroup,
                        icon: const Icon(Icons.add),
                        label: Text(l.newGroup),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              children: [
                ...active.map((g) => _SwipeableGroupTile(
                      groupId: g.id,
                      name: g.name,
                      currency: g.currencySymbol,
                      isArchived: false,
                      roundAmounts: g.roundAmounts,
                    )),
                if (archived.isNotEmpty) ...[
                  const Divider(height: 1),
                  // Collapsed/expanded archive header
                  InkWell(
                    onTap: () =>
                        setState(() => _archiveExpanded = !_archiveExpanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          AnimatedRotation(
                            turns: _archiveExpanded ? 0.25 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(Icons.chevron_right,
                                size: 18, color: Colors.grey.shade500),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${l.archivedGroups} (${archived.length})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_archiveExpanded)
                    ...archived.map((g) => _SwipeableGroupTile(
                          groupId: g.id,
                          name: g.name,
                          currency: g.currencySymbol,
                          isArchived: true,
                          roundAmounts: g.roundAmounts,
                        )),
                ],
              ],
            );
          },
        ),
        floatingActionButton: _GlowFab(onTap: _onCreateGroup),
      ),
    );
  }
}

class _GlowFab extends StatelessWidget {
  final VoidCallback onTap;
  const _GlowFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 18,
            spreadRadius: 3,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onTap,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

class _SwipeableGroupTile extends ConsumerWidget {
  final int groupId;
  final String name;
  final String currency;
  final bool isArchived;
  final bool roundAmounts;

  const _SwipeableGroupTile({
    required this.groupId,
    required this.name,
    required this.currency,
    required this.isArchived,
    required this.roundAmounts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;

    return Dismissible(
      key: Key('group_$groupId'),
      background: Container(
        color: Colors.blueGrey,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Icon(
          isArchived ? Icons.unarchive : Icons.archive,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(l.deleteGroup),
              content: Text(l.deleteGroupConfirm(name)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l.delete,
                      style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
          return confirmed == true;
        } else {
          // Free-plan limit disabled for v1.0 (Phase 1: all users have full access).
          return true;
        }
      },
      onDismissed: (direction) async {
        final dao = ref.read(groupsDaoProvider);
        if (direction == DismissDirection.startToEnd) {
          await dao.archiveGroup(groupId, archive: !isArchived);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    isArchived ? l.groupUnarchived : l.groupArchived),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: l.undo,
                  onPressed: () => dao.archiveGroup(groupId, archive: isArchived),
                ),
              ),
            );
          }
        } else {
          await dao.deleteGroup(groupId);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l.deleted),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      },
      child: _GroupTileContent(
        groupId: groupId,
        name: name,
        currency: currency,
        isArchived: isArchived,
        roundAmounts: roundAmounts,
      ),
    );
  }
}

class _GroupTileContent extends ConsumerWidget {
  final int groupId;
  final String name;
  final String currency;
  final bool isArchived;
  final bool roundAmounts;

  const _GroupTileContent({
    required this.groupId,
    required this.name,
    required this.currency,
    required this.isArchived,
    required this.roundAmounts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final expensesAsync = ref.watch(expensesStreamProvider(groupId));

    final total = expensesAsync.maybeWhen(
      data: (list) => list.fold<int>(0, (s, e) => s + e.amountKop),
      orElse: () => 0,
    );

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isArchived ? Colors.grey.shade300 : null,
        child: Icon(
          Icons.group,
          color: isArchived ? Colors.grey.shade500 : null,
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isArchived ? Colors.grey.shade500 : null,
        ),
      ),
      subtitle: Text(
        '${l.totalExpenses}: ${formatMoney(total, symbol: currency, round: roundAmounts)}',
        style: TextStyle(color: isArchived ? Colors.grey.shade400 : null),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('last_group_id', groupId);
        if (context.mounted) context.push('/group/$groupId/expenses');
      },
    );
  }
}

