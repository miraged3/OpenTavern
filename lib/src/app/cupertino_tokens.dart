import 'package:flutter/cupertino.dart';

abstract final class OTCupertinoColors {
  static const pageBackground = CupertinoColors.systemGroupedBackground;
  static const groupedBackground = CupertinoColors.systemGrey6;
  static const elevatedBackground =
      CupertinoColors.secondarySystemGroupedBackground;
  static const separator = CupertinoColors.separator;
  static const primaryText = Color(0xFF111111);
  static const secondaryText = Color(0xFF6E6E73);
  static const tertiaryText = Color(0xFF8E8E93);
  static const accent = CupertinoColors.activeBlue;
}

abstract final class OTCupertinoMetrics {
  static const horizontalPadding = 16.0;
  static const sectionRadius = 14.0;
  static const hairlineWidth = 0.5;
}
