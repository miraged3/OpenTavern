import 'package:flutter/material.dart';

@immutable
class OTThemeColors extends ThemeExtension<OTThemeColors> {
  const OTThemeColors({
    required this.pageBackground,
    required this.surface,
    required this.primaryText,
    required this.secondaryText,
    required this.tertiaryText,
    required this.border,
    required this.strongBorder,
    required this.mutedFill,
    required this.danger,
    required this.warning,
    required this.success,
    required this.inProgress,
    required this.inverseText,
    required this.accent,
    required this.infoBanner,
    required this.quoteBackground,
    required this.systemFill,
    required this.shadowScrim,
  });

  final Color pageBackground;
  final Color surface;
  final Color primaryText;
  final Color secondaryText;
  final Color tertiaryText;
  final Color border;
  final Color strongBorder;
  final Color mutedFill;
  final Color danger;
  final Color warning;
  final Color success;
  final Color inProgress;
  final Color inverseText;
  final Color accent;
  final Color infoBanner;
  final Color quoteBackground;
  final Color systemFill;
  final Color shadowScrim;

  @override
  OTThemeColors copyWith({
    Color? pageBackground,
    Color? surface,
    Color? primaryText,
    Color? secondaryText,
    Color? tertiaryText,
    Color? border,
    Color? strongBorder,
    Color? mutedFill,
    Color? danger,
    Color? warning,
    Color? success,
    Color? inProgress,
    Color? inverseText,
    Color? accent,
    Color? infoBanner,
    Color? quoteBackground,
    Color? systemFill,
    Color? shadowScrim,
  }) {
    return OTThemeColors(
      pageBackground: pageBackground ?? this.pageBackground,
      surface: surface ?? this.surface,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      tertiaryText: tertiaryText ?? this.tertiaryText,
      border: border ?? this.border,
      strongBorder: strongBorder ?? this.strongBorder,
      mutedFill: mutedFill ?? this.mutedFill,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      inProgress: inProgress ?? this.inProgress,
      inverseText: inverseText ?? this.inverseText,
      accent: accent ?? this.accent,
      infoBanner: infoBanner ?? this.infoBanner,
      quoteBackground: quoteBackground ?? this.quoteBackground,
      systemFill: systemFill ?? this.systemFill,
      shadowScrim: shadowScrim ?? this.shadowScrim,
    );
  }

  @override
  OTThemeColors lerp(ThemeExtension<OTThemeColors>? other, double t) {
    if (other is! OTThemeColors) {
      return this;
    }
    return OTThemeColors(
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      tertiaryText: Color.lerp(tertiaryText, other.tertiaryText, t)!,
      border: Color.lerp(border, other.border, t)!,
      strongBorder: Color.lerp(strongBorder, other.strongBorder, t)!,
      mutedFill: Color.lerp(mutedFill, other.mutedFill, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      inProgress: Color.lerp(inProgress, other.inProgress, t)!,
      inverseText: Color.lerp(inverseText, other.inverseText, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      infoBanner: Color.lerp(infoBanner, other.infoBanner, t)!,
      quoteBackground: Color.lerp(quoteBackground, other.quoteBackground, t)!,
      systemFill: Color.lerp(systemFill, other.systemFill, t)!,
      shadowScrim: Color.lerp(shadowScrim, other.shadowScrim, t)!,
    );
  }
}

extension OTThemeContext on BuildContext {
  OTThemeColors get otColors => Theme.of(this).extension<OTThemeColors>()!;
}

abstract final class OTStyle {
  static OTThemeColors _activeColors = const OTThemeColors(
    pageBackground: Color(0xFFFAFAFA),
    surface: Colors.white,
    primaryText: Color(0xFF111111),
    secondaryText: Color(0xFF6B7280),
    tertiaryText: Color(0xFF9CA3AF),
    border: Color(0xFFE5E7EB),
    strongBorder: Color(0xFFD1D5DB),
    mutedFill: Color(0xFFF3F4F6),
    danger: Color(0xFFEF4444),
    warning: Color(0xFFB54708),
    success: Color(0xFF10B981),
    inProgress: Color(0xFF8B5CF6),
    inverseText: Colors.white,
    accent: Color(0xFF2563EB),
    infoBanner: Color(0xFFF9FAFB),
    quoteBackground: Color(0xFFF9FAFB),
    systemFill: Color(0xFFF2F2F7),
    shadowScrim: Color(0xE6FFFFFF),
  );

  static const horizontalPadding = 16.0;
  static const cardRadius = 12.0;
  static const rowMinHeight = 52.0;

  static void setActiveColors(OTThemeColors colors) {
    _activeColors = colors;
  }

  static Color get pageBackground => _activeColors.pageBackground;
  static Color get surface => _activeColors.surface;
  static Color get primaryText => _activeColors.primaryText;
  static Color get secondaryText => _activeColors.secondaryText;
  static Color get tertiaryText => _activeColors.tertiaryText;
  static Color get border => _activeColors.border;
  static Color get strongBorder => _activeColors.strongBorder;
  static Color get mutedFill => _activeColors.mutedFill;
  static Color get danger => _activeColors.danger;
  static Color get warning => _activeColors.warning;
  static Color get success => _activeColors.success;
  static Color get inProgress => _activeColors.inProgress;
  static Color get inverseText => _activeColors.inverseText;
  static Color get accent => _activeColors.accent;
  static Color get infoBanner => _activeColors.infoBanner;
  static Color get quoteBackground => _activeColors.quoteBackground;
  static Color get systemFill => _activeColors.systemFill;
  static Color get shadowScrim => _activeColors.shadowScrim;

  static OutlinedBorder get pillShape => const StadiumBorder();

  static BoxDecoration cardDecoration(
    BuildContext context, {
    Color? borderColor,
    Color? backgroundColor,
  }) {
    final colors = context.otColors;
    return BoxDecoration(
      color: backgroundColor ?? colors.surface,
      border: Border.all(color: borderColor ?? colors.border),
      borderRadius: BorderRadius.circular(cardRadius),
    );
  }

  static BoxDecoration flatGroupDecoration(BuildContext context) {
    final colors = context.otColors;
    return BoxDecoration(
      color: colors.surface,
      border: Border(
        top: BorderSide(color: colors.border),
        bottom: BorderSide(color: colors.border),
      ),
    );
  }

  static BoxDecoration get flatGroupDecorationStatic => BoxDecoration(
    color: surface,
    border: Border(
      top: BorderSide(color: border),
      bottom: BorderSide(color: border),
    ),
  );
}
