import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../app/ui_style.dart';

class OTMarkdownBody extends StatelessWidget {
  const OTMarkdownBody({
    required this.data,
    this.compact = false,
    this.textColor,
    this.linkColor,
    this.codeBackgroundColor,
    this.blockquoteBackgroundColor,
    this.blockquoteBorderColor,
    super.key,
  });

  final String data;
  final bool compact;
  final Color? textColor;
  final Color? linkColor;
  final Color? codeBackgroundColor;
  final Color? blockquoteBackgroundColor;
  final Color? blockquoteBorderColor;

  @override
  Widget build(BuildContext context) {
    if (data.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final colors = context.otColors;
    final resolvedTextColor = textColor ?? colors.primaryText;

    final baseStyle = compact
        ? OTStyle.textStyle(fontSize: 14, height: 1.4, color: resolvedTextColor)
        : OTStyle.textStyle(
            fontSize: 15,
            height: 1.45,
            color: resolvedTextColor,
          );
    final emphasisStyle = OTStyle.isWindows
        ? baseStyle.copyWith(fontWeight: FontWeight.w600)
        : baseStyle.copyWith(fontStyle: FontStyle.italic);

    return MarkdownBody(
      data: data,
      selectable: false,
      softLineBreak: true,
      shrinkWrap: true,
      styleSheet: MarkdownStyleSheet(
        p: baseStyle,
        a: baseStyle.copyWith(
          color: linkColor ?? resolvedTextColor,
          decoration: TextDecoration.underline,
        ),
        strong: baseStyle.copyWith(fontWeight: FontWeight.w700),
        em: emphasisStyle,
        code: baseStyle.copyWith(
          fontFamily: 'monospace',
          backgroundColor: codeBackgroundColor ?? colors.mutedFill,
        ),
        blockquote: baseStyle.copyWith(color: resolvedTextColor),
        blockquotePadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        blockquoteDecoration: BoxDecoration(
          color: blockquoteBackgroundColor ?? colors.quoteBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: blockquoteBorderColor ?? colors.border),
        ),
        h1: OTStyle.textStyle(
          fontSize: 20,
          height: 1.3,
          fontWeight: FontWeight.w800,
          color: resolvedTextColor,
        ),
        h2: OTStyle.textStyle(
          fontSize: 18,
          height: 1.3,
          fontWeight: FontWeight.w800,
          color: resolvedTextColor,
        ),
        h3: OTStyle.textStyle(
          fontSize: 16,
          height: 1.3,
          fontWeight: FontWeight.w800,
          color: resolvedTextColor,
        ),
        listBullet: baseStyle,
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.border)),
        ),
      ),
    );
  }
}
