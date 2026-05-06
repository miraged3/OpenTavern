import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ui_style.dart';

ThemeData buildOpenTavernTheme({required Brightness brightness}) {
  const primary = Color(0xFF111111);
  final isDark = brightness == Brightness.dark;
  final background = isDark ? const Color(0xFF0B0B0C) : const Color(0xFFFAFAFA);
  final surface = isDark ? const Color(0xFF121214) : Colors.white;
  final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE5E7EB);
  final mutedFill = isDark ? const Color(0xFF1C1C20) : const Color(0xFFF3F4F6);
  final primaryText = isDark ? Colors.white : primary;
  final secondaryText = isDark
      ? const Color(0xFFA1A1AA)
      : const Color(0xFF6B7280);
  final tertiaryText = isDark
      ? const Color(0xFF71717A)
      : const Color(0xFF9CA3AF);
  final strongBorder = isDark
      ? const Color(0xFF3F3F46)
      : const Color(0xFFD1D5DB);
  final inverseText = isDark ? primary : Colors.white;
  final accent = isDark ? const Color(0xFF8AB4FF) : const Color(0xFF2563EB);

  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: brightness,
    surface: surface,
  );
  final fontFamily = OTStyle.fontFamily;
  final fontFamilyFallback = OTStyle.fontFamilyFallback;
  final baseTheme = ThemeData(
    colorScheme: scheme,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    useMaterial3: true,
  );
  final textTheme = baseTheme.textTheme.apply(
    bodyColor: primaryText,
    displayColor: primaryText,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
  );

  return baseTheme.copyWith(
    scaffoldBackgroundColor: background,
    extensions: <ThemeExtension<dynamic>>[
      OTThemeColors(
        pageBackground: background,
        surface: surface,
        primaryText: primaryText,
        secondaryText: secondaryText,
        tertiaryText: tertiaryText,
        border: border,
        strongBorder: strongBorder,
        mutedFill: mutedFill,
        danger: const Color(0xFFEF4444),
        warning: const Color(0xFFB54708),
        success: const Color(0xFF10B981),
        inProgress: const Color(0xFF8B5CF6),
        inverseText: inverseText,
        accent: accent,
        infoBanner: isDark ? const Color(0xFF18181B) : const Color(0xFFF9FAFB),
        quoteBackground: isDark
            ? const Color(0xFF18181B)
            : const Color(0xFFF9FAFB),
        systemFill: isDark ? const Color(0xFF1F2937) : const Color(0xFFF2F2F7),
        shadowScrim: isDark ? const Color(0xE61A1A1C) : const Color(0xE6FFFFFF),
      ),
    ],
    textTheme: textTheme.copyWith(
      headlineSmall: textTheme.headlineSmall?.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.45),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: primaryText,
      elevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: primaryText,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      toolbarTextStyle: textTheme.bodyMedium?.copyWith(color: primaryText),
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      textTheme: CupertinoTextThemeData(
        textStyle: OTStyle.textStyle(color: primaryText, fontSize: 17),
        actionTextStyle: OTStyle.textStyle(
          color: accent,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        tabLabelTextStyle: OTStyle.textStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        navTitleTextStyle: OTStyle.textStyle(
          color: primaryText,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        navLargeTitleTextStyle: OTStyle.textStyle(
          color: primaryText,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      height: 62,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStatePropertyAll(
        OTStyle.textStyle(color: secondaryText, fontWeight: FontWeight.w600),
      ),
    ),
    dividerTheme: DividerThemeData(color: border, thickness: 1),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryText, width: 1.2),
      ),
      hintStyle: OTStyle.textStyle(color: secondaryText),
      prefixIconColor: secondaryText,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryText,
        foregroundColor: inverseText,
        elevation: 0,
        textStyle: OTStyle.textStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryText,
        side: BorderSide(color: strongBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryText,
        textStyle: OTStyle.textStyle(fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: mutedFill,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: OTStyle.textStyle(
        color: primaryText,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
