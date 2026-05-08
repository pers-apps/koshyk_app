import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../groups/data/groups_providers.dart';

class MoreScreen extends ConsumerWidget {
  final int? groupId;
  const MoreScreen({super.key, this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final currency = ref.watch(currencyProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final isUk = (locale?.languageCode ?? Localizations.localeOf(context).languageCode) == 'uk';
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: groupId == null,
      onPopInvokedWithResult: (didPop, __) {
        if (!didPop && context.mounted) context.go('/');
      },
      child: GradientScaffold(
      bottomNavigationBar: groupId != null
          ? AppBottomNav(currentIndex: 3, groupId: groupId!)
          : null,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/logo.png', width: 28, height: 28),
            ),
            const SizedBox(width: 8),
            Flexible(child: Text('${l.appTitle} — ${l.more}')),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Theme toggle
          _SettingsTile(
            icon: isDark ? Icons.dark_mode : Icons.light_mode,
            title: l.theme,
            trailing: Switch(
              value: isDark,
              activeThumbColor: cs.primary,
              onChanged: (val) => ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(val ? ThemeMode.dark : ThemeMode.light),
            ),
          ),
          const Divider(indent: 60, height: 1),
          // Language toggle
          _SettingsTile(
            icon: Icons.language,
            title: l.language,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('EN', style: TextStyle(
                  fontWeight: isUk ? FontWeight.normal : FontWeight.bold,
                  color: isUk ? cs.onSurface.withValues(alpha: 0.4) : cs.primary,
                )),
                Switch(
                  value: isUk,
                  activeThumbColor: cs.primary,
                  onChanged: (val) => ref
                      .read(localeProvider.notifier)
                      .setLocale(Locale(val ? 'uk' : 'en')),
                ),
                Text('УКР', style: TextStyle(
                  fontWeight: isUk ? FontWeight.bold : FontWeight.normal,
                  color: isUk ? cs.primary : cs.onSurface.withValues(alpha: 0.4),
                )),
              ],
            ),
          ),
          const Divider(indent: 60, height: 1),
          // Currency symbol
          _SettingsTile(
            icon: Icons.attach_money,
            title: l.currency,
            trailing: DropdownButton<String>(
              value: currency,
              underline: const SizedBox.shrink(),
              items: kCurrencyOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))))
                  .toList(),
              onChanged: (val) async {
                if (val == null) return;
                await ref.read(currencyProvider.notifier).setCurrency(val);
                await ref.read(groupsDaoProvider).updateCurrencyAll(val);
              },
            ),
          ),
          const Divider(indent: 60, height: 1),
          // Check for updates
          _SettingsTile(
            icon: Icons.system_update_outlined,
            title: l.checkForUpdates,
            onTap: () => _checkForUpdates(context, l),
          ),
          const Divider(indent: 60, height: 1),
          // About app
          _SettingsTile(
            icon: Icons.info_outline,
            title: l.aboutApp,
            onTap: () => _showAboutDialog(context, l),
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _checkForUpdates(BuildContext context, AppLocalizations l) async {
    final upgrader = Upgrader();
    await upgrader.initialize();
    final isUpdateAvailable = upgrader.isUpdateAvailable();
    if (!context.mounted) return;
    if (isUpdateAvailable) {
      showDialog(
        context: context,
        builder: (_) => UpgradeAlert(
          upgrader: upgrader,
          child: const SizedBox.shrink(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.upToDate),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l) async {
    final info = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.appTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${l.version}: ${info.version}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(l.appDescription),
              const SizedBox(height: 12),
              const Text(
                'koshyk.app@proton.me',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.done),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: cs.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
