import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/app_providers.dart';
import 'generated/app_localizations.dart';
import 'router.dart';
import 'theme.dart';
import 'ui_style.dart';

class OpenTavernApp extends ConsumerWidget {
  const OpenTavernApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final languagePreference = ref.watch(languagePreferenceProvider);
    final lightTheme = buildOpenTavernTheme(brightness: Brightness.light);
    final darkTheme = buildOpenTavernTheme(brightness: Brightness.dark);
    final platformBrightness =
        View.of(context).platformDispatcher.platformBrightness;
    final effectiveTheme = switch (themeMode) {
      ThemeMode.light => lightTheme,
      ThemeMode.dark => darkTheme,
      ThemeMode.system => platformBrightness == Brightness.dark
          ? darkTheme
          : lightTheme,
    };
    OTStyle.setActiveColors(effectiveTheme.extension<OTThemeColors>()!);

    Locale? resolveLocale(Locale? locale, Iterable<Locale> supportedLocales) {
      switch (languagePreference) {
        case AppLanguagePreference.en:
          return const Locale('en');
        case AppLanguagePreference.zh:
          return const Locale('zh');
        case AppLanguagePreference.system:
          if (locale == null) return const Locale('en');
          for (final supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
          return const Locale('en');
      }
    }

    return MaterialApp.router(
      title: 'OpenTavern',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
      localeResolutionCallback: resolveLocale,
    );
  }
}
