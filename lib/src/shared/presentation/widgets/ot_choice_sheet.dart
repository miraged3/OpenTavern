import 'package:flutter/material.dart';

import '../../../app/ui_style.dart';

class OtActionSheetItem {
  const OtActionSheetItem({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
}

Future<T?> showOtChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> values,
  required String Function(T value) labelBuilder,
}) {
  final colors = context.otColors;
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: colors.pageBackground,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (context) {
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
              child: Text(
                title,
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            for (final value in values)
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  labelBuilder(value),
                  style: TextStyle(color: colors.primaryText),
                ),
                onTap: () => Navigator.pop(context, value),
              ),
          ],
        ),
      );
    },
  );
}

Future<void> showOtActionSheet({
  required BuildContext context,
  required String title,
  required List<OtActionSheetItem> items,
}) {
  final colors = context.otColors;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: colors.pageBackground,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (context) {
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
              child: Text(
                title,
                style: TextStyle(
                  color: colors.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            for (final item in items)
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    color: item.isDestructive
                        ? colors.danger
                        : colors.primaryText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  item.onTap();
                },
              ),
          ],
        ),
      );
    },
  );
}
