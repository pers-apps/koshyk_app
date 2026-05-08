import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

/// Bottom navigation bar shown inside a group context.
/// Always has a groupId. 4 tabs: Expenses | Summary | Settlements | More.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final int groupId;
  final List<GlobalKey?>? tabKeys;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.groupId,
    this.tabKeys,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final tabs = [
      _TabDef(icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long, label: l.expenses),
      _TabDef(icon: Icons.pie_chart_outline, selectedIcon: Icons.pie_chart, label: l.summary),
      _TabDef(icon: Icons.swap_horiz, selectedIcon: Icons.swap_horiz, label: l.settlements),
      _TabDef(icon: Icons.more_horiz, selectedIcon: Icons.more_horiz, label: l.more),
    ];

    return Material(
      color: cs.surfaceContainer,
      elevation: 3,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final tab = tabs[i];
              final selected = i == currentIndex;
              final color = selected ? cs.primary : cs.onSurface.withValues(alpha: 0.65);

              return Expanded(
                child: InkWell(
                  key: tabKeys != null && tabKeys!.length > i ? tabKeys![i] : null,
                  onTap: () => _onTap(context, i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(selected ? tab.selectedIcon : tab.icon, color: color, size: 24),
                      const SizedBox(height: 2),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int i) {
    if (i == currentIndex) return;
    switch (i) {
      case 0: context.go('/group/$groupId/expenses');
      case 1: context.go('/group/$groupId/summary');
      case 2: context.go('/group/$groupId/settlements');
      case 3: context.go('/more?groupId=$groupId');
    }
  }
}

class _TabDef {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _TabDef({required this.icon, required this.selectedIcon, required this.label});
}
