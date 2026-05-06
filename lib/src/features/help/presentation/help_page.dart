import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app/l10n_extension.dart';
import '../../../app/ui_style.dart';
import '../../../shared/presentation/widgets/ot_list_row.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Scaffold(
      backgroundColor: colors.pageBackground,
      appBar: AppBar(
        title: Text(context.l10n.helpTitle),
        backgroundColor: colors.pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
        children: [
          _SectionTitle(context.l10n.aboutOpenTavern),
          DecoratedBox(
            decoration: OTStyle.flatGroupDecoration(context),
            child: OTListRow(
              onTap: () => _showAboutOpenTavern(context),
              leading: const OTAvatar(child: Icon(Icons.info_outline_rounded)),
              title: Text(context.l10n.aboutOpenTavern),
              trailing: Icon(
                CupertinoIcons.chevron_forward,
                color: colors.tertiaryText,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutOpenTavern(BuildContext context) {
    final colors = context.otColors;
    showAboutDialog(
      context: context,
      applicationName: 'OpenTavern',
      applicationVersion: '0.1',
      applicationIcon: CircleAvatar(
        backgroundColor: colors.accent.withValues(alpha: 0.12),
        child: Icon(Icons.local_fire_department_rounded, color: colors.accent),
      ),
      children: [
        Text(context.l10n.aboutOpenTavernDescription),
        const SizedBox(height: 8),
        SelectableText(context.l10n.aboutOpenTavernRepository),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
      child: Text(
        text,
        style: TextStyle(
          color: colors.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
