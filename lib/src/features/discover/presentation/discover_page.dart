import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n_extension.dart';
import '../../../app/ui_style.dart';
import '../../../shared/presentation/widgets/ot_list_row.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(context.l10n.discoverTitle),
            border: Border(bottom: BorderSide(color: colors.border)),
            backgroundColor: colors.shadowScrim,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _SectionLabel(title: context.l10n.discoverQuickActions)),
          SliverToBoxAdapter(
            child: _ActionGroup(
              children: [
                _DiscoverRow(
                  icon: Icons.inventory_2_rounded,
                  title: context.l10n.discoverImportCharacter,
                  onTap: () => context.pushNamed('character_import'),
                ),
                _DiscoverRow(
                  icon: Icons.edit_note_rounded,
                  title: context.l10n.discoverCreateCharacter,
                  onTap: () => context.pushNamed('character_create'),
                ),
                _DiscoverRow(
                  icon: Icons.person_search_rounded,
                  title: context.l10n.discoverViewCharacters,
                  onTap: () => context.goNamed('characters'),
                ),
                _DiscoverRow(
                  icon: Icons.settings_rounded,
                  title: context.l10n.discoverSettings,
                  onTap: () => context.pushNamed('settings'),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(child: _SectionLabel(title: context.l10n.discoverHelp)),
          SliverToBoxAdapter(
            child: _ActionGroup(
              children: [
                _DiscoverRow(
                  icon: Icons.help_outline_rounded,
                  title: context.l10n.discoverHelp,
                  onTap: () => context.pushNamed('help'),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.otColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionGroup extends StatelessWidget {
  const _ActionGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: OTStyle.flatGroupDecoration(context),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              const Divider(height: 1, indent: 76),
          ],
        ],
      ),
    );
  }
}

class _DiscoverRow extends StatelessWidget {
  const _DiscoverRow({required this.icon, required this.title, this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OTListRow(
      onTap: onTap,
      leading: OTAvatar(child: Icon(icon)),
      title: Text(title),
      trailing: Icon(
        CupertinoIcons.chevron_forward,
        color: context.otColors.tertiaryText,
        size: 18,
      ),
    );
  }
}
