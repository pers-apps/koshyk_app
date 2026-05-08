import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

import 'core/db/database.dart';
import 'core/db/app_settings_dao.dart';
import 'core/providers/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'l10n/app_localizations.dart';

const _firstLaunchKey = 'first_launch_date';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Record first_launch_date on very first run.
  // Required for grandfather-premium logic in v2.0.
  // Dual storage: SharedPreferences (survives reinstall via Auto Backup) + SQLite (fallback).
  final prefs = await SharedPreferences.getInstance();
  var stored = prefs.getString(_firstLaunchKey);
  if (stored == null) {
    stored = DateTime.now().toIso8601String();
    await prefs.setString(_firstLaunchKey, stored);
  }
  // SQLite copy for compatibility with existing code
  final db = AppDatabase();
  final sqliteValue = await db.getSetting(_firstLaunchKey);
  if (sqliteValue == null) {
    await db.setSetting(_firstLaunchKey, stored);
  }
  await db.close();

  runApp(const ProviderScope(child: KoshykApp()));
}

class KoshykApp extends ConsumerWidget {
  const KoshykApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return UpgradeAlert(
      upgrader: Upgrader(
        durationUntilAlertAgain: const Duration(days: 1),
      ),
      child: MaterialApp.router(
        title: 'Кошик',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        locale: locale,
        routerConfig: appRouter,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('uk'),
          Locale('en'),
        ],
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          if (deviceLocale == null) return const Locale('en');
          final lang = deviceLocale.languageCode;
          if (lang == 'uk') return const Locale('uk');
          if (lang == 'ru') return const Locale('uk');
          if (lang == 'en') return const Locale('en');
          return const Locale('en');
        },
      ),
    );
  }
}
