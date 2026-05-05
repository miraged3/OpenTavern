import 'package:flutter/material.dart';

import '../../../app/ui_style.dart';

class OTListRow extends StatelessWidget {
  const OTListRow({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.isThreeLine = false,
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isThreeLine;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    final content = SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, isThreeLine ? 12 : 11, 16, 11),
        child: Row(
          crossAxisAlignment: isThreeLine
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      color: colors.primaryText,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    child: title,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 5),
                    DefaultTextStyle(
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 14,
                        height: 1.32,
                      ),
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: colors.primaryText.withValues(alpha: 0.06),
        highlightColor: colors.primaryText.withValues(alpha: 0.03),
        child: content,
      ),
    );
  }
}

class OTAvatar extends StatelessWidget {
  const OTAvatar({required this.child, this.backgroundColor, super.key});

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.mutedFill,
        shape: BoxShape.circle,
      ),
      child: SizedBox(width: 48, height: 48, child: Center(child: child)),
    );
  }
}
